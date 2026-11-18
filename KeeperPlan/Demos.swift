import SwiftUI

// One stick figure, posed by joint angles and animated between key poses.
// Every drill uses the same figure so the demos look consistent.
//
// Angles are in degrees, measured from "straight down". Positive swings
// towards the way the figure faces (to the right). 180 points straight up.
// The scene is a 100 x 100 square with the floor at y = 88.

enum Ball {
    case none
    case hands
    case leftHand
    case at(Double, Double)
}

struct Pose {
    var x = 50.0
    /// Height off the floor, for jumps.
    var lift = 0.0
    /// Lean of the body from upright. 90 is lying flat.
    var torso = 0.0
    var lT = 0.0, lS = 0.0      // near leg: thigh, shin
    var rT = 0.0, rS = 0.0      // far leg: thigh, shin
    var laU = 6.0, laF = 14.0   // near arm: upper, forearm
    var raU = 4.0, raF = 10.0   // far arm: upper, forearm
    /// 1 faces right, -1 faces left. Values in between look like a turn.
    var face = 1.0
    var ball: Ball = .none
    /// Opens the knees outward, in degrees, as in a squat.
    var splay = 0.0
    /// Brings the hands to the middle, for holding one thing with both.
    var handsTogether = false

    func mixed(with o: Pose, _ t: Double) -> Pose {
        func m(_ a: Double, _ b: Double) -> Double { a + (b - a) * t }
        return Pose(x: m(x, o.x), lift: m(lift, o.lift), torso: m(torso, o.torso),
                    lT: m(lT, o.lT), lS: m(lS, o.lS), rT: m(rT, o.rT), rS: m(rS, o.rS),
                    laU: m(laU, o.laU), laF: m(laF, o.laF), raU: m(raU, o.raU), raF: m(raF, o.raF),
                    face: m(face, o.face), ball: .none, splay: m(splay, o.splay),
                    handsTogether: t < 0.5 ? handsTogether : o.handsTogether)
    }
}

enum Prop {
    case wall, ladder, line, mattress, bench
    case dumbbells, dumbbellNear
}

struct Demo {
    var poses: [Pose]
    /// Seconds for one full loop.
    var period: Double
    var props: [Prop] = []
    /// True when the figure faces the viewer and moves side to side.
    var frontal = false
}

struct Skeleton {
    var hip = CGPoint.zero, shoulder = CGPoint.zero, head = CGPoint.zero
    var lKnee = CGPoint.zero, lFoot = CGPoint.zero, rKnee = CGPoint.zero, rFoot = CGPoint.zero
    var lElbow = CGPoint.zero, lHand = CGPoint.zero, rElbow = CGPoint.zero, rHand = CGPoint.zero

    static let floor = 88.0
    static let headRadius = 5.5

    init(_ p: Pose) {
        func off(_ from: CGPoint, _ length: Double, _ degrees: Double) -> CGPoint {
            let r = degrees * .pi / 180
            return CGPoint(x: from.x + p.face * length * sin(r), y: from.y + length * cos(r))
        }
        hip = CGPoint(x: p.x, y: 0)
        shoulder = off(hip, 21, 180 - p.torso)
        head = off(shoulder, 8, 180 - p.torso)
        lKnee = off(hip, 16, p.lT); lFoot = off(lKnee, 16, p.lS)
        rKnee = off(hip, 16, p.rT); rFoot = off(rKnee, 16, p.rS)
        lElbow = off(shoulder, 11, p.laU); lHand = off(lElbow, 11, p.laF)
        rElbow = off(shoulder, 11, p.raU); rHand = off(rElbow, 11, p.raF)

        // Drop the figure so its lowest point rests on the floor, then lift for jumps.
        let lowest = [hip.y, shoulder.y, head.y + Self.headRadius, lKnee.y, lFoot.y, rKnee.y, rFoot.y, lHand.y, rHand.y].max() ?? 0
        let shift = Self.floor - lowest - p.lift
        hip.y += shift; shoulder.y += shift; head.y += shift
        lKnee.y += shift; lFoot.y += shift; rKnee.y += shift; rFoot.y += shift
        lElbow.y += shift; lHand.y += shift; rElbow.y += shift; rHand.y += shift
    }

