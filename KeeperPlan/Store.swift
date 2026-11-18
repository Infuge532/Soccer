import Foundation
import SwiftUI
import WidgetKit

/// One day of training: what you picked to work on and which drills you did.
struct DayLog: Codable, Identifiable {
    var dayKey: String
    var focuses: [Focus] = []
    /// Drill ids, in the order they were ticked.
    var done: [String] = []
    var lastChange = Date()

    var id: String { dayKey }
    var trained: Bool { !done.isEmpty }
}

struct Badge: Identifiable {
    let title: String
    let symbol: String
    let earned: Bool
    var id: String { title }
}

struct CatchEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var count: Int
}

struct ReminderSettings: Codable {
    var enabled = false
    var hour = 16
    var minute = 30
    var nudge = true
    var nudgeHour = 19
    var nudgeMinute = 0
}

struct AppSettings: Codable {
    var voice = true
    var alarm = false
}

struct AppData: Codable {
    var days: [String: DayLog] = [:]
    var setup = Setup()
    var catches: [CatchEntry] = []
    var reminders = ReminderSettings()
    var settings = AppSettings()
}

final class Store: ObservableObject {
    @Published var data: AppData {
        didSet { persist() }
    }

    private static let key = "keeperplan.data.v2"
    private static let oldKey = "keeperplan.data.v1"

    /// The parts of the old 4-week-plan data that still mean something.
    private struct Legacy: Decodable {
        var catches: [CatchEntry]?
        var reminders: ReminderSettings?
    }

    init() {
        let defaults = UserDefaults.standard
        if let raw = defaults.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode(AppData.self, from: raw) {
            data = decoded
        } else {
            var fresh = AppData()
            if let raw = defaults.data(forKey: Self.oldKey),
               let old = try? JSONDecoder().decode(Legacy.self, from: raw) {
                fresh.catches = old.catches ?? []
                fresh.reminders = old.reminders ?? ReminderSettings()
            }
            data = fresh
        }
        shareWithWidget()
    }

