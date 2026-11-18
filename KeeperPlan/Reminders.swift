import Foundation
import UserNotifications

extension Notification.Name {
    /// Posted when a reminder's "Start now" button is used.
    static let startTodayWorkout = Notification.Name("startTodayWorkout")
}

/// Local notifications. Reminders are scheduled as dated one-offs for the next
/// four weeks, so a day you've already trained never gets a reminder. They are
/// rebuilt every time the app opens or settings change.
///
/// With "Ring like an alarm" on (iOS 26.1 and later), the main reminder for the
/// next two weeks is a real alarm instead, which rings through silent mode.
enum Reminders {
    private static var center: UNUserNotificationCenter { .current() }
    private static let delegate = ReminderDelegate()
    private static let category = "TRAIN"
    private static var alarmWork: Task<Void, Never>?

    /// Set when the app is opened from a reminder's "Start now" button before
    /// the Today screen is ready to hear about it.
    static var pendingStart = false

    private static let lines = [
        "Quick feet, soft hands. Let's go.",
        "Great keepers are made on days like this.",
        "Small session now, big saves later.",
        "Your space is clear and the ball is waiting.",
        "Show up today and keep the streak going.",
        "One session closer to the keeper you want to be.",
    ]

    static func setUp() {
        center.delegate = delegate
        let start = UNNotificationAction(identifier: "START", title: "Start now", options: [.foreground])
        let snooze = UNNotificationAction(identifier: "SNOOZE", title: "Snooze 30 min", options: [])
        center.setNotificationCategories([
            UNNotificationCategory(identifier: category, actions: [start, snooze], intentIdentifiers: [], options: []),
        ])
    }

    static func authorize() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func status() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func refresh(store: Store) {
        center.removeAllPendingNotificationRequests()
        let settings = store.data.reminders
        let useAlarm = settings.enabled && store.settings.alarm

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let streak = store.streak
        var alarms: [(date: Date, title: String, fallback: () -> Void)] = []

        if settings.enabled {
            for offset in 0..<28 {
                guard let day = cal.date(byAdding: .day, value: offset, to: today) else { continue }
                let key = Store.dayKey(day)
                if store.trained(day) { continue }
                let title = "What are you working on today?"
                let body = "Diving, hands, distribution, shot stopping... \(lines[offset % lines.count])"
                let addMain = {
                    add(id: "main-\(key)", day: day, hour: settings.hour, minute: settings.minute, title: title, body: body)
                }

                // Alarms cover the next two weeks; later days stay as notifications
                // until the app is opened again.
                if useAlarm, offset < 14, let fire = fireDate(day, settings.hour, settings.minute), fire > Date() {
                    alarms.append((fire, title, addMain))
                } else {
                    addMain()
                }

                if settings.nudge {
                    let nudge = streak > 0 && offset == 0
                        ? "You're on a \(streak)-day streak. One drill keeps it going."
                        : "Even one drill counts. Pick something and get after it."
                    add(id: "nudge-\(key)", day: day, hour: settings.nudgeHour, minute: settings.nudgeMinute,
                        title: "Still time today", body: nudge)
                }
            }

            if let later = cal.date(byAdding: .day, value: 28, to: today) {
                add(id: "comeback", day: later, hour: settings.hour, minute: settings.minute,
                    title: "Your gloves miss you",
                    body: "Open Keeper to pick a drill and restart your reminders.")
            }
        }

        // Alarm scheduling is asynchronous. Runs are chained so two refreshes
        // in a row cannot leave duplicate alarms behind.
        let previous = alarmWork
        alarmWork = Task {
            await previous?.value
            if #available(iOS 26.1, *) {
                Alarms.cancelAll()
                for alarm in alarms {
                    if await !Alarms.schedule(at: alarm.date, title: alarm.title) {
                        alarm.fallback()   // could not set an alarm, so notify instead
                    }
                }
            } else {
                alarms.forEach { $0.fallback() }
            }
        }
    }

    static func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "Time to train"
        content.body = "This is what your reminder will look like. Press and hold it for Start now and Snooze."
        content.sound = .default
        content.categoryIdentifier = category
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        center.add(UNNotificationRequest(identifier: "test", content: content, trigger: trigger))
    }

    /// Repeats a reminder 30 minutes from now.
    static func snooze(_ original: UNNotificationContent) {
        let content = UNMutableNotificationContent()
        content.title = original.title
        content.body = original.body
        content.sound = .default
        content.categoryIdentifier = category
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        center.add(UNNotificationRequest(identifier: "snooze-\(UUID().uuidString)", content: content, trigger: trigger))
    }

    private static func fireDate(_ day: Date, _ hour: Int, _ minute: Int) -> Date? {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: day)
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps)
    }

    private static func add(id: String, day: Date, hour: Int, minute: Int, title: String, body: String) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: day)
        comps.hour = hour
        comps.minute = minute
        guard let fire = cal.date(from: comps), fire > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}

/// Shows reminders as banners while the app is open, and handles the
/// "Start now" and "Snooze 30 min" buttons.
private final class ReminderDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "SNOOZE":
            Reminders.snooze(response.notification.request.content)
        case "START":
            DispatchQueue.main.async {
                Reminders.pendingStart = true
                NotificationCenter.default.post(name: .startTodayWorkout, object: nil)
            }
        default:
            break
        }
        completionHandler()
    }
}
