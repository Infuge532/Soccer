import SwiftUI
import UIKit

// The look of the whole app: tall condensed caps for headings and numbers,
// a floodlit stadium behind the big screens, and notched dark panels.

extension Font {
    /// Tall, condensed caps for headings, numbers and labels.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight).width(.compressed)
    }
}

enum Appearance {
    /// Navigation bar titles in the display face.
    static func apply() {
        let large = UIFont.systemFont(ofSize: 44, weight: .heavy, width: .compressed)
        let small = UIFont.systemFont(ofSize: 21, weight: .heavy, width: .compressed)
        let edge = UINavigationBarAppearance()
        edge.configureWithTransparentBackground()
        edge.largeTitleTextAttributes = [.font: large, .foregroundColor: UIColor.white]
        edge.titleTextAttributes = [.font: small, .foregroundColor: UIColor.white]
        let standard = UINavigationBarAppearance()
        standard.configureWithDefaultBackground()
        standard.backgroundColor = UIColor(Theme.background).withAlphaComponent(0.85)
        standard.largeTitleTextAttributes = edge.largeTitleTextAttributes
        standard.titleTextAttributes = edge.titleTextAttributes
        let bar = UINavigationBar.appearance()
        bar.standardAppearance = standard
        bar.compactAppearance = standard
        bar.scrollEdgeAppearance = edge
    }
}

// MARK: - Headings

/// Lime condensed caps, like "MY STATUS".
struct SectionHeader: View {
    let text: String
    var size: CGFloat = 26
    var body: some View {
        Text(text.uppercased())
            .font(.display(size))
            .foregroundStyle(Theme.accent)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Panels

/// A rounded panel whose top edge steps down after a raised tab on the left.
struct NotchedPanelShape: Shape {
    var radius: CGFloat = 18
    /// How much of the width the raised tab covers.
    var tab: CGFloat = 0.44
    /// How far the rest of the top edge sits below the tab.
    var drop: CGFloat = 12

    func path(in r: CGRect) -> Path {
        let tabEnd = r.minX + r.width * tab
        let low = r.minY + drop
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY - radius))
        p.addArc(tangent1End: CGPoint(x: r.minX, y: r.minY), tangent2End: CGPoint(x: r.minX + radius, y: r.minY), radius: radius)
        p.addArc(tangent1End: CGPoint(x: tabEnd, y: r.minY), tangent2End: CGPoint(x: tabEnd + drop * 1.6, y: low), radius: 6)
        p.addArc(tangent1End: CGPoint(x: tabEnd + drop * 1.6, y: low), tangent2End: CGPoint(x: r.maxX, y: low), radius: 6)
        p.addArc(tangent1End: CGPoint(x: r.maxX, y: low), tangent2End: CGPoint(x: r.maxX, y: r.maxY), radius: radius)
        p.addArc(tangent1End: CGPoint(x: r.maxX, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.maxY), radius: radius)
        p.addArc(tangent1End: CGPoint(x: r.minX, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.minY), radius: radius)
        p.closeSubpath()
        return p
    }
}

/// The main section container: a notched panel with an optional lime title.
struct Panel<Content: View>: View {
    var title: String? = nil
    var spacing: CGFloat = 12
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title { SectionHeader(text: title) }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.top, 21)
        .padding(.bottom, 18)
        .background(NotchedPanelShape().fill(Theme.card))
        .overlay(NotchedPanelShape().stroke(Theme.line, lineWidth: 1))
    }
}

/// A label and value on one line with a hairline under it.
struct StatusRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).foregroundStyle(Theme.muted)
            Spacer(minLength: 6)
            Text(value).font(.display(20, .bold)).monospacedDigit()
        }
        .font(.subheadline)
        .padding(.vertical, 5)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
}

// MARK: - Buttons

struct CircleIconButton: View {
    let symbol: String
    var dot = false
    var label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.card.opacity(0.9)))
                .overlay(Circle().stroke(Theme.line, lineWidth: 1))
                .overlay(alignment: .topTrailing) {
                    if dot { Circle().fill(Theme.accent).frame(width: 9, height: 9).offset(x: -6, y: 6) }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// The big lime square with an arrow, inside a thin ring.
struct ArrowSquareButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 76, height: 76)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.accent))
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1.5))
                .shadow(color: Theme.accent.opacity(0.35), radius: 24)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Get started")
    }
}

