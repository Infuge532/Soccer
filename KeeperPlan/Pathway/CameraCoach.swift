import SwiftUI
import AVFoundation
import Vision

/// Front camera + on-device body tracking (Apple Vision) + recording.
/// Flags form mistakes during a drill. Nothing leaves the phone.
final class CameraCoach: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    struct Mistake: Identifiable {
        let check: String
        let message: String
        let fix: String
        var count: Int
        let firstAt: Int
        var id: String { check }
    }

    struct Report {
        var mistakes: [Mistake]
        var lowPercent: Int?
        var scansPerMinute: Double?
        var tracked: Bool
        var status: String?
        var videoURL: URL?
    }

    static let checkText: [String: (msg: String, fix: String)] = [
        "low": ("Bend your knees — get low", "Athletic stance: knees bent, weight on the balls of your feet."),
        "headUp": ("Lift your eyes off the ball", "Glance down to touch, then eyes up. Use your peripheral vision for the ball."),
        "base": ("Widen your base", "Feet a little wider than your shoulders so you can move either way."),
        "hands": ("Hands up and ready", "Hands out in front at waist height or above — ready before the ball comes."),
        "balance": ("Stay balanced — chest over the ball", "Leaning back sends the ball high and kills your balance. Stay stacked over the ball."),
        "scan": ("Check your shoulder", "Scan while the ball is traveling — a quick head turn, at least once per pass."),
        "frame": ("Step back — whole body in frame", "Prop the phone 3–4 yards away at waist height so it sees head to feet."),
    ]

    let session = AVCaptureSession()
    @Published var status = "Starting camera…"
    @Published var callout: String?
    /// Joints in normalized image coordinates, origin top-left.
    @Published var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    @Published var imageAspect: CGFloat = 9.0 / 16.0
    @Published var recording = false

    var voice = true
    var isIdle: () -> Bool = { false }

    private let checks: Set<String>
    private let queue = DispatchQueue(label: "pathway.camera")
    private var writer: AVAssetWriter?
    private var writerInput: AVAssetWriterInput?
    private var outputURL: URL?
    private var frameCount = 0
    private var started = Date()
    private var since: [String: Date] = [:]
    private var fired: Set<String> = []
    private var counts: [String: Int] = [:]
    private var firstAt: [String: Int] = [:]
    private var lastCall = Date.distantPast
    private var lowFrames = 0
    private var poseFrames = 0
    private var scans = 0
    private var turned = false
    private var lastScan = Date()
    private var stopped = false
    private var available = false

    init(checks: [FormCheck]) {
        self.checks = Set(checks.map(\.rawValue) + ["frame"])
        super.init()
    }

    func start() {
        AVCaptureDevice.requestAccess(for: .video) { ok in
            guard ok else { DispatchQueue.main.async { self.status = "Camera blocked — allow it in Settings › Keeper, or train without it." }; return }
            self.queue.async { self.configure() }
        }
    }

    private func configure() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            DispatchQueue.main.async { self.status = "No camera on this device." }
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .hd1280x720
        if session.canAddInput(input) { session.addInput(input) }
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        if let c = output.connection(with: .video) {
            if c.isVideoRotationAngleSupported(90) { c.videoRotationAngle = 90 }
            if c.isVideoMirroringSupported { c.automaticallyAdjustsVideoMirroring = false; c.isVideoMirrored = true }
        }
        session.commitConfiguration()
        session.startRunning()
        available = true
        started = Date()
        lastScan = Date()
        DispatchQueue.main.async { self.status = "Recording · form checks on" }
    }

    // MARK: Frames

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !stopped, let pixels = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        record(sampleBuffer, pixels)
        frameCount += 1
        guard frameCount % 3 == 0 else { return }  // ~10 checks a second is plenty

        let w = CGFloat(CVPixelBufferGetWidth(pixels)), h = CGFloat(CVPixelBufferGetHeight(pixels))
        let request = VNDetectHumanBodyPoseRequest()
        try? VNImageRequestHandler(cvPixelBuffer: pixels, orientation: .up).perform([request])
        var found: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        if let obs = request.results?.first, let points = try? obs.recognizedPoints(.all) {
            for (name, p) in points where p.confidence > 0.3 {
                found[name] = CGPoint(x: p.location.x, y: 1 - p.location.y)
            }
        }
        let now = Date()
        DispatchQueue.main.async {
            self.joints = found
            self.imageAspect = w / h
            if !self.isIdle() { self.evaluate(found, w: w, h: h, now: now) }
        }
    }

    private func record(_ buffer: CMSampleBuffer, _ pixels: CVPixelBuffer) {
        let time = CMSampleBufferGetPresentationTimeStamp(buffer)
        if writer == nil {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("pathway-\(UUID().uuidString).mov")
            guard let w = try? AVAssetWriter(outputURL: url, fileType: .mov) else { return }
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: CVPixelBufferGetWidth(pixels),
                AVVideoHeightKey: CVPixelBufferGetHeight(pixels),
            ])
            input.expectsMediaDataInRealTime = true
            guard w.canAdd(input) else { return }
            w.add(input)
            w.startWriting()
            w.startSession(atSourceTime: time)
            writer = w; writerInput = input; outputURL = url
            DispatchQueue.main.async { self.recording = true }
        }
        if let input = writerInput, input.isReadyForMoreMediaData, writer?.status == .writing {
            input.append(buffer)
        }
    }

    // MARK: Checks

    private func flag(_ key: String, _ now: Date) {
        counts[key, default: 0] += 1
        if firstAt[key] == nil { firstAt[key] = Int(now.timeIntervalSince(started)) }
        guard now.timeIntervalSince(lastCall) > 3.5, let text = Self.checkText[key] else { return }
        lastCall = now
        callout = text.msg
        if voice { Speaker.shared.say(text.msg) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            if self?.callout == text.msg { self?.callout = nil }
        }
    }

    /// A condition has to hold for a while before it counts, and counts once per stretch.
    private func sustain(_ key: String, _ bad: Bool, _ seconds: Double, _ now: Date) {
        guard checks.contains(key) else { return }
        if bad {
            if let begin = since[key] {
                if !fired.contains(key) && now.timeIntervalSince(begin) > seconds {
                    flag(key, now)
                    fired.insert(key)
                }
            } else {
                since[key] = now
            }
        } else {
            since[key] = nil
            fired.remove(key)
        }
    }

    private func evaluate(_ j: [VNHumanBodyPoseObservation.JointName: CGPoint], w: CGFloat, h: CGFloat, now: Date) {
        func pt(_ n: VNHumanBodyPoseObservation.JointName) -> CGPoint? { j[n].map { CGPoint(x: $0.x * w, y: $0.y * h) } }
        func angle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Double {
            let v1 = CGVector(dx: a.x - b.x, dy: a.y - b.y), v2 = CGVector(dx: c.x - b.x, dy: c.y - b.y)
            let c = Double((v1.dx * v2.dx + v1.dy * v2.dy) / max(0.0001, hypot(v1.dx, v1.dy) * hypot(v2.dx, v2.dy)))
            return Foundation.acos(Swift.max(-1.0, Swift.min(1.0, c))) * 180 / Double.pi
        }
        guard let ls = pt(.leftShoulder), let rs = pt(.rightShoulder) else {
            sustain("frame", true, 2.5, now)
            return
        }
        let shoulderWidth = max(1, hypot(ls.x - rs.x, ls.y - rs.y))

        if let lh = pt(.leftHip), let rh = pt(.rightHip), let lk = pt(.leftKnee), let rk = pt(.rightKnee),
           let la = pt(.leftAnkle), let ra = pt(.rightAnkle) {
            sustain("frame", false, 0, now)
            poseFrames += 1
            let knee = (angle(lh, lk, la) + angle(rh, rk, ra)) / 2
            if knee < 158 { lowFrames += 1 }
            sustain("low", knee > 166, 1.4, now)
            sustain("base", hypot(la.x - ra.x, la.y - ra.y) / shoulderWidth < 0.85, 1.6, now)
            let sh = CGPoint(x: (ls.x + rs.x) / 2, y: (ls.y + rs.y) / 2), hip = CGPoint(x: (lh.x + rh.x) / 2, y: (lh.y + rh.y) / 2)
            let lean = abs(Double(atan2(sh.x - hip.x, hip.y - sh.y)) * 180 / Double.pi)
            sustain("balance", lean > 28, 1.0, now)
            if let lw = pt(.leftWrist), let rw = pt(.rightWrist) {
                let hipY = (lh.y + rh.y) / 2
                sustain("hands", lw.y > hipY && rw.y > hipY, 1.5, now)
            }
        } else {
            sustain("frame", true, 2.5, now)
        }

        if let nose = pt(.nose) {
            let shY = (ls.y + rs.y) / 2
            sustain("headUp", (shY - nose.y) / shoulderWidth < 0.28, 2.2, now)
            if checks.contains("scan") {
                let yaw = (nose.x - (ls.x + rs.x) / 2) / shoulderWidth
                let isTurned = abs(yaw) > 0.32 || j[.leftEar] == nil || j[.rightEar] == nil
                if isTurned && !turned { scans += 1; lastScan = now }
                turned = isTurned
                if now.timeIntervalSince(lastScan) > 7 { flag("scan", now); lastScan = now }
            }
        }
    }

    // MARK: Stop

    func stop(completion: @escaping (Report) -> Void) {
        let minutes = Date().timeIntervalSince(started) / 60
        let mistakes = counts.map { key, n in
            Mistake(check: key, message: Self.checkText[key]?.msg ?? key, fix: Self.checkText[key]?.fix ?? "", count: n, firstAt: firstAt[key] ?? 0)
        }.sorted { $0.count > $1.count }
        var report = Report(mistakes: mistakes,
                            lowPercent: poseFrames > 0 ? Int(Double(lowFrames) / Double(poseFrames) * 100) : nil,
                            scansPerMinute: checks.contains("scan") && minutes > 0.1 && available ? (Double(scans) / minutes * 10).rounded() / 10 : nil,
                            tracked: poseFrames > 0,
                            status: available ? nil : status,
                            videoURL: nil)
        queue.async {
            self.stopped = true
            self.session.stopRunning()
            guard let writer = self.writer, writer.status == .writing else {
                DispatchQueue.main.async { completion(report) }
                return
            }
            self.writerInput?.markAsFinished()
            writer.finishWriting {
                report.videoURL = writer.status == .completed ? self.outputURL : nil
                DispatchQueue.main.async { completion(report) }
            }
        }
    }
}

