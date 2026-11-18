import SwiftUI

/// Animated top-down drill demo on a 100 x 64 tactics board.
struct TacticsBoard: View {
    let script: BoardScript
    var keeperIsYou = false
    @Binding var caption: String
    @Binding var playing: Bool
    var speed: Double = 1
    /// Change it to start the animation over.
    var restartToken = 0

    @State private var clock = BoardClock()

    var body: some View {
        TimelineView(.animation(paused: !playing)) { context in
            let t = clock.time(at: context.date, playing: playing, speed: speed)
            let frame = BoardTimeline.shared(script).sample(t)
            Canvas { ctx, size in
                draw(ctx: ctx, size: size, frame: frame)
            }
            .onChange(of: frame.caption) { _, c in caption = c }
            .onAppear { caption = frame.caption }
        }
        .aspectRatio(100 / 64, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityLabel("Drill animation")
        .onChange(of: restartToken) { _, _ in clock.reset() }
    }

    // MARK: Drawing

    private static let grass1 = Color(red: 0.14, green: 0.38, blue: 0.25)
    private static let grass2 = Color(red: 0.13, green: 0.35, blue: 0.23)
    private static let cone = Color(red: 0.94, green: 0.48, blue: 0.23)

    private func draw(ctx: GraphicsContext, size: CGSize, frame: BoardFrame) {
        let k = size.width / 100
        func p(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * k, y: y * k) }
        // grass stripes
        for i in 0..<10 {
            ctx.fill(Path(CGRect(x: Double(i) * 10 * k, y: 0, width: 10 * k, height: 64 * k)), with: .color(i.isMultiple(of: 2) ? Self.grass1 : Self.grass2))
        }
        let chalk = GraphicsContext.Shading.color(.white.opacity(0.4))
        ctx.stroke(Path(CGRect(x: 1.5 * k, y: 1.5 * k, width: 97 * k, height: 61 * k)), with: chalk, lineWidth: 0.4 * k)

        let s = script.setup
        if let g = s.goal {
            let right = g.x > 50
            let box = right ? CGRect(x: (g.x - 16) * k, y: (g.y - 20) * k, width: 16 * k, height: 40 * k)
                : CGRect(x: g.x * k, y: (g.y - 20) * k, width: 16 * k, height: 40 * k)
            let six = right ? CGRect(x: (g.x - 6) * k, y: (g.y - 10) * k, width: 6 * k, height: 20 * k)
                : CGRect(x: g.x * k, y: (g.y - 10) * k, width: 6 * k, height: 20 * k)
            ctx.stroke(Path(box), with: chalk, lineWidth: 0.4 * k)
            ctx.stroke(Path(six), with: chalk, lineWidth: 0.4 * k)
            let mouth = CGRect(x: (right ? g.x : g.x - 2.5) * k, y: (g.y - g.w / 2) * k, width: 2.5 * k, height: g.w * k)
            ctx.fill(Path(mouth), with: .color(.white.opacity(0.18)))
            ctx.stroke(Path(mouth), with: .color(.white), lineWidth: 0.6 * k)
        }
        if let w = s.wall {
            var path = Path(); path.move(to: p(w.0, w.1)); path.addLine(to: p(w.2, w.3))
            ctx.stroke(path, with: .color(Color(white: 0.78)), style: StrokeStyle(lineWidth: 2.4 * k, lineCap: .square))
        }
        for g in s.gates {
            var path = Path(); path.move(to: p(g.0, g.1)); path.addLine(to: p(g.2, g.3))
            ctx.stroke(path, with: .color(.white.opacity(0.55)), style: StrokeStyle(lineWidth: 0.35 * k, dash: [k, k]))
            drawCone(ctx, p(g.0, g.1), k); drawCone(ctx, p(g.2, g.3), k)
        }
        for c in s.cones { drawCone(ctx, p(c.0, c.1), k) }

        // your path
        let you = frame.youKey(keeperIsYou: keeperIsYou)
        let trail = BoardTimeline.shared(script).path(of: you)
        if trail.count > 1 {
            var path = Path()
            path.addLines(trail.map { p($0.x, $0.y) })
            ctx.stroke(path, with: .color(.white.opacity(0.3)), style: StrokeStyle(lineWidth: 0.4 * k, dash: [1.2 * k, k]))
        }

        // look wedge
        if let look = frame.look, let me = frame.actors[you] {
            let r = 14.0, half = 22.0
            var wedge = Path()
            wedge.move(to: p(me.x, me.y))
            wedge.addArc(center: p(me.x, me.y), radius: r * k, startAngle: .degrees(look - half), endAngle: .degrees(look + half), clockwise: false)
            wedge.closeSubpath()
            ctx.fill(wedge, with: .color(.white.opacity(0.2)))
        }

        for key in ["d", "m", "k", "p"] {
            guard let pt = frame.actors[key] else { continue }
            let (fill, ink): (Color, Color) = switch key {
            case "p": (Theme.accent, .black)
            case "m": (Color(red: 0.18, green: 0.49, blue: 0.33), .white)
            case "d": (Color(white: 0.1), .white)
            default: (Color(red: 0.89, green: 0.7, blue: 0.24), .black)
            }
            let label = key == you ? "YOU" : ["m": "M", "d": "D", "k": "GK", "p": "YOU"][key]!
            let rect = CGRect(x: (pt.x - 2.6) * k, y: (pt.y - 2.6) * k, width: 5.2 * k, height: 5.2 * k)
            ctx.fill(Path(ellipseIn: rect), with: .color(fill))
            ctx.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.85)), lineWidth: 0.45 * k)
            ctx.draw(Text(label).font(.system(size: (label.count > 2 ? 1.7 : 2.1) * k, weight: .heavy)).foregroundStyle(ink), at: p(pt.x, pt.y))
        }
        if let b = frame.ball {
            let rect = CGRect(x: (b.x - 1.05) * k, y: (b.y - 1.05) * k, width: 2.1 * k, height: 2.1 * k)
            ctx.fill(Path(ellipseIn: rect), with: .color(.white))
            ctx.stroke(Path(ellipseIn: rect), with: .color(.black), lineWidth: 0.3 * k)
        }
        if let cue = frame.cue {
            let colors: [String: Color] = ["RED": .red, "GREEN": .green, "BLUE": .blue, "YELLOW": .yellow]
            let rect = CGRect(x: 4 * k, y: 4 * k, width: 14 * k, height: 10 * k)
            ctx.fill(Path(roundedRect: rect, cornerRadius: 1.2 * k), with: .color(colors[cue] ?? .white))
            ctx.draw(Text(cue).font(.system(size: (cue.count > 1 ? 3 : 5.5) * k, weight: .black)).foregroundStyle(colors[cue] == nil ? .black : .white), at: CGPoint(x: rect.midX, y: rect.midY))
        }
    }

    private func drawCone(_ ctx: GraphicsContext, _ c: CGPoint, _ k: Double) {
        var tri = Path()
        tri.move(to: CGPoint(x: c.x - 1.3 * k, y: c.y + 1 * k))
        tri.addLine(to: CGPoint(x: c.x, y: c.y - 1.4 * k))
        tri.addLine(to: CGPoint(x: c.x + 1.3 * k, y: c.y + 1 * k))
        tri.closeSubpath()
        ctx.fill(tri, with: .color(Self.cone))
    }
}

