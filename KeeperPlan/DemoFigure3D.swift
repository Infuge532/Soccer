import SwiftUI
import SceneKit

/// The 3D demo: a dark grey anatomical mannequin on black, posed every frame
/// from the key poses in Demos.swift. The camera frames each drill so the
/// figure fills the card, and sways gently so the depth is easy to read.
struct DemoFigure: View {
    let demo: Demo
    /// Shows one key pose without moving. Only the debug gallery uses this.
    var fixed: Int? = nil
    var height: CGFloat = 270

    var body: some View {
        DemoSceneView(demo: demo, fixed: fixed)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .accessibilityLabel("Animated 3D demonstration")
    }
}

private struct DemoSceneView: UIViewRepresentable {
    let demo: Demo
    let fixed: Int?

    func makeCoordinator() -> DemoRig { DemoRig(demo: demo, fixed: fixed) }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = context.coordinator.scene
        view.pointOfView = context.coordinator.cameraNode
        view.delegate = context.coordinator
        view.backgroundColor = DemoRig.backdrop
        view.antialiasingMode = .multisampling4X
        view.isUserInteractionEnabled = false
        view.rendersContinuously = fixed == nil
        view.isPlaying = fixed == nil
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        if view.bounds.height > 1 {
            context.coordinator.aspect = Float(view.bounds.width / view.bounds.height)
        }
    }
}

/// Joint order used by the rig.
private enum J: Int, CaseIterable {
    case hip, shoulder, head
    case lHip, rHip, lKnee, rKnee, lFoot, rFoot
    case lShoulder, rShoulder, lElbow, rElbow, lHand, rHand

    /// How far the body surface sits from this joint, for resting on the floor.
    var radius: Float {
        switch self {
        case .head: return 5.6
        case .hip, .shoulder: return 4.6
        case .lHip, .rHip: return 3.7
        case .lKnee, .rKnee: return 2.6
        case .lFoot, .rFoot: return 1.9
        case .lShoulder, .rShoulder: return 3.0
        case .lElbow, .rElbow: return 2.0
        case .lHand, .rHand: return 1.5
        }
    }
}

final class DemoRig: NSObject, SCNSceneRendererDelegate {
    static let backdrop = UIColor(white: 0.035, alpha: 1)

    let scene = SCNScene()
    let cameraNode = SCNNode()
    var aspect: Float = 1.5
    private let demo: Demo
    private let fixed: Int?

    private var limbs: [(node: SCNNode, from: J, to: J)] = []
    private var jointNodes: [(node: SCNNode, at: J)] = []
    private var bulges: [(node: SCNNode, from: J, to: J, along: Float)] = []
    private var trunk: [(node: SCNNode, along: Float)] = []
    private let headNode = SCNNode()
    private let neckNode = SCNNode()
    private var feet: [(node: SCNNode, knee: J, foot: J)] = []
    private var hands: [(node: SCNNode, elbow: J, hand: J)] = []
    private let ballNode = SCNNode()
    private var dumbbellNodes: [SCNNode] = []

    private var centre = SIMD3<Float>(50, 36, 0)
    private var halfSize = SIMD2<Float>(40, 40)

    // Each scene gets its own materials; sharing them between views can render black.
    private let body = DemoRig.material(UIColor(white: 0.44, alpha: 1), shine: 0.10)
    private let lime = DemoRig.material(UIColor(red: 0.74, green: 0.93, blue: 0.22, alpha: 1), shine: 0.2)
    private let grey = DemoRig.material(UIColor(white: 0.20, alpha: 1), shine: 0.05)
    private let stage = DemoRig.material(UIColor(white: 0.075, alpha: 1), shine: 0)

    init(demo: Demo, fixed: Int?) {
        self.demo = demo
        self.fixed = fixed
        super.init()
        build()
        frame()
        apply(time: 0)
    }

    private static func material(_ color: UIColor, shine: CGFloat) -> SCNMaterial {
        let m = SCNMaterial()
        m.lightingModel = .blinn
        m.diffuse.contents = color
        m.specular.contents = UIColor(white: shine, alpha: 1)
        m.shininess = 0.08
        return m
    }

    // MARK: Building the scene

    private func add(_ geometry: SCNGeometry, _ material: SCNMaterial) -> SCNNode {
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        scene.rootNode.addChildNode(node)
        return node
    }

