import SwiftUI
import UserNotifications

struct RemindersView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.openURL) private var openURL
    @State private var denied = false
    @State private var confirmRestart = false
    @State private var testSent = false
    @State private var alarmDenied = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Daily reminder", isOn: enabledBinding)
                    if store.data.reminders.enabled {
                        DatePicker("Remind me at", selection: time(\.hour, \.minute), displayedComponents: .hourAndMinute)
                    }
                } footer: {
                    Text("A notification every day at this time, asking what you want to work on. Days you have already trained are skipped.")
                }

                if store.data.reminders.enabled, #available(iOS 26.1, *) {
                    Section {
                        Toggle("Ring like an alarm", isOn: alarmBinding)
                    } footer: {
                        Text(alarmDenied
                             ? "Alarms are turned off for this app. Allow them in the Settings app, then switch this on again."
                             : "Rings through silent mode and Focus and stays on screen until you stop it, with a Start button. Covers the next two weeks and renews each time you open the app.")
                    }
                }

                if store.data.reminders.enabled {
                    Section {
                        Toggle("Second nudge if not done", isOn: $store.data.reminders.nudge)
                        if store.data.reminders.nudge {
                            DatePicker("Nudge me at", selection: time(\.nudgeHour, \.nudgeMinute), displayedComponents: .hourAndMinute)
                        }
                    } footer: {
                        Text("A follow-up later in the day, only if you haven't ticked off a drill yet.")
                    }

                    Section {
                        Button(testSent ? "Sent. Lock your phone to see it." : "Send a test notification in 5 sec") {
                            Reminders.sendTest()
                            testSent = true
                        }
                    }
                }

                if denied {
                    Section {
                        Text("Notifications are turned off for this app, so reminders cannot appear.")
                            .foregroundStyle(.secondary)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                        }
                    }
                }

                Section {
                    Toggle("Say the drill name aloud", isOn: $store.settings.voice)
                } header: {
                    Text("Drills")
                } footer: {
                    Text("Reads out the drill and how much to do when you open it, so you can leave the phone on the grass. The speaker button on a drill reads all the steps.")
                }

                Section("Safety rules") {
                    ForEach(Library.safetyRules, id: \.self) { rule in
                        Label(rule, systemImage: "checkmark.shield")
                    }
                }

                Section {
                    Button("Clear training history", role: .destructive) { confirmRestart = true }
                } footer: {
                    Text("Removes every training day and ticked-off drill. Your wall-catch streaks are kept.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .confirmationDialog("Clear all your training days and ticked-off drills? This can't be undone.", isPresented: $confirmRestart, titleVisibility: .visible) {
                Button("Clear history", role: .destructive) {
                    store.clearHistory()
                    refresh()
                }
            }
            .onChange(of: store.data.reminders.hour) { _, _ in refresh() }
            .onChange(of: store.data.reminders.minute) { _, _ in refresh() }
            .onChange(of: store.data.reminders.nudge) { _, _ in refresh() }
            .onChange(of: store.data.reminders.nudgeHour) { _, _ in refresh() }
            .onChange(of: store.data.reminders.nudgeMinute) { _, _ in refresh() }
            .task { await checkStatus() }
        }
    }

    /// Turning the toggle on asks iOS for permission first.
    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { store.data.reminders.enabled },
            set: { on in
                guard on else {
                    store.data.reminders.enabled = false
                    refresh()
                    return
                }
                Task { @MainActor in
                    let granted = await Reminders.authorize()
                    store.data.reminders.enabled = granted
                    denied = !granted
                    refresh()
                }
            })
    }

    /// Turning the alarm on asks iOS for permission to set alarms first.
    @available(iOS 26.1, *)
    private var alarmBinding: Binding<Bool> {
        Binding(
            get: { store.settings.alarm },
            set: { on in
                guard on else {
                    store.settings.alarm = false
                    refresh()
                    return
                }
                Task { @MainActor in
                    let granted = await Alarms.authorize()
                    store.settings.alarm = granted
                    alarmDenied = !granted
                    refresh()
                }
            })
    }

    private func time(_ hour: WritableKeyPath<ReminderSettings, Int>,
                      _ minute: WritableKeyPath<ReminderSettings, Int>) -> Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = store.data.reminders[keyPath: hour]
                comps.minute = store.data.reminders[keyPath: minute]
                return Calendar.current.date(from: comps) ?? Date()
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                store.data.reminders[keyPath: hour] = comps.hour ?? 16
                store.data.reminders[keyPath: minute] = comps.minute ?? 30
            })
    }

    private func refresh() {
        Reminders.refresh(store: store)
    }

    private func checkStatus() async {
        let status = await Reminders.status()
        denied = status == .denied
        if denied && store.data.reminders.enabled {
            store.data.reminders.enabled = false
        }
    }
}