    private func persist() {
        if let raw = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(raw, forKey: Self.key)
        }
        shareWithWidget()
    }

    /// The widget cannot read the app's storage, so the days trained and
    /// today's picks go into the shared app group for it.
    private func shareWithWidget() {
        guard let shared = UserDefaults(suiteName: "group.app.keeperplan.hometraining") else { return }
        let trained = data.days.values.filter(\.trained).map(\.dayKey).sorted()
        let focus = today.focuses.map(\.name).joined(separator: " + ")
        if shared.stringArray(forKey: "doneDays") != trained
            || shared.string(forKey: "todayFocus") != focus
            || shared.integer(forKey: "todayDone") != today.done.count {
            shared.set(trained, forKey: "doneDays")
            shared.set(focus, forKey: "todayFocus")
            shared.set(today.done.count, forKey: "todayDone")
            shared.set(Self.dayKey(Date()), forKey: "todayKey")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: Dates

    private static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dayKey(_ date: Date) -> String { keyFormatter.string(from: date) }
    static func date(fromKey key: String) -> Date? { keyFormatter.date(from: key) }

    static func monday(of date: Date) -> Date {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        let offset = (cal.component(.weekday, from: day) + 5) % 7
        return cal.date(byAdding: .day, value: -offset, to: day) ?? day
    }

    // MARK: Today

    var todayKey: String { Self.dayKey(Date()) }

    /// Today's picks and ticks. A new day starts empty so you can pick again.
    var today: DayLog { data.days[todayKey] ?? DayLog(dayKey: todayKey) }

    private func updateToday(_ change: (inout DayLog) -> Void) {
        var log = today
        change(&log)
        log.lastChange = Date()
        if log.focuses.isEmpty && log.done.isEmpty {
            data.days[todayKey] = nil
        } else {
            data.days[todayKey] = log
        }
    }

    func toggleFocus(_ focus: Focus) {
        updateToday { log in
            if let i = log.focuses.firstIndex(of: focus) {
                log.focuses.remove(at: i)
            } else {
                log.focuses.append(focus)
            }
        }
    }

    func clearFocuses() {
        updateToday { $0.focuses = [] }
    }

    func isDone(_ drillID: String) -> Bool { today.done.contains(drillID) }

    func toggleDone(_ drillID: String) {
        updateToday { log in
            if let i = log.done.firstIndex(of: drillID) {
                log.done.remove(at: i)
            } else {
                log.done.append(drillID)
                if let focus = Library.drill(drillID)?.focus, !log.focuses.contains(focus) {
                    log.focuses.append(focus)
                }
            }
        }
    }

    func toggleNeed(_ need: Need) {
        data.setup.toggle(need)
    }

    // MARK: History

    func trained(_ date: Date) -> Bool { data.days[Self.dayKey(date)]?.trained ?? false }

    /// Days you trained, newest first.
    var history: [DayLog] {
        data.days.values.filter(\.trained).sorted { $0.dayKey > $1.dayKey }
    }

    var totalDrills: Int { data.days.values.reduce(0) { $0 + $1.done.count } }

    /// Days trained in a row. Today only counts once you've done a drill.
    var streak: Int {
        let cal = Calendar.current
        var day = cal.startOfDay(for: Date())
        if !trained(day) { day = cal.date(byAdding: .day, value: -1, to: day) ?? day }
        var count = 0
        while trained(day) {
            count += 1
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    var longestStreak: Int {
        let cal = Calendar.current
        let dates = history.compactMap { Self.date(fromKey: $0.dayKey) }.sorted()
        var best = 0, run = 0
        var previous: Date?
        for date in dates {
            if let previous, cal.dateComponents([.day], from: previous, to: date).day == 1 {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            previous = date
        }
        return best
    }

    func daysTrained(inWeekOf date: Date) -> Int {
        let monday = Self.monday(of: date)
        return (0..<7).filter { offset in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: monday) else { return false }
            return trained(day)
        }.count
    }

    /// How many drills you've done for each focus, all time.
    var drillsByFocus: [(focus: Focus, count: Int)] {
        var counts: [Focus: Int] = [:]
        for log in data.days.values {
            for id in log.done {
                if let focus = Library.drill(id)?.focus { counts[focus, default: 0] += 1 }
            }
        }
        return Focus.allCases.map { ($0, counts[$0] ?? 0) }
    }

    func clearHistory() {
        data.days = [:]
    }

    // MARK: Badges

    var badges: [Badge] {
        let days = history.count
        let focusesTried = drillsByFocus.filter { $0.count > 0 }.count
        return [
            Badge(title: "First drill", symbol: "figure.run", earned: totalDrills >= 1),
            Badge(title: "3 days in a row", symbol: "flame.fill", earned: longestStreak >= 3),
            Badge(title: "7 days in a row", symbol: "calendar", earned: longestStreak >= 7),
            Badge(title: "10 days", symbol: "10.circle.fill", earned: days >= 10),
            Badge(title: "50 drills", symbol: "checkmark.seal.fill", earned: totalDrills >= 50),
            Badge(title: "All-rounder", symbol: "star.circle.fill", earned: focusesTried >= Focus.allCases.count),
            Badge(title: "50 catches", symbol: "hand.raised.fill", earned: bestCatchStreak >= 50),
            Badge(title: "100 catches", symbol: "star.fill", earned: bestCatchStreak >= 100),
        ]
    }

    // MARK: Settings

    var settings: AppSettings {
        get { data.settings }
        set { data.settings = newValue }
    }

    // MARK: Wall-catch streak

    var bestCatchStreak: Int { data.catches.map(\.count).max() ?? 0 }

    func addCatchStreak(_ count: Int) {
        guard count > 0 else { return }
        data.catches.append(CatchEntry(date: Date(), count: count))
    }
}