    private func addLight(_ type: SCNLight.LightType, _ intensity: CGFloat, from: SCNVector3? = nil) {
        let node = SCNNode()
        let light = SCNLight()
        light.type = type
        light.intensity = intensity
        node.light = light
        if let from {
            node.position = from
            node.look(at: SCNVector3(50, 30, 0))
        }
        scene.rootNode.addChildNode(node)
    }

    private func addBox(_ x0: CGFloat, _ x1: CGFloat, height: CGFloat, depth: CGFloat, _ material: SCNMaterial, z: CGFloat = 0) {
        let node = add(SCNBox(width: x1 - x0, height: height, length: depth, chamferRadius: 0.6), material)
        node.position = SCNVector3(Float((x0 + x1) / 2), Float(height / 2), Float(z))
    }

    private func build() {
        scene.background.contents = Self.backdrop

        addLight(.ambient, 260)
        addLight(.directional, 950, from: SCNVector3(60, 170, 120))    // key, from above and in front
        addLight(.directional, 420, from: SCNVector3(170, 60, -90))    // rim, from behind
        addLight(.directional, 220, from: SCNVector3(-80, 40, 60))     // soft fill

        let camera = SCNCamera()
        camera.fieldOfView = 30
        camera.zNear = 1
        camera.zFar = 1200
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)

        // Limbs taper from the first joint to the second, with a muscle bulge
        // part-way along: a sphere stretched along the limb.
        let legs: [(J, J, J)] = [(.lHip, .lKnee, .lFoot), (.rHip, .rKnee, .rFoot)]
        for (hip, knee, foot) in legs {
            limbs.append((add(SCNCone(topRadius: 2.5, bottomRadius: 3.7, height: 16), body), hip, knee))
            limbs.append((add(SCNCone(topRadius: 1.7, bottomRadius: 2.5, height: 16), body), knee, foot))
            addBulge(hip, knee, along: 0.38, radius: 3.6, stretch: 1.7)
            addBulge(knee, foot, along: 0.32, radius: 2.75, stretch: 1.8)
            addJoint(hip); addJoint(knee); addJoint(foot)
            feet.append((add(SCNCapsule(capRadius: 1.75, height: 8.5), body), knee, foot))
        }
        let arms: [(J, J, J)] = [(.lShoulder, .lElbow, .lHand), (.rShoulder, .rElbow, .rHand)]
        for (shoulder, elbow, hand) in arms {
            limbs.append((add(SCNCone(topRadius: 1.9, bottomRadius: 2.6, height: 11), body), shoulder, elbow))
            limbs.append((add(SCNCone(topRadius: 1.4, bottomRadius: 1.9, height: 11), body), elbow, hand))
            addBulge(shoulder, elbow, along: 0.4, radius: 2.5, stretch: 1.6)
            addBulge(elbow, hand, along: 0.3, radius: 2.0, stretch: 1.7)
            addJoint(shoulder); addJoint(elbow); addJoint(hand)
            hands.append((add(SCNCapsule(capRadius: 1.35, height: 5.4), body), elbow, hand))
        }

        // The trunk: pelvis, waist, ribs and chest as overlapping rounded volumes.
        // Scale is (across, along the spine, front to back).
        let volumes: [(Float, SIMD3<Float>)] = [
            (0.04, SIMD3(7.4, 7.0, 5.0)),   // pelvis and glutes
            (0.36, SIMD3(6.2, 9.0, 4.5)),   // waist
            (0.68, SIMD3(7.3, 8.6, 5.0)),   // ribs
            (0.90, SIMD3(8.3, 5.6, 4.8)),   // chest and shoulders
        ]
        for (along, scale) in volumes {
            let node = add(SCNSphere(radius: 1), body)
            node.simdScale = scale
            trunk.append((node, along))
        }
        let head = SCNSphere(radius: 1)
        head.materials = [body]
        headNode.geometry = head
        headNode.simdScale = SIMD3(4.5, 5.7, 5.1)
        scene.rootNode.addChildNode(headNode)
        let neck = SCNCone(topRadius: 1.9, bottomRadius: 2.6, height: 6)
        neck.materials = [body]
        neckNode.geometry = neck
        scene.rootNode.addChildNode(neckNode)

        // The tennis ball.
        let tennis = SCNSphere(radius: 2.4)
        tennis.materials = [lime]
        ballNode.geometry = tennis
        ballNode.isHidden = true
        scene.rootNode.addChildNode(ballNode)

