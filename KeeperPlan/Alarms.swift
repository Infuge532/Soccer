import SwiftUI
import AlarmKit
import AppIntents

/// Real alarms through Apple's AlarmKit. Unlike a notification, an alarm rings
/// through silent mode and Focus and takes over the screen until it is stopped.
@available(iOS 26.1, *)
enum Alarms {
    private static let key = "keeperplan.alarmIDs"

    struct Metadata: AlarmMetadata {}

    static var isAuthorized: Bool { AlarmManager.shared.authorizationState == .authorized }

    static func authorize() async -> Bool {
        if isAuthorized { return true }
        return (try? await AlarmManager.shared.requestAuthorization()) == .authorized
    }

    /// Cancels every alarm this app has set.
    static func cancelAll() {
        let ids = UserDefaults.standard.stringArray(forKey: key) ?? []
        for id in ids.compactMap(UUID.init(uuidString:)) {
            try? AlarmManager.shared.cancel(id: id)
        }
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Sets one alarm. Returns false if the system refused it.
    static func schedule(at date: Date, title: String) async -> Bool {
        guard isAuthorized else { return false }
        let id = UUID()
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(String.LocalizationValue(title)),
            secondaryButton: AlarmButton(text: "Start", textColor: .black, systemImageName: "figure.run"),
            secondaryButtonBehavior: .custom)
        let attributes = AlarmAttributes<Metadata>(presentation: AlarmPresentation(alert: alert), tintColor: Theme.accent)
        let configuration = AlarmManager.AlarmConfiguration<Metadata>(
            schedule: .fixed(date), attributes: attributes, secondaryIntent: StartWorkoutIntent())
        do {
            _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
            var ids = UserDefaults.standard.stringArray(forKey: key) ?? []
            ids.append(id.uuidString)
            UserDefaults.standard.set(ids, forKey: key)
            return true
        } catch {
            return false
        }
    }
}

/// The alarm's "Start" button: opens the app on today's workout.
@available(iOS 26.1, *)
struct StartWorkoutIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start workout"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            Reminders.pendingStart = true
            NotificationCenter.default.post(name: .startTodayWorkout, object: nil)
        }
        return .result()
    }
}