    func ballPoint(_ ball: Ball) -> CGPoint? {
        switch ball {
        case .none: return nil
        case .hands: return CGPoint(x: (lHand.x + rHand.x) / 2, y: (lHand.y + rHand.y) / 2)
        case .leftHand: return lHand
        case .at(let x, let y): return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - The demos

enum Demos {
    #if DEBUG
    static var ids: [String] { all.keys.sorted() }
    #endif

    static func forDrill(_ id: String) -> Demo {
        var demo = all[id] ?? Demo(poses: [Pose(), ready(50)], period: 2)
        demo.period *= 1.6   // slow enough to follow
        return demo
    }

    /// Facing the viewer, feet apart by `spread`, hands out in the keeper's set position.
    private static func front(_ x: Double, lift: Double = 0, spread: Double) -> Pose {
        Pose(x: x, lift: lift, lT: -spread, lS: -spread / 4, rT: spread, rS: spread / 4,
             laU: -30, laF: -80, raU: 30, raF: 80)
    }

    /// Side-on athletic stance, knees bent, hands in front.
    private static func ready(_ x: Double, ball: Ball = .none) -> Pose {
        Pose(x: x, torso: 18, lT: 35, lS: -25, rT: 18, rS: -30, laU: 50, laF: 95, raU: 45, raF: 90, ball: ball, splay: 10)
    }

    private static let lying = Pose(x: 62, torso: 85, lT: -80, lS: -95, rT: -70, rS: -100,
                                    laU: 95, laF: 95, raU: 100, raF: 92, ball: .hands)

    private static func catching(_ ball: Ball) -> Pose {
        Pose(x: 36, torso: 8, lT: 12, lS: -10, rT: -8, rS: -6, laU: 50, laF: 95, raU: 45, raF: 90, ball: ball)
    }

    private static func throwing(_ ball: Ball) -> Pose {
        Pose(x: 36, torso: 10, lT: 12, lS: -10, rT: -8, rS: -6, laU: 75, laF: 85, raU: 70, raF: 82, ball: ball)
    }

    private static let wallCatch = Demo(poses: [catching(.hands), throwing(.at(91, 44))], period: 1.6, props: [.wall])

    private static let all: [String: Demo] = [
        // Warm-up
        "w1": Demo(poses: [
            Pose(lift: 1, lT: 72, lS: -8, laU: -35, laF: 30, raU: 40, raF: 100),
            Pose(lift: 1, rT: 72, rS: -8, laU: 40, laF: 100, raU: -35, raF: 30),
            Pose(lift: 1, lT: 5, lS: -110, laU: 35, laF: 95, raU: -30, raF: 25),
            Pose(lift: 1, rT: 5, rS: -110, laU: -30, laF: 25, raU: 35, raF: 95),
        ], period: 1.6),
        "w2": Demo(poses: [
            Pose(torso: -5, lT: 55, lS: 50, laU: -40, laF: -30, raU: 40, raF: 50),
            Pose(torso: 8, lT: -35, lS: -45, laU: 40, laF: 50, raU: -30, raF: -20),
        ], period: 1.5),
        "w3": Demo(poses: [
            Pose(),
            Pose(torso: 30, lT: 80, lS: -28, rT: 75, rS: -30, laU: 70, laF: 80, raU: 70, raF: 80, splay: 22),
            Pose(),
            Pose(torso: 5, lT: 65, lS: -5, rT: -12, rS: -68, laU: 80, laF: 85, raU: 75, raF: 80),
        ], period: 4.0),
        "w4": Demo(poses: [
            ready(50),
            Pose(x: 50, lift: 3, torso: 14, lT: 26, lS: -18, rT: 12, rS: -22, laU: 50, laF: 95, raU: 45, raF: 90, splay: 8),
        ], period: 0.45),

        // Day A
        "a1": Demo(poses: [
            Pose(lift: 1, lT: 55, lS: -15, laU: -30, laF: 30, raU: 35, raF: 100),
            Pose(lift: 1, rT: 55, rS: -15, laU: 35, laF: 100, raU: -30, raF: 30),
        ], period: 0.6, props: [.ladder]),
        "a2": Demo(poses: [
            front(50, spread: 4), front(50, lift: 3, spread: 14), front(50, spread: 24), front(50, lift: 3, spread: 14),
        ], period: 1.0, props: [.ladder], frontal: true),
        "a3": Demo(poses: [
            front(32, spread: 24), front(50, spread: 8), front(68, spread: 24), front(50, spread: 8),
        ], period: 2.6, frontal: true),
        "a4": Demo(poses: [
            front(28, spread: 22), front(36, spread: 8), front(44, spread: 22), lying, lying, front(44, spread: 22),
        ], period: 3.6, props: [.mattress], frontal: true),
        "a5": Demo(poses: [
            ready(56),
            Pose(x: 44, torso: 14, lT: 25, lS: -10, rT: -40, rS: -15, laU: 50, laF: 95, raU: 45, raF: 90),
        ], period: 1.6),
        "a6": Demo(poses: [
            front(43, spread: 4), front(50, lift: 7, spread: 4), front(57, spread: 4), front(50, lift: 7, spread: 4),
        ], period: 0.9, props: [.line], frontal: true),

        // Day B
        "b1": wallCatch,
        "x-catches": wallCatch,
        "x-hands10": wallCatch,
        "b1w": Demo(poses: [
            Pose(x: 36, torso: 8, lT: 12, lS: -10, rT: -8, rS: -6, laU: 50, laF: 95, raU: 5, raF: 12, ball: .leftHand),
            Pose(x: 36, torso: 10, lT: 12, lS: -10, rT: -8, rS: -6, laU: 75, laF: 85, raU: 5, raF: 12, ball: .at(91, 44)),
        ], period: 1.6, props: [.wall]),
        "b2": Demo(poses: [
            throwing(.at(91, 42)),
            Pose(x: 36, lift: 6, lT: 6, rT: -6, laU: 50, laF: 95, raU: 45, raF: 90, ball: .at(72, 40)),
            ready(36, ball: .hands),
            ready(36, ball: .hands),
        ], period: 2.4, props: [.wall]),
        "b3": Demo(poses: [
            Pose(x: 40, laU: 150, laF: 170, raU: 10, raF: 20, face: -1, ball: .leftHand),
            Pose(x: 40, laU: 170, laF: 176, raU: 10, raF: 20, face: -1, ball: .at(91, 40)),
            Pose(x: 40, torso: 10, lT: 12, lS: -10, rT: -8, rS: -6, laU: 50, laF: 95, raU: 45, raF: 90, face: 1, ball: .at(72, 86)),
            Pose(x: 40, torso: 10, lT: 12, lS: -10, rT: -8, rS: -6, laU: 50, laF: 95, raU: 45, raF: 90, face: 1, ball: .hands),
        ], period: 2.8, props: [.wall]),
        "b4": Demo(poses: [
            Pose(x: 40, torso: 40, lT: 50, lS: -30, rT: 30, rS: -35, laU: 50, laF: 70, raU: 45, raF: 65, ball: .hands),
            Pose(x: 40, torso: 40, lT: 50, lS: -30, rT: 30, rS: -35, laU: 50, laF: 70, raU: 45, raF: 65, ball: .at(90, 86)),
            Pose(x: 42, torso: 52, lT: 60, lS: -30, rT: 35, rS: -38, laU: 30, laF: 45, raU: 25, raF: 40, ball: .at(72, 64)),
            Pose(x: 40, torso: 40, lT: 50, lS: -30, rT: 30, rS: -35, laU: 50, laF: 70, raU: 45, raF: 65, ball: .hands),
        ], period: 2.2, props: [.wall]),
        "b5": Demo(poses: [
            Pose(x: 36, torso: 5, lT: 10, lS: -8, rT: -8, rS: -6, laU: 75, laF: 85, raU: 30, raF: 100, ball: .at(91, 40)),
            Pose(x: 36, torso: 5, lT: 10, lS: -8, rT: -8, rS: -6, laU: 30, laF: 100, raU: 75, raF: 85, ball: .hands),
        ], period: 1.2, props: [.wall]),
        "b6": Demo(poses: [
            ready(40, ball: .at(91, 87)),
            Pose(x: 42, torso: 35, lT: 80, lS: -5, rT: 10, rS: -88, laU: 20, laF: 40, raU: 15, raF: 35, ball: .hands),
            Pose(x: 42, torso: 35, lT: 80, lS: -5, rT: 10, rS: -88, laU: 20, laF: 40, raU: 15, raF: 35, ball: .hands),
            ready(40, ball: .hands),
        ], period: 2.8, props: [.wall]),
        "b7": Demo(poses: [
            Pose(x: 40, lT: 0, lS: -89, rT: 5, rS: -89, laU: 50, laF: 95, raU: 45, raF: 90, ball: .hands),
            Pose(x: 40, lT: 0, lS: -89, rT: 5, rS: -89, laU: 50, laF: 95, raU: 45, raF: 90, ball: .hands),
            lying, lying,
        ], period: 3.0, props: [.mattress]),

        // Day C: explosive
        "c1": Demo(poses: [
            Pose(torso: 35, lT: 75, lS: -30, rT: 70, rS: -32, laU: -35, laF: -20, raU: -30, raF: -15, splay: 18),
            Pose(lift: 9, lT: 3, lS: 5, rT: -3, rS: 3, laU: 170, laF: 175, raU: 165, raF: 172),
        ], period: 1.4),
        "c2": Demo(poses: [
            Pose(x: 66, torso: 12, lT: -15, lS: -75, rT: 8, rS: -4, laU: 40, laF: 70, raU: -30, raF: -10),
            front(50, lift: 7, spread: 18),
            Pose(x: 34, torso: -12, lT: -8, lS: 4, rT: 15, rS: 75, laU: 30, laF: 10, raU: -40, raF: -70),
            front(50, lift: 7, spread: 18),
        ], period: 2.0, frontal: true),
        "c3": Demo(poses: [
            Pose(torso: 5, lT: 65, lS: -5, rT: -12, rS: -68, laU: -30, laF: -10, raU: 35, raF: 80),
            Pose(lift: 9, lT: 15, rT: -15, rS: -10),
            Pose(torso: 5, lT: -12, lS: -68, rT: 65, rS: -5, laU: 35, laF: 80, raU: -30, raF: -10),
            Pose(lift: 9, lT: -15, lS: -10, rT: 15),
        ], period: 1.8),
        "c4": Demo(poses: [
            Pose(torso: 15, lT: 35, lS: -25, rT: 30, rS: -28, laU: -20, laF: 0, raU: -15, raF: 5),
            Pose(lift: 16, torso: 10, lT: 105, lS: -10, rT: 100, rS: -12, laU: 60, laF: 90, raU: 55, raF: 85),
        ], period: 1.3),

        // Day C: strength
        "s1": Demo(poses: [
            Pose(laU: 20, laF: 150, raU: 15, raF: 145, handsTogether: true),
            Pose(torso: 28, lT: 80, lS: -28, rT: 75, rS: -30, laU: 45, laF: 165, raU: 40, raF: 160, splay: 24, handsTogether: true),
        ], period: 2.4, props: [.dumbbells]),
        "s2": Demo(poses: [
            Pose(x: 52, torso: 5, lT: 15, lS: -5, rT: -25, rS: -75, laU: 0, laF: 3, raU: 0, raF: 3),
            Pose(x: 52, torso: 12, lT: 70, lS: -10, rT: -40, rS: -100, laU: 0, laF: 3, raU: 0, raF: 3),
        ], period: 2.4, props: [.bench, .dumbbells]),
        "s3": Demo(poses: [
            Pose(lT: 3, lS: -3, rT: -5, rS: -5, laU: 0, laF: 0, raU: 0, raF: 0),
            Pose(torso: 78, lT: 6, lS: -8, rT: -78, rS: -80, laU: 0, laF: 0, raU: 0, raF: 0),
        ], period: 2.6, props: [.dumbbells]),
        "s4": Demo(poses: [
            Pose(torso: 65, lT: -65, lS: -65, rT: -65, rS: -65, laU: 0, laF: 0, raU: 0, raF: 0),
            Pose(torso: 80, lT: -80, lS: -80, rT: -80, rS: -80, laU: -70, laF: 60, raU: -70, raF: 60),
        ], period: 1.8),
        "s5": Demo(poses: [
            Pose(torso: 65, lT: 22, lS: -15, rT: 12, rS: -20, laU: 0, laF: 0, raU: 25, raF: 5),
            Pose(torso: 65, lT: 22, lS: -15, rT: 12, rS: -20, laU: -55, laF: 15, raU: 25, raF: 5),
        ], period: 1.6, props: [.dumbbellNear]),
        "s6": Demo(poses: [
            Pose(torso: 65, lT: -65, lS: -65, rT: -65, rS: -65, laU: 180, laF: 180, raU: 0, raF: 0),
            Pose(torso: 63, lT: -66, lS: -66, rT: -66, rS: -66, laU: 176, laF: 180, raU: 0, raF: 0),
        ], period: 2.4, frontal: true),
        "s7": Demo(poses: [
            Pose(x: 45, torso: 90, lT: -180, lS: -90, rT: -100, rS: -95, laU: 100, laF: 100, raU: 180, raF: 180),
            Pose(x: 45, torso: 90, lT: -100, lS: -95, rT: -180, rS: -90, laU: 180, laF: 180, raU: 100, raF: 100),
        ], period: 2.8),

        // Drill library: diving, distribution, crosses, 1v1s
        "dive": Demo(poses: [
            front(40, spread: 22),
            Pose(x: 58, lift: 10, torso: 75, lT: -55, lS: -60, rT: -40, rS: -50,
                 laU: 110, laF: 100, raU: 115, raF: 105, ball: .hands),
            lying, lying,
            front(40, spread: 22),
        ], period: 3.2, frontal: true),
        "throw": Demo(poses: [
            Pose(x: 40, torso: -8, lT: 22, lS: 0, rT: -22, rS: -15, laU: -120, laF: -150, raU: 100, raF: 95, ball: .leftHand),
            Pose(x: 44, torso: 12, lT: 25, lS: -5, rT: -25, rS: -30, laU: 165, laF: 140, raU: 30, raF: 50, ball: .at(62, 20)),
            Pose(x: 46, torso: 28, lT: 30, lS: -10, rT: -30, rS: -50, laU: 60, laF: 50, raU: -10, raF: 0, ball: .at(92, 30)),
        ], period: 2.0),
        "kick": Demo(poses: [
            Pose(x: 40, torso: -5, lT: -45, lS: -95, rT: 8, rS: 0, laU: -40, laF: -20, raU: 60, raF: 70, ball: .at(55, 86)),
            Pose(x: 42, torso: -10, lT: 35, lS: 20, rT: 5, rS: 0, laU: -50, laF: -30, raU: 70, raF: 80, ball: .at(57, 84)),
            Pose(x: 44, torso: -18, lT: 95, lS: 95, rT: 5, rS: 0, laU: -60, laF: -40, raU: 80, raF: 90, ball: .at(92, 45)),
        ], period: 1.8),
        "highcatch": Demo(poses: [
            ready(40),
            Pose(x: 46, lift: 12, lT: 95, lS: -10, rT: -5, rS: -10, laU: 170, laF: 172, raU: 165, raF: 170,
                 ball: .hands, handsTogether: true),
            Pose(x: 50, torso: 5, lT: 10, lS: -10, rT: -8, rS: -6, laU: 40, laF: 120, raU: 35, raF: 115,
                 ball: .hands, handsTogether: true),
        ], period: 2.2),
        "roll": Demo(poses: [
            ready(36, ball: .hands),
            Pose(x: 40, torso: 50, lT: 80, lS: -5, rT: -30, rS: -95, laU: -30, laF: -20, raU: 40, raF: 40, ball: .leftHand),
            Pose(x: 42, torso: 55, lT: 80, lS: -5, rT: -30, rS: -95, laU: 50, laF: 60, raU: 40, raF: 40, ball: .at(70, 86)),
            Pose(x: 42, torso: 55, lT: 80, lS: -5, rT: -30, rS: -95, laU: 50, laF: 60, raU: 40, raF: 40, ball: .at(92, 86)),
        ], period: 2.4),
        "block": Demo(poses: [
            front(46, spread: 10),
            Pose(x: 50, lT: -40, lS: -55, rT: 40, rS: 55, laU: -55, laF: -45, raU: 55, raF: 45),
            Pose(x: 50, lT: -40, lS: -55, rT: 40, rS: 55, laU: -55, laF: -45, raU: 55, raF: 45),
        ], period: 2.2, frontal: true),
    ]
}

#if DEBUG
/// Every key pose of every demo, for checking them by eye.
/// Opened with the launch arguments "-gallery N", five demos per page.
struct DemoGallery: View {
    let page: Int

    var body: some View {
        let cells = Demos.ids.flatMap { id in Demos.forDrill(id).poses.indices.map { (id, $0) } }
        let shown = Array(cells.dropFirst(page * 12).prefix(12))
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)], spacing: 4) {
            ForEach(shown.indices, id: \.self) { i in
                DemoFigure(demo: Demos.forDrill(shown[i].0), fixed: shown[i].1, height: 128)
                    .overlay(alignment: .topLeading) {
                        Text("\(shown[i].0) \(shown[i].1)").font(.caption2).padding(4)
                    }
            }
        }
        .padding(.top, 60)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Theme.background.ignoresSafeArea())
    }
}
#endif
