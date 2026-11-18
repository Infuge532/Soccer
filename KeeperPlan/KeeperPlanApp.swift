import SwiftUI

@main
struct KeeperPlanApp: App {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Reminders.setUp()
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if let i = CommandLine.arguments.firstIndex(of: "-gallery") {
                DemoGallery(page: Int(CommandLine.arguments[min(i + 1, CommandLine.arguments.count - 1)]) ?? 0)
                    .preferredColorScheme(.dark)
            } else {
                mainTabs
            }
            #else
            mainTabs
            #endif
        }
    }

    private var mainTabs: some View {
            TabView {
                TrainView()
                    .tabItem { Label("Train", systemImage: "soccerball") }
                ProgressScreen()
                    .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                RemindersView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            .environmentObject(store)
            .tint(Theme.accent)
            .preferredColorScheme(.dark)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Reminders.refresh(store: store) }
            }
    }
}

enum Theme {
    static let accent = Color(red: 0.74, green: 0.93, blue: 0.22)
    static let background = Color(red: 0.04, green: 0.06, blue: 0.05)
    static let card = Color.white.opacity(0.07)
    static let cardStrong = Color.white.opacity(0.12)
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct BigButtonStyle: ButtonStyle {
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(filled ? Color.black : Color.white)
            .background(filled ? Theme.accent : Theme.cardStrong,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
