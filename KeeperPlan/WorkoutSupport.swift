import SwiftUI
import AVFoundation
import PhotosUI
import CoreTransferable

/// Speaks the next exercise aloud so the phone can stay on the floor.
final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()

    func say(_ text: String) {
        // Play over the silent switch, and dip any music instead of stopping it.
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

/// Your own video clip for a drill, kept in the app's Documents folder.
enum Clips {
    private static var folder: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("clips")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func url(_ id: String) -> URL { folder.appendingPathComponent("\(id).mov") }
    static func exists(_ id: String) -> Bool { FileManager.default.fileExists(atPath: url(id).path) }

    static func save(from source: URL, id: String) throws {
        remove(id)
        try FileManager.default.copyItem(at: source, to: url(id))
    }

    static func remove(_ id: String) {
        try? FileManager.default.removeItem(at: url(id))
    }
}

/// A video picked from the photo library, copied somewhere we can read it.
struct PickedMovie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return PickedMovie(url: copy)
        }
    }
}

/// Plays a clip silently on a loop.
struct LoopingVideo: UIViewRepresentable {
    let url: URL

    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var looper: AVPlayerLooper?
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        let player = AVQueuePlayer()
        player.isMuted = true
        view.looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.backgroundColor = .black
        player.play()
        return view
    }

    func updateUIView(_ view: PlayerView, context: Context) {}

    static func dismantleUIView(_ view: PlayerView, coordinator: ()) {
        view.playerLayer.player?.pause()
    }
}

/// The demo at the top of a step: the 3D figure, or your own clip if you added one.
struct DemoArea: View {
    let id: String
    /// nil when no 3D demo fits the drill. You can still add your own video.
    let demo: Demo?

    @State private var hasClip = false
    @State private var showClip = true
    @State private var picked: PhotosPickerItem?
    @State private var importing = false

    var body: some View {
        VStack(spacing: 8) {
            if hasClip && showClip {
                LoopingVideo(url: Clips.url(id))
                    .frame(height: 270)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else if let demo {
                DemoFigure(demo: demo)
            }
            HStack(spacing: 14) {
                if hasClip {
                    Button(showClip ? "Show 3D figure" : "Show my video") { showClip.toggle() }
                    Button("Remove video", role: .destructive) {
                        Clips.remove(id)
                        hasClip = false
                    }
                } else {
                    PhotosPicker(selection: $picked, matching: .videos) {
                        Label(importing ? "Adding video…" : "Use my own video", systemImage: "video.badge.plus")
                    }
                }
                Spacer()
            }
            .font(.footnote.weight(.semibold))
            .tint(Theme.accent)
        }
        .onAppear { hasClip = Clips.exists(id) }
        .onChange(of: picked) { _, item in
            guard let item else { return }
            importing = true
            Task {
                if let movie = try? await item.loadTransferable(type: PickedMovie.self) {
                    try? Clips.save(from: movie.url, id: id)
                    try? FileManager.default.removeItem(at: movie.url)
                }
                await MainActor.run {
                    hasClip = Clips.exists(id)
                    showClip = true
                    importing = false
                    picked = nil
                }
            }
        }
    }
}