/// Keeps animation time across pauses and speed changes.
final class BoardClock {
    private var origin = Date()
    private var frozen: Double?
    private var speed = 1.0

    private func live(_ date: Date) -> Double { max(0, date.timeIntervalSince(origin) * speed) }

    func time(at date: Date, playing: Bool, speed newSpeed: Double) -> Double {
        if !playing {
            if frozen == nil { frozen = live(date) }
            return frozen ?? 0
        }
        if let f = frozen {
            speed = newSpeed
            origin = date.addingTimeInterval(-f / speed)
            frozen = nil
        } else if newSpeed != speed {
            let now = live(date)
            speed = newSpeed
            origin = date.addingTimeInterval(-now / speed)
        }
        return live(date)
    }

    func reset() {
        origin = Date()
        if frozen != nil { frozen = 0 }
    }
}

struct BoardFrame {
    var actors: [String: (x: Double, y: Double)] = [:]
    var ball: (x: Double, y: Double)?
    var caption = ""
    var cue: String?
    var look: Double?

    func youKey(keeperIsYou: Bool) -> String { keeperIsYou && actors["p"] == nil ? "k" : "p" }
}

/// Precomputed keyframes for a script, cached by drill so frames are cheap to sample.
final class BoardTimeline {
    private struct Key {
        let t: Double
        var actors: [String: (x: Double, y: Double)]
        var ball: BoardMark?
        let caption: String
        let cue: String?
        let look: Double?
    }