        // A faint round stage so the figure reads as standing on something.
        let disc = add(SCNCylinder(radius: 46, height: 0.2), stage)
        disc.position = SCNVector3(50, -0.1, 0)

        for prop in demo.props {
            switch prop {
            case .wall: addBox(93, 96, height: 62, depth: 60, grey)
            case .mattress: addBox(52, 99, height: 2.4, depth: 34, grey)
            case .bench: addBox(12, 34, height: 10, depth: 24, grey)
            case .line: addBox(49.2, 50.8, height: 0.5, depth: 50, lime)
            case .ladder:
                addBox(14, 86, height: 0.5, depth: 0.9, lime, z: 10)
                addBox(14, 86, height: 0.5, depth: 0.9, lime, z: -10)
                for x in stride(from: 14.0, through: 86.0, by: 12.0) {
                    addBox(x - 0.45, x + 0.45, height: 0.5, depth: 20, lime)
                }
            case .dumbbells:
                dumbbellNodes.append(add(SCNCapsule(capRadius: 2.2, height: 9), lime))
                dumbbellNodes.append(add(SCNCapsule(capRadius: 2.2, height: 9), lime))
            case .dumbbellNear:
                dumbbellNodes.append(add(SCNCapsule(capRadius: 2.2, height: 9), lime))
            }
        }
    }

    private func addJoint(_ at: J) {
        jointNodes.append((add(SCNSphere(radius: CGFloat(at.radius)), body), at))
    }

    private func addBulge(_ from: J, _ to: J, along: Float, radius: CGFloat, stretch: Float) {
        let node = add(SCNSphere(radius: radius), body)
        node.simdScale = SIMD3(1, stretch, 1)
        bulges.append((node, from, to, along))
    }

    /// Works out what the camera has to fit: every key pose plus the props.
    private func frame() {
        var low = SIMD3<Float>(repeating: .greatestFiniteMagnitude)
        var high = SIMD3<Float>(repeating: -.greatestFiniteMagnitude)
        func include(_ p: SIMD3<Float>, _ pad: Float) {
            low = simd_min(low, p - SIMD3<Float>(repeating: pad))
            high = simd_max(high, p + SIMD3<Float>(repeating: pad))
        }
        for pose in demo.poses {
            let j = positions(pose)
            for joint in J.allCases { include(j[joint.rawValue], joint.radius + 1.5) }
            if let ball = ballPosition(pose.ball, j) { include(ball, 3) }
        }
        for prop in demo.props {
            switch prop {
            case .wall:
                include(SIMD3<Float>(96, 0, 0), 0)
                include(SIMD3<Float>(93, 56, 0), 0)
            case .mattress: include(SIMD3<Float>(99, 0, 0), 0)
            case .bench: include(SIMD3<Float>(12, 0, 0), 0)
            case .ladder:
                include(SIMD3<Float>(20, 0, 0), 0)
                include(SIMD3<Float>(80, 0, 0), 0)
            default: break
            }
        }
        include(SIMD3<Float>((low.x + high.x) / 2, 0, 0), 0)
        centre = SIMD3<Float>((low.x + high.x) / 2, (low.y + high.y) / 2, 0)
        halfSize = SIMD2<Float>(max((high.x - low.x) / 2, 14) + 8, max((high.y - low.y) / 2, 20))
    }

    // MARK: Posing

    /// Turns a flat pose into 3D joint positions. Side-on drills move in the
    /// forward plane with left and right limbs spread in depth. `frontal`
    /// drills face the camera, so left and right spread across the screen.
    private func positions(_ pose: Pose) -> [SIMD3<Float>] {
        var flat = pose
        flat.face = 1
        flat.lift = 0
        let s = Skeleton(flat)
        let originX = pose.x
        func v(_ p: CGPoint) -> SIMD3<Float> {
            SIMD3<Float>(Float(p.x - originX), Float(Skeleton.floor - p.y), 0)
        }
        let lean = Float(pose.torso * .pi / 180)
        let side: SIMD3<Float> = demo.frontal ? SIMD3<Float>(-cos(lean), sin(lean), 0) : SIMD3<Float>(0, 0, 1)
        let hipWidth: Float = 4.4
        let shoulderWidth: Float = 8.0

        var j = [SIMD3<Float>](repeating: .zero, count: J.allCases.count)
        let hip = v(s.hip)
        let shoulder = v(s.shoulder)
        j[J.hip.rawValue] = hip
        j[J.shoulder.rawValue] = shoulder
        j[J.head.rawValue] = v(s.head) + (v(s.head) - shoulder) * 0.2

        // Legs. `splay` opens the knees outward, as in a squat, and the shins
        // come part of the way back in so the feet stay planted.
        let open: Float = demo.frontal ? 0 : Float(pose.splay * .pi / 180)
        let back: Float = open * 0.55
        let legs: [(CGPoint, CGPoint, Float, J, J, J)] = [
            (s.lKnee, s.lFoot, 1, .lHip, .lKnee, .lFoot),
            (s.rKnee, s.rFoot, -1, .rHip, .rKnee, .rFoot),
        ]
        for (knee2D, foot2D, sign, hipJ, kneeJ, footJ) in legs {
            let root = hip + side * (hipWidth * sign)
            let thigh = v(knee2D) - hip
            let shin = v(foot2D) - v(knee2D)
            let kneeOut: Float = sign * -thigh.y * sin(open)
            let knee = root + SIMD3<Float>(thigh.x, thigh.y * cos(open), 0) + side * kneeOut
            let footIn: Float = sign * -shin.y * sin(back)
            let foot = knee + SIMD3<Float>(shin.x, shin.y * cos(back), 0) - side * footIn
            j[hipJ.rawValue] = root
            j[kneeJ.rawValue] = knee
            j[footJ.rawValue] = foot
        }

        let handWidth: Float = shoulderWidth * (pose.handsTogether ? 0.25 : 1)
        j[J.lShoulder.rawValue] = shoulder + side * shoulderWidth
        j[J.rShoulder.rawValue] = shoulder - side * shoulderWidth
        j[J.lElbow.rawValue] = v(s.lElbow) + side * (shoulderWidth + 1)
        j[J.rElbow.rawValue] = v(s.rElbow) - side * (shoulderWidth + 1)
        j[J.lHand.rawValue] = v(s.lHand) + side * handWidth
        j[J.rHand.rawValue] = v(s.rHand) - side * handWidth

        // A real turn about the vertical axis: face 1 looks right, -1 looks left.
        let turn = acos(max(-1, min(1, Float(pose.face))))
        if turn > 0.001 {
            let c = cos(turn), n = sin(turn)
            for i in j.indices {
                let p = j[i]
                j[i] = SIMD3<Float>(p.x * c + p.z * n, p.y, -p.x * n + p.z * c)
            }
        }

        // Rest the lowest part on the floor, then lift for jumps.
        var lowest = Float.greatestFiniteMagnitude
        for joint in J.allCases {
            lowest = min(lowest, j[joint.rawValue].y - joint.radius)
        }
        let shift = SIMD3<Float>(Float(pose.x), Float(pose.lift) - lowest, 0)
        return j.map { $0 + shift }
    }

    private func ballPosition(_ ball: Ball, _ j: [SIMD3<Float>]) -> SIMD3<Float>? {
        switch ball {
        case .none: return nil
        case .hands: return (j[J.lHand.rawValue] + j[J.rHand.rawValue]) / 2 + SIMD3<Float>(3, 0, 0)
        case .leftHand: return j[J.lHand.rawValue] + SIMD3<Float>(3, 0, 0)
        case .at(let x, let y): return SIMD3<Float>(Float(x), Float(Skeleton.floor - y) + 2.4, 0)
        }
    }

    private static func rotation(to direction: SIMD3<Float>) -> simd_quatf {
        let up = SIMD3<Float>(0, 1, 0)
        if simd_dot(up, direction) < -0.9999 {
            return simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
        }
        return simd_quatf(from: up, to: direction)
    }

    private static func aim(_ node: SCNNode, from a: SIMD3<Float>, to b: SIMD3<Float>, along: Float = 0.5) {
        node.simdPosition = a + (b - a) * along
        let length = simd_length(b - a)
        guard length > 0.0001 else { return }
        node.simdOrientation = rotation(to: (b - a) / length)
    }

    private func apply(time: TimeInterval) {
        let count = demo.poses.count
        guard count > 0 else { return }

        var a = demo.poses[0], b = demo.poses[0]
        var t = 0.0
        if let fixed {
            a = demo.poses[fixed % count]
            b = a
        } else {
            // Each key pose is held for a moment, then eased into the next.
            let progress = (time.truncatingRemainder(dividingBy: demo.period) / demo.period) * Double(count)
            let index = Int(progress) % count
            let raw = min(1, max(0, (progress - Double(Int(progress)) - 0.18) / 0.82))
            t = raw * raw * (3 - 2 * raw)
            a = demo.poses[index]
            b = demo.poses[(index + 1) % count]
        }

        let j = positions(a.mixed(with: b, t))
        func p(_ joint: J) -> SIMD3<Float> { j[joint.rawValue] }

        for item in limbs { Self.aim(item.node, from: p(item.from), to: p(item.to)) }
        for item in jointNodes { item.node.simdPosition = p(item.at) }
        for item in bulges { Self.aim(item.node, from: p(item.from), to: p(item.to), along: item.along) }

        // The trunk and head share one frame: across the shoulders, up the spine, front to back.
        let spine: SIMD3<Float> = p(.shoulder) - p(.hip)
        let up: SIMD3<Float> = simd_normalize(spine)
        let across: SIMD3<Float> = simd_normalize(p(.lShoulder) - p(.rShoulder))
        let depth: SIMD3<Float> = simd_normalize(simd_cross(across, up))
        let orientation = simd_quatf(simd_float3x3(columns: (across, up, depth)))
        for item in trunk {
            item.node.simdPosition = p(.hip) + spine * item.along
            item.node.simdOrientation = orientation
        }
        headNode.simdPosition = p(.head)
        headNode.simdOrientation = orientation
        Self.aim(neckNode, from: p(.shoulder) + up * 1.5, to: p(.head))

        // Feet point the way the body faces, unless the shin is lying flat.
        var forward: SIMD3<Float> = simd_cross(up, across)
        forward.y = 0
        forward = simd_length(forward) > 0.2 ? simd_normalize(forward) : SIMD3<Float>(1, 0, 0)
        for item in feet {
            let shin: SIMD3<Float> = simd_normalize(p(item.foot) - p(item.knee))
            let toe: SIMD3<Float> = abs(shin.y) > 0.6 ? forward : shin
            Self.aim(item.node, from: p(item.foot) - toe * 1.5, to: p(item.foot) + toe * 6)
        }
        for item in hands {
            let forearm: SIMD3<Float> = simd_normalize(p(item.hand) - p(item.elbow))
            Self.aim(item.node, from: p(item.hand), to: p(item.hand) + forearm * 4.6)
        }

        // The ball travels in a straight line between where each key pose puts it.
        if let from = ballPosition(a.ball, positions(a)), let to = ballPosition(b.ball, positions(b)) {
            ballNode.isHidden = false
            ballNode.simdPosition = from + (to - from) * Float(t)
        } else {
            ballNode.isHidden = true
        }

        // Dumbbells: one held at the chest when the hands are up, else one per hand.
        let left = p(.lHand), right = p(.rHand)
        let along: SIMD3<Float> = forward * 4.5
        if dumbbellNodes.count == 2 {
            if left.y > p(.shoulder).y - 9 {
                let middle: SIMD3<Float> = (left + right) / 2 + forward * 2
                Self.aim(dumbbellNodes[0], from: middle - SIMD3<Float>(0, 4.5, 0), to: middle + SIMD3<Float>(0, 4.5, 0))
                dumbbellNodes[1].isHidden = true
            } else {
                dumbbellNodes[1].isHidden = false
                Self.aim(dumbbellNodes[0], from: left - along, to: left + along)
                Self.aim(dumbbellNodes[1], from: right - along, to: right + along)
            }
        } else if let only = dumbbellNodes.first {
            Self.aim(only, from: left - along, to: left + along)
        }

        // Camera: a front three-quarter view, pulled back just far enough to
        // fit this drill, swaying a little.
        let sway: Float = fixed == nil ? 0.2 * Float(sin(time * 0.5)) : 0
        let angle: Float = 0.55 + sway
        let tanHalf: Float = tan(15 * Float.pi / 180)
        let distance: Float = max(halfSize.y / tanHalf, halfSize.x / (tanHalf * aspect)) * 1.18 + 20
        cameraNode.simdPosition = SIMD3<Float>(centre.x + distance * sin(angle), centre.y + distance * 0.16, distance * cos(angle))
        cameraNode.simdLook(at: centre)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        apply(time: time)
    }
}
