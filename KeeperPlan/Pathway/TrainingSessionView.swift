import SwiftUI
import AVKit
import AudioToolbox

/// A Pathway training session: reps with rest, or timed (with optional
/// work/easy intervals), plus on-screen cues, a metronome, voice and the
/// optional camera coach.
struct TrainingSessionView: View {
    let config: SessionConfig
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @StateObject private var camera: CameraCoach
    @State private var started = Date()
    @State private var repsDone = 0
    @State private var setIndex = 0
    @State private var resting = false
    @State private var restLeft = 0
    @State private var elapsed = 0
    @State private var paused = false
    @State private var cue: (label: String, color: Color)?
    @State private var nextCueAt = Date().addingTimeInterval(3)
    @State private var lastPhase: String?
    @State private var finished: Finished?
    @State private var lastTick = Date()

    struct Finished {
        let completed: Bool
        let seconds: Int
        let reps: Int
        var camera: CameraCoach.Report?
    }

    init(config: SessionConfig) {
        self.config = config
        _camera = StateObject(wrappedValue: CameraCoach(checks: config.drill.checks))
    }

    private let second = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let fast = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.15, blue: 0.1).ignoresSafeArea()
            if let finished {
                SessionReport(drill: config.drill, result: finished) { dismiss() }
            } else {
                live
            }
            if let cue, finished == nil {
                cue.color.ignoresSafeArea()
                    .overlay(Text(cue.label).font(.system(size: 120, weight: .black, design: .rounded)).foregroundStyle(.white).minimumScaleFactor(0.3).padding())
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            if config.camera {
                camera.voice = config.voice
                camera.start()
            }
            if config.voice { Speaker.shared.say(config.format == .reps ? "Set 1. Go." : "Go") }
        }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .onReceive(second) { _ in tick() }
        .onReceive(fast) { now in fastTick(now) }
    }

    // MARK: Live screen

    private var live: some View {
        VStack(spacing: 0) {
            HStack {
                Button { finish(completed: false) } label: { Label("End", systemImage: "xmark") }
                Spacer()
                VStack(spacing: 2) {
                    Text(config.camera ? "CAMERA COACH" : "TRAINING").font(.caption2.weight(.bold).monospaced()).foregroundStyle(Theme.accent)
                    Text(config.drill.name).font(.subheadline.weight(.bold)).lineLimit(1)
                }
                Spacer()
                Color.clear.frame(width: 60, height: 1)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .tint(.white)

            if config.camera {
                ZStack(alignment: .top) {
                    CameraPreview(session: camera.session)
                    SkeletonOverlay(joints: camera.joints, aspect: camera.imageAspect)
                    HStack(spacing: 6) {
                        Circle().fill(camera.recording ? .red : .gray).frame(width: 8, height: 8)
                        Text(camera.status).font(.caption.monospaced())
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.black.opacity(0.6), in: Capsule())
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if let msg = camera.callout {
                        VStack {
                            Spacer()
                            Text(msg.uppercased())
                                .font(.title3.weight(.black)).foregroundStyle(.black)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color(red: 0.89, green: 0.7, blue: 0.24), in: RoundedRectangle(cornerRadius: 10))
                                .padding(.bottom, 14)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxHeight: .infinity)
                .background(.black)
                .animation(.spring(duration: 0.3), value: camera.callout)
            }

            VStack(spacing: 10) {
                Text(bigText)
                    .font(.system(size: config.camera ? 64 : 120, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.5).lineLimit(1)
                    .contentTransition(.numericText())
                Text(subText).font(.headline).foregroundStyle(Color(red: 0.89, green: 0.7, blue: 0.24))
                ProgressView(value: progress).tint(Theme.accent).padding(.horizontal, 30)
                if config.format == .reps {
                    Button { addRep() } label: { Text("+1 REP").font(.system(size: 34, weight: .black)) }
                        .buttonStyle(BigButtonStyle())
                        .disabled(resting)
                        .opacity(resting ? 0.4 : 1)
                        .padding(.horizontal, 30)
                    if resting { Button("Skip rest") { endRest() }.tint(.white) }
                } else {
                    HStack(spacing: 12) {
                        Button(paused ? "Resume" : "Pause") { paused.toggle() }.buttonStyle(BigButtonStyle())
                        Button("Finish now") { finish(completed: true) }.buttonStyle(BigButtonStyle(filled: false))
                    }
                    .padding(.horizontal, 30)
                }
                if !config.camera {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(config.drill.steps.enumerated()), id: \.offset) { i, s in
                            Text("\(i + 1). \(s)").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 16)
                }
            }
            .padding(.vertical, 16)
            .frame(maxHeight: config.camera ? nil : .infinity)
        }
    }

    private var bigText: String {
        if config.format == .reps {
            return resting ? clock(restLeft) : "\(repsDone - setIndex * config.reps)"
        }
        return clock(config.seconds - elapsed)
    }

    private var subText: String {
        if config.format == .reps {
            return resting ? "Rest — set \(setIndex + 1) of \(config.sets) next" : "of \(config.reps) reps · set \(setIndex + 1) of \(config.sets)"
        }
        if let phase = phase { return "\(phase.name) · \(phase.left)s" }
        return paused ? "Paused" : "Keep going"
    }

    private var progress: Double {
        config.format == .reps ? Double(repsDone) / Double(max(1, config.sets * config.reps)) : Double(elapsed) / Double(max(1, config.seconds))
    }

    private var phase: (name: String, left: Int)? {
        guard let iv = config.drill.interval else { return nil }
        let cycle = elapsed % (iv.work + iv.rest)
        return cycle < iv.work ? ("WORK", iv.work - cycle) : ("EASY", iv.work + iv.rest - cycle)
    }

    private func clock(_ s: Int) -> String { String(format: "%d:%02d", max(0, s) / 60, max(0, s) % 60) }

    // MARK: Timing

    private func beep(_ id: SystemSoundID = 1057) { AudioServicesPlaySystemSound(id) }

    private func tick() {
        guard finished == nil else { return }
        if config.format == .reps {
            guard resting else { return }
            restLeft -= 1
            if restLeft <= 3 && restLeft > 0 { beep() }
            if restLeft <= 0 { endRest() }
        } else {
            guard !paused else { return }
            elapsed += 1
            let left = config.seconds - elapsed
            if left == 60 && config.seconds > 120 { beep(); if config.voice { Speaker.shared.say("One minute left") } }
            if left <= 3 && left > 0 { beep() }
            if let p = phase, p.name != lastPhase {
                if lastPhase != nil { beep(1016); if config.voice { Speaker.shared.say(p.name == "WORK" ? "Go" : "Easy") } }
                lastPhase = p.name
            }
            if left <= 0 { finish(completed: true) }
        }
    }

    private func fastTick(_ now: Date) {
        guard finished == nil, !paused, !resting else { return }
        // metronome
        if config.tempo, let bpm = config.drill.tempo, now.timeIntervalSince(lastTick) >= 60 / Double(bpm) {
            lastTick = now
            AudioServicesPlaySystemSound(1104)
        }
        // cues
        // cues: show for 1.3 s, then hide for a random gap
        guard let kind = config.drill.cue else { return }
        if now >= nextCueAt {
            if cue == nil {
                let set: [(String, Color)]
                switch kind {
                case .colors: set = [("RED", .red), ("GREEN", .green), ("BLUE", .blue), ("YELLOW", .yellow)]
                case .arrows: set = [("←", .black), ("→", .black), ("↑", .black)]
                case .numbers: set = (1...5).map { ("\($0)", .black) }
                }
                let pick = set.randomElement()!
                withAnimation(.easeOut(duration: 0.12)) { cue = (pick.0, pick.1) }
                beep(1016)
                if config.voice {
                    Speaker.shared.say(["←": "left", "→": "right", "↑": "back"][pick.0] ?? pick.0.lowercased())
                }
                nextCueAt = now.addingTimeInterval(1.3)
            } else {
                withAnimation(.easeIn(duration: 0.15)) { cue = nil }
                nextCueAt = now.addingTimeInterval(Double.random(in: 1.4...3.8))
            }
        }
    }

    private func addRep() {
        guard !resting, finished == nil else { return }
        repsDone += 1
        beep(1104)
        let total = config.sets * config.reps
        if repsDone >= total { finish(completed: true); return }
        if repsDone % config.reps == 0 {
            setIndex += 1
            if config.rest > 0 {
                resting = true
                restLeft = config.rest
                if config.voice { Speaker.shared.say("Set done. Rest \(config.rest) seconds.") }
            } else if config.voice { Speaker.shared.say("Set \(setIndex + 1).") }
        }
    }

    private func endRest() {
        resting = false
        beep(1016)
        if config.voice { Speaker.shared.say("Set \(setIndex + 1). Go.") }
    }

    private func finish(completed: Bool) {
        guard finished == nil else { return }
        let seconds = Int(Date().timeIntervalSince(started))
        let reps = repsDone
        func save(_ report: CameraCoach.Report?) {
            if seconds > 15 {
                store.addPathwaySession(PathwaySession(drillID: config.drill.id, seconds: seconds, reps: reps, completed: completed,
                                                       camera: config.camera, flags: report?.mistakes.reduce(0) { $0 + $1.count } ?? 0))
            }
            withAnimation { finished = Finished(completed: completed, seconds: seconds, reps: reps, camera: report) }
        }
        if config.voice { Speaker.shared.say(completed ? "Session complete" : "Session ended") }
        if config.camera {
            camera.stop { save($0) }
        } else {
            save(nil)
        }
    }
}

struct SessionReport: View {
    let drill: PathwayDrill
    let result: TrainingSessionView.Finished
    let close: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Kicker(text: result.completed ? "Session complete" : "Session ended early")
                Text(drill.name).font(.largeTitle.weight(.black))
                HStack(spacing: 24) {
                    stat(String(format: "%d:%02d", result.seconds / 60, result.seconds % 60), "time")
                    if result.reps > 0 { stat("\(result.reps)", "reps") }
                    if let low = result.camera?.lowPercent { stat("\(low)%", "athletic stance") }
                    if let scans = result.camera?.scansPerMinute { stat(scans.formatted(), "shoulder checks / min") }
                }
                if let c = result.camera {
                    Card {
                        Text("What the camera coach saw").font(.headline)
                        if let status = c.status {
                            Text(status).foregroundStyle(.secondary)
                        } else if !c.tracked {
                            Text("The camera never saw your whole body. Next time, prop the phone 3–4 yards away at waist height.").foregroundStyle(.secondary)
                        } else if c.mistakes.isEmpty {
                            Text("No form flags — clean session. Make it harder next time: more speed, or the weak foot.").foregroundStyle(Theme.accent)
                        } else {
                            ForEach(c.mistakes) { m in
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(m.message).font(.subheadline.weight(.bold))
                                        Spacer()
                                        Text("\(m.count)× · first at \(m.firstAt / 60):\(String(format: "%02d", m.firstAt % 60))").font(.caption.monospaced()).foregroundStyle(.red)
                                    }
                                    Text(m.fix).font(.footnote).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        Text("Form checks are estimates from body tracking — reminders, not a referee.").font(.caption).foregroundStyle(.tertiary)
                    }
                    if let url = c.videoURL {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        ShareLink(item: url) { Label("Save or share the video", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity) }
                            .buttonStyle(BigButtonStyle(filled: false))
                        Text("The video is only kept until you close this screen. Save it to keep it.").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Card { Text("Also watch for").font(.headline); Bullets(items: drill.mistakes, mark: "xmark", tint: .red) }
                Button("Done", action: close).buttonStyle(BigButtonStyle())
            }
            .padding(20)
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title.weight(.bold).monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
