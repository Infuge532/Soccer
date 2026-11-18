import SwiftUI

@main
struct KeeperPlanApp: App {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Reminders.setUp()
        Appearance.apply()
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

    @State private var tab = Self.launchTab

    private var mainTabs: some View {
            TabView(selection: $tab) {
                PathwayHomeView()
                    .tag(0)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                PositionsView()
                    .tag(1)
                    .tabItem { Label("Positions", systemImage: "sportscourt.fill") }
                SelectiveView()
                    .tag(2)
                    .tabItem { Label("Selective", systemImage: "sparkles") }
                TrainView()
                    .tag(3)
                    .tabItem { Label("Keeper", systemImage: "hand.raised.fill") }
                ProgressScreen()
                    .tag(4)
                    .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
            }
            .environmentObject(store)
            .tint(Theme.accent)
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: Binding(get: { store.profile == nil }, set: { _ in })) {
                OnboardingView().environmentObject(store)
            }
            .onAppear(perform: debugSeed)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Reminders.refresh(store: store) }
            }
    }

    private static var launchTab: Int {
        #if DEBUG
        if let i = CommandLine.arguments.firstIndex(of: "-tab"), i + 1 < CommandLine.arguments.count { return Int(CommandLine.arguments[i + 1]) ?? 0 }
        #endif
        return 0
    }

    /// Debug only: `-seedProfile` fills in a sample player so screenshots skip onboarding.
    private func debugSeed() {
        #if DEBUG
        if CommandLine.arguments.contains("-seedProfile") && store.profile == nil {
            store.saveProfile(PlayerProfile(name: "Alex Rivera", age: "U15", primary: "RCM", secondary: "CAM", third: "RW",
                                            current: .npl, team: "N1", goal: .mlsh))
        }
        #endif
    }
}

enum Theme {
    static let accent = Color(red: 0.8, green: 0.95, blue: 0.36)
    static let background = Color(red: 0.045, green: 0.05, blue: 0.05)
    static let card = Color(red: 0.1, green: 0.106, blue: 0.106)
    static let cardStrong = Color(red: 0.15, green: 0.16, blue: 0.16)
    static let line = Color.white.opacity(0.08)
    static let muted = Color(white: 0.62)
}

/// A plain dark surface. Use `Panel` for a section with a lime title.
struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Theme.line, lineWidth: 1))
    }
}

struct BigButtonStyle: ButtonStyle {
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(filled ? Color.black : Color.white)
            .background(filled ? Theme.accent : Theme.cardStrong,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(filled ? .clear : Theme.line, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