/// Live camera picture.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var preview: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.preview.session = session
        v.preview.videoGravity = .resizeAspect
        v.backgroundColor = .black
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

/// Skeleton drawn over the camera picture.
struct SkeletonOverlay: View {
    let joints: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let aspect: CGFloat

    private static let bones: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.leftShoulder, .rightShoulder), (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist), (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
        (.leftHip, .rightHip), (.leftHip, .leftKnee), (.leftKnee, .leftAnkle), (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
        (.neck, .nose),
    ]

    var body: some View {
        Canvas { ctx, size in
            // the picture is aspect-fit inside the view
            var rect = CGRect(origin: .zero, size: size)
            if size.width / size.height > aspect {
                let w = size.height * aspect; rect = CGRect(x: (size.width - w) / 2, y: 0, width: w, height: size.height)
            } else {
                let h = size.width / aspect; rect = CGRect(x: 0, y: (size.height - h) / 2, width: size.width, height: h)
            }
            func p(_ n: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
                joints[n].map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) }
            }
            for (a, b) in Self.bones {
                guard let pa = p(a), let pb = p(b) else { continue }
                var path = Path(); path.move(to: pa); path.addLine(to: pb)
                ctx.stroke(path, with: .color(Theme.accent), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
            for n in joints.keys {
                guard let c = p(n) else { continue }
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 4, y: c.y - 4, width: 8, height: 8)), with: .color(.white))
            }
        }
        .allowsHitTesting(false)
    }
}