/// A pill with an icon in a circle and a lime count, like "Turf (06)".
struct IconPill: View {
    let symbol: String
    let title: String
    var count: Int? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.cardStrong))
            HStack(spacing: 0) {
                Text(title)
                if let count {
                    Text(" (")
                    Text(String(format: "%02d", count)).foregroundStyle(Theme.accent)
                    Text(")")
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
        }
        .padding(.leading, 5).padding(.trailing, 16).padding(.vertical, 5)
        .background(Capsule().fill(Theme.card))
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
    }
}

// MARK: - Stadium

/// A floodlit stadium that fades into the background. Drop a photo named
/// "Stadium" into Assets.xcassets and it's used instead of the drawing.
struct StadiumBackdrop: View {
    var fade: CGFloat = 0.55

    var body: some View {
        ZStack {
            if let photo = UIImage(named: "Stadium") {
                Image(uiImage: photo).resizable().scaledToFill()
            } else {
                Canvas { ctx, size in StadiumArt.draw(&ctx, size) }
            }
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: fade * 0.6),
                .init(color: Theme.background.opacity(0.8), location: fade + 0.2),
                .init(color: Theme.background, location: 1),
            ], startPoint: .top, endPoint: .bottom)
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SeededRandom {
    var state: UInt64
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 33) / Double(1 << 31)
    }
}

