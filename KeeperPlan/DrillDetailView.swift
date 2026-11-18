import SwiftUI
import AudioToolbox
import Combine

/// One drill: the demo, how to do it, a timer when it's timed, coach tips,
/// and a button to tick it off and go to the next one.
struct DrillDetailView: View {
    @EnvironmentObject private var store: Store
    let drill: Drill
    /// Every drill on today's list, for the Next button.
    let queue: [String]
    @Binding var path: [String]

    private var done: Bool { store.isDone(drill.id) }

    /// The next drill on the list that isn't done yet, looking forward first.
    private var next: Drill? {
        guard let here = queue.firstIndex(of: drill.id) else { return nil }
        let after = queue[(here + 1)...] + queue[..<here]
        return after.first { !store.isDone($0) }.flatMap(Library.drill)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DemoArea(id: drill.id, demo: drill.demo.map(Demos.forDrill))
                        .id("demo-\(drill.id)")
                    Label(drill.focus.name.uppercased(), systemImage: drill.focus.symbol)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.accent)
                    Text(drill.name)
                        .font(.largeTitle.bold())
                    HStack(spacing: 16) {
                        Label(drill.amount, systemImage: "repeat")
                        Label("\(drill.minutes) min", systemImage: "clock")
                    }
                    .font(.subheadline.weight(.semibold))
                    needs
                    Text(drill.summary)
                        .foregroundStyle(.secondary)

                    Card {
                        Label("How to do it", systemImage: "list.number")
                            .font(.headline)
                            .foregroundStyle(Theme.accent)
                        ForEach(drill.steps.indices, id: \.self) { i in
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text("\(i + 1)")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.black)
                                    .frame(width: 24, height: 24)
                                    .background(Theme.accent, in: Circle())
                                    .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
                                Text(drill.steps[i])
                                    .foregroundStyle(.white.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    if let seconds = drill.timer {
                        Countdown(seconds: seconds, label: "Start \(timeText(seconds)) timer", prominent: false) {}
                            .id("timer-\(drill.id)")
                    }

                    TipsCard(tips: drill.tips)
                }
                .padding(16)
            }
            bottomBar
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Speaker.shared.say("\(drill.name). \(drill.amount). " + drill.steps.joined(separator: " "))
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .tint(Theme.accent)
                .accessibilityLabel("Read the steps aloud")
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true   // keep the screen on
            if store.settings.voice { Speaker.shared.say("\(drill.name). \(drill.amount).") }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
        }
    }

    @ViewBuilder
    private var needs: some View {
        let list = Need.allCases.filter { drill.needs.contains($0) }
        HStack(spacing: 8) {
            if list.isEmpty {
                Label("Nothing extra needed", systemImage: "checkmark")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.card, in: Capsule())
            }
            ForEach(list) { need in
                Label(need.name, systemImage: need.symbol)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.card, in: Capsule())
            }
        }
        .foregroundStyle(.white.opacity(0.85))
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) { store.toggleDone(drill.id) }
            } label: {
                Label(done ? "Done" : "Mark as done", systemImage: done ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(BigButtonStyle(filled: !done))
            .sensoryFeedback(.success, trigger: done) { _, new in new }

            if done, let next {
                Button {
                    if !path.isEmpty { path[path.count - 1] = next.id }
                } label: {
                    Label("Next", systemImage: "arrow.right")
                }
                .buttonStyle(BigButtonStyle())
                .frame(maxWidth: 140)
                .accessibilityLabel("Next drill: \(next.name)")
            }
        }
        .padding(16)
    }

    private func timeText(_ seconds: Int) -> String {
        seconds >= 60 && seconds % 60 == 0 ? "\(seconds / 60) min" : "\(seconds) sec"
    }
}

// MARK: - Shared pieces

/// Coach tips: how to do the drill well and what helps most.
struct TipsCard: View {
    let tips: [String]

    var body: some View {
        if !tips.isEmpty {
            Card {
                Label("Coach tips", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.accent)
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 6, height: 6)
                            .alignmentGuide(.firstTextBaseline) { $0[.bottom] + 4 }
                        Text(tip)
                            .foregroundStyle(.white.opacity(0.88))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

struct CheckCircle: View {
    let done: Bool

    var body: some View {
        Image(systemName: done ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 28))
            .foregroundStyle(done ? Theme.accent : Color.white.opacity(0.35))
            .contentTransition(.symbolEffect(.replace))
    }
}

struct StepButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline)
                .frame(width: 44, height: 44)
                .background(Theme.cardStrong, in: Circle())
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol == "minus" ? "Fewer" : "More")
    }
}

/// A tap-to-start countdown. It works from an end time, so it stays correct
/// if the phone locks or the app goes to the background.
struct Countdown: View {
    let seconds: Int
    let label: String
    let prominent: Bool
    let onFinish: () -> Void

    @State private var end: Date?
    @State private var remaining = 0
    @State private var finished = 0
    private let tick = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        Button {
            if end == nil {
                remaining = seconds
                end = Date().addingTimeInterval(Double(seconds))
            } else {
                end = nil
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: end == nil ? "timer" : "stop.fill")
                Text(end == nil ? label : clock)
                    .monospacedDigit()
            }
        }
        .buttonStyle(BigButtonStyle(filled: prominent || end != nil))
        .onReceive(tick) { now in
            guard let end else { return }
            let left = Int(end.timeIntervalSince(now).rounded(.up))
            if left <= 0 {
                self.end = nil
                finished += 1
                AudioServicesPlaySystemSound(1005)
                onFinish()
            } else {
                remaining = left
            }
        }
        .sensoryFeedback(.success, trigger: finished)
    }

    private var clock: String {
        String(format: "%d:%02d", remaining / 60, remaining % 60)
    }
}