    private var keys: [Key] = []
    private(set) var total = 0.0
    private let hold = 1.1
    private static var cache: [String: BoardTimeline] = [:]

    static func shared(_ script: BoardScript) -> BoardTimeline {
        let id = script.steps.map { "\($0.dur)\($0.caption ?? "")" }.joined() + "\(script.steps.count)"
        if let t = cache[id] { return t }
        let t = BoardTimeline(script)
        cache[id] = t
        return t
    }

    private init(_ script: BoardScript) {
        var t = 0.0
        var actors: [String: (x: Double, y: Double)] = [:]
        var ball: BoardMark?
        var caption = ""
        for step in script.steps {
            t += step.dur
            for m in step.marks {
                if m.key == "b" { ball = m } else { actors[m.key] = (m.x, m.y) }
            }
            if let c = step.caption { caption = c }
            keys.append(Key(t: t, actors: actors, ball: ball, caption: caption, cue: step.cue, look: step.look))
        }
        total = t
    }

    func path(of key: String) -> [(x: Double, y: Double)] { keys.compactMap { $0.actors[key] } }

    private static func ease(_ t: Double) -> Double { t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2 }

    func sample(_ time: Double) -> BoardFrame {
        guard !keys.isEmpty else { return BoardFrame() }
        let t = time.truncatingRemainder(dividingBy: total + hold)
        let i = keys.firstIndex { $0.t >= t } ?? keys.count - 1
        let prev = keys[max(0, i - 1)], cur = keys[i]
        let span = cur.t - (i > 0 ? prev.t : 0)
        let e = span > 0 ? Self.ease(min(1, max(0, (t - (i > 0 ? prev.t : 0)) / span))) : 1

        var f = BoardFrame()
        for (k, b) in cur.actors {
            let a = prev.actors[k] ?? b
            f.actors[k] = (a.x + (b.x - a.x) * e, a.y + (b.y - a.y) * e)
        }
        f.caption = cur.caption
        f.cue = cur.cue
        f.look = cur.look

        func resolve(_ m: BoardMark?, using actors: [String: (x: Double, y: Double)], from: [String: (x: Double, y: Double)]) -> (x: Double, y: Double)? {
            guard let m else { return nil }
            guard let a = m.attach else { return (m.x, m.y) }
            guard let pos = actors[a] else { return nil }
            let before = from[a] ?? pos
            var dx = pos.x - before.x, dy = pos.y - before.y
            let len = (dx * dx + dy * dy).squareRoot()
            if len > 0.5 { dx /= len; dy /= len } else { dx = 1; dy = 0 }
            return (pos.x + dx * 2.4, pos.y + dy * 2.4)
        }
        if let to = cur.ball {
            if let attach = to.attach, prev.ball?.attach == attach {
                f.ball = resolve(to, using: f.actors, from: prev.actors)
            } else if let a = resolve(prev.ball ?? to, using: prev.actors, from: keys[max(0, i - 2)].actors),
                      let b = resolve(to, using: cur.actors, from: prev.actors) {
                f.ball = (a.x + (b.x - a.x) * e, a.y + (b.y - a.y) * e)
            }
        }
        // keep the ball visible at a player's feet
        if var b = f.ball {
            for a in f.actors.values {
                let dx = b.x - a.x, dy = b.y - a.y, d = (dx * dx + dy * dy).squareRoot()
                if d < 2.6 {
                    let ux = d > 0.2 ? dx / d : 0.7, uy = d > 0.2 ? dy / d : 0.7
                    b = (a.x + ux * 2.9, a.y + uy * 2.9)
                }
            }
            f.ball = b
        }
        return f
    }
}