enum StadiumArt {
    static func draw(_ ctx: inout GraphicsContext, _ s: CGSize) {
        let w = s.width, h = s.height
        let horizon = h * 0.6
        let full = Path(CGRect(origin: .zero, size: s))

        // Night sky
        ctx.fill(full, with: .linearGradient(Gradient(colors: [Color(red: 0.07, green: 0.08, blue: 0.08), Color(red: 0.03, green: 0.035, blue: 0.035)]),
                                             startPoint: .zero, endPoint: CGPoint(x: 0, y: horizon)))

        // Stands: a curved bowl down to the pitch
        var stands = Path()
        stands.move(to: CGPoint(x: -10, y: h * 0.2))
        stands.addQuadCurve(to: CGPoint(x: w + 10, y: h * 0.2), control: CGPoint(x: w / 2, y: h * 0.02))
        stands.addLine(to: CGPoint(x: w + 10, y: horizon))
        stands.addLine(to: CGPoint(x: -10, y: horizon))
        stands.closeSubpath()
        ctx.fill(stands, with: .linearGradient(Gradient(colors: [Color(red: 0.16, green: 0.15, blue: 0.13), Color(red: 0.06, green: 0.06, blue: 0.06)]),
                                               startPoint: CGPoint(x: 0, y: h * 0.1), endPoint: CGPoint(x: 0, y: horizon)))

        // Crowd: thousands of specks in a few colours
        ctx.drawLayer { layer in
            layer.clip(to: stands)
            var rng = SeededRandom(state: 42)
            let colors: [Color] = [Color(white: 0.85), Color(red: 0.95, green: 0.8, blue: 0.6), Color(white: 0.45), Theme.accent, Color(red: 0.9, green: 0.3, blue: 0.25)]
            var paths = Array(repeating: Path(), count: colors.count * 2)
            var y = h * 0.04
            while y < horizon - 6 {
                var x = rng.next() * 4
                while x < w {
                    let pick = rng.next()
                    let c = pick < 0.35 ? 0 : pick < 0.6 ? 1 : pick < 0.9 ? 2 : pick < 0.96 ? 3 : 4
                    let bright = rng.next() < 0.3 ? 1 : 0
                    paths[c * 2 + bright].addRect(CGRect(x: x, y: y + rng.next() * 2, width: 1.4, height: 1.6))
                    x += 2.2 + rng.next() * 2.4
                }
                y += 3
            }
            for (i, path) in paths.enumerated() {
                layer.fill(path, with: .color(colors[i / 2].opacity(i % 2 == 1 ? 0.32 : 0.1)))
            }
        }

        // Advertising boards along the bottom of the stands
        ctx.fill(Path(CGRect(x: 0, y: horizon - 9, width: w, height: 9)), with: .color(Color(red: 0.05, green: 0.06, blue: 0.05)))
        ctx.fill(Path(CGRect(x: 0, y: horizon - 7, width: w, height: 3)), with: .color(Theme.accent.opacity(0.35)))

        // Pitch with mowed stripes running to a vanishing point
        let vanish = CGPoint(x: w / 2, y: horizon - h * 0.9)
        let bottom = h * 1.05
        let stripe = w / 5
        for i in -8...8 {
            let x0 = w / 2 + CGFloat(i) * stripe - stripe / 2, x1 = x0 + stripe
            func atHorizon(_ x: CGFloat) -> CGFloat { vanish.x + (x - vanish.x) * (horizon - vanish.y) / (bottom - vanish.y) }
            var band = Path()
            band.move(to: CGPoint(x: atHorizon(x0), y: horizon))
            band.addLine(to: CGPoint(x: atHorizon(x1), y: horizon))
            band.addLine(to: CGPoint(x: x1, y: bottom))
            band.addLine(to: CGPoint(x: x0, y: bottom))
            band.closeSubpath()
            let even = i % 2 == 0
            ctx.fill(band, with: .color(even ? Color(red: 0.12, green: 0.3, blue: 0.13) : Color(red: 0.15, green: 0.36, blue: 0.16)))
        }

        // Goal on the horizon
        let gw = w * 0.36, gh = h * 0.12
        let goal = CGRect(x: (w - gw) / 2, y: horizon - gh + 4, width: gw, height: gh)
        var net = Path()
        var nx = goal.minX
        while nx <= goal.maxX { net.move(to: CGPoint(x: nx, y: goal.minY)); net.addLine(to: CGPoint(x: nx, y: goal.maxY)); nx += 6 }
        var ny = goal.minY
        while ny <= goal.maxY { net.move(to: CGPoint(x: goal.minX, y: ny)); net.addLine(to: CGPoint(x: goal.maxX, y: ny)); ny += 6 }
        ctx.stroke(net, with: .color(.white.opacity(0.12)), lineWidth: 0.6)
        var frame = Path()
        frame.move(to: CGPoint(x: goal.minX, y: goal.maxY))
        frame.addLine(to: CGPoint(x: goal.minX, y: goal.minY))
        frame.addLine(to: CGPoint(x: goal.maxX, y: goal.minY))
        frame.addLine(to: CGPoint(x: goal.maxX, y: goal.maxY))
        ctx.stroke(frame, with: .color(.white.opacity(0.85)), lineWidth: 3)

        // Pitch markings: six-yard box and penalty arc
        var lines = Path()
        lines.addRect(CGRect(x: w * 0.2, y: horizon + 2, width: w * 0.6, height: h * 0.07))
        lines.addRect(CGRect(x: w * 0.02, y: horizon + 2, width: w * 0.96, height: h * 0.2))
        lines.addEllipse(in: CGRect(x: w * 0.3, y: horizon + h * 0.14, width: w * 0.4, height: h * 0.12))
        ctx.stroke(lines, with: .color(.white.opacity(0.22)), lineWidth: 1.4)

        // Floodlights: a big warm glow, two lamps and soft beams
        ctx.blendMode = .plusLighter
        ctx.fill(full, with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.95, blue: 0.82).opacity(0.28), .clear]),
                                             center: CGPoint(x: w / 2, y: -h * 0.05), startRadius: 0, endRadius: w * 0.75))
        for lamp in [CGPoint(x: w * 0.1, y: h * 0.07), CGPoint(x: w * 0.9, y: h * 0.07)] {
            ctx.fill(full, with: .radialGradient(Gradient(colors: [.white.opacity(0.9), Color(red: 1, green: 0.9, blue: 0.7).opacity(0.25), .clear]),
                                                 center: lamp, startRadius: 0, endRadius: 55))
            var beam = Path()
            beam.move(to: lamp)
            beam.addLine(to: CGPoint(x: w / 2 - w * 0.35, y: h))
            beam.addLine(to: CGPoint(x: w / 2 + w * 0.35, y: h))
            beam.closeSubpath()
            ctx.fill(beam, with: .linearGradient(Gradient(colors: [.white.opacity(0.05), .clear]), startPoint: lamp, endPoint: CGPoint(x: w / 2, y: h)))
        }
        ctx.fill(full, with: .radialGradient(Gradient(colors: [Theme.accent.opacity(0.12), .clear]),
                                             center: CGPoint(x: w / 2, y: horizon + h * 0.15), startRadius: 0, endRadius: w * 0.5))
    }
}