/// Tap-to-pick formation for the profile and the positions tab.
struct PitchPicker: View {
    /// Spot code → rank (1 main, 2 second, 3 third).
    var picked: [String: Int] = [:]
    var onPick: (Spot) -> Void

    var body: some View {
        GeometryReader { geo in
            let k = geo.size.width / 100
            ZStack(alignment: .topLeading) {
                Canvas { ctx, size in
                    for i in 0..<10 {
                        ctx.fill(Path(CGRect(x: Double(i) * 10 * k, y: 0, width: 10 * k, height: 64 * k)),
                                 with: .color(i.isMultiple(of: 2) ? Color(red: 0.14, green: 0.38, blue: 0.25) : Color(red: 0.13, green: 0.35, blue: 0.23)))
                    }
                    let chalk = GraphicsContext.Shading.color(.white.opacity(0.45))
                    ctx.stroke(Path(CGRect(x: 1.5 * k, y: 1.5 * k, width: 97 * k, height: 61 * k)), with: chalk, lineWidth: 1)
                    var mid = Path(); mid.move(to: CGPoint(x: 50 * k, y: 1.5 * k)); mid.addLine(to: CGPoint(x: 50 * k, y: 62.5 * k))
                    ctx.stroke(mid, with: chalk, lineWidth: 1)
                    ctx.stroke(Path(ellipseIn: CGRect(x: 42 * k, y: 24 * k, width: 16 * k, height: 16 * k)), with: chalk, lineWidth: 1)
                    ctx.stroke(Path(CGRect(x: 1.5 * k, y: 12 * k, width: 15 * k, height: 40 * k)), with: chalk, lineWidth: 1)
                    ctx.stroke(Path(CGRect(x: 83.5 * k, y: 12 * k, width: 15 * k, height: 40 * k)), with: chalk, lineWidth: 1)
                }
                Text("ATTACK →").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
                    .position(x: 92 * k, y: 5 * k)
                ForEach(Spot.all) { spot in
                    let rank = picked[spot.code]
                    Button { onPick(spot) } label: {
                        Text(spot.code)
                            .font(.system(size: max(8, 2.1 * k), weight: .heavy))
                            .foregroundStyle(rank == nil ? .white : .black)
                            .frame(width: 7.4 * k, height: 7.4 * k)
                            .background(Circle().fill(rankColor(rank)))
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                            .overlay(alignment: .topTrailing) {
                                if let rank {
                                    Text("\(rank)").font(.caption2.bold()).foregroundStyle(.white)
                                        .padding(3).background(Circle().fill(.black)).offset(x: 6, y: -6)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .position(x: spot.x * k, y: spot.y * k)
                    .accessibilityLabel(spot.label)
                }
            }
        }
        .aspectRatio(100 / 64, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func rankColor(_ rank: Int?) -> Color {
        switch rank {
        case 1: return Theme.accent
        case 2: return Color(red: 0.89, green: 0.7, blue: 0.24)
        case 3: return Color(red: 0.56, green: 0.72, blue: 0.63)
        default: return .white.opacity(0.16)
        }
    }
}
