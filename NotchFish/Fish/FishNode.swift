import SpriteKit

/// Fish creation, idle animations, and settings application.
extension FishScene {

    func createFish() {
        fish = SKNode()
        fish.position = CGPoint(x: notchCenter + notchHalfWidth + 40, y: fishCenterY)

        // Body — rounded oval
        let bodyPath = CGMutablePath()
        bodyPath.addEllipse(in: CGRect(x: -14, y: -7, width: 28, height: 14))
        fishBody = SKShapeNode(path: bodyPath)
        fishBody.fillColor = NSColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1.0)
        fishBody.strokeColor = NSColor(red: 0.85, green: 0.35, blue: 0.05, alpha: 1.0)
        fishBody.lineWidth = 0.8
        fish.addChild(fishBody)

        // Belly highlight
        let bellyPath = CGMutablePath()
        bellyPath.addEllipse(in: CGRect(x: -9, y: -5, width: 18, height: 8))
        fishBelly = SKShapeNode(path: bellyPath)
        fishBelly.fillColor = NSColor(red: 1.0, green: 0.75, blue: 0.4, alpha: 0.5)
        fishBelly.strokeColor = .clear
        fishBelly.position = CGPoint(x: 1, y: -1)
        fish.addChild(fishBelly)

        // Scale pattern (3 arcs)
        fishScaleArcs.removeAll()
        for i in 0..<3 {
            let scalePath = CGMutablePath()
            let sx = CGFloat(-4 + i * 5)
            scalePath.addArc(center: CGPoint(x: sx, y: 0),
                             radius: 3,
                             startAngle: .pi * 0.2,
                             endAngle: .pi * 0.8,
                             clockwise: false)
            let scaleArc = SKShapeNode(path: scalePath)
            scaleArc.strokeColor = NSColor(red: 0.9, green: 0.4, blue: 0.05, alpha: 0.4)
            scaleArc.lineWidth = 0.5
            scaleArc.fillColor = .clear
            fish.addChild(scaleArc)
            fishScaleArcs.append(scaleArc)
        }

        // Tail — forked
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: -13, y: 0))
        tailPath.addCurve(to: CGPoint(x: -24, y: 8),
                          control1: CGPoint(x: -17, y: 2),
                          control2: CGPoint(x: -22, y: 6))
        tailPath.addLine(to: CGPoint(x: -18, y: 1))
        tailPath.addLine(to: CGPoint(x: -18, y: -1))
        tailPath.addLine(to: CGPoint(x: -24, y: -8))
        tailPath.addCurve(to: CGPoint(x: -13, y: 0),
                          control1: CGPoint(x: -22, y: -6),
                          control2: CGPoint(x: -17, y: -2))
        tailPath.closeSubpath()
        fishTail = SKShapeNode(path: tailPath)
        fishTail.fillColor = NSColor(red: 1.0, green: 0.45, blue: 0.05, alpha: 1.0)
        fishTail.strokeColor = NSColor(red: 0.85, green: 0.3, blue: 0.0, alpha: 0.8)
        fishTail.lineWidth = 0.5
        fish.addChild(fishTail)

        // Dorsal fin
        let dorsalPath = CGMutablePath()
        dorsalPath.move(to: CGPoint(x: -4, y: 7))
        dorsalPath.addCurve(to: CGPoint(x: 6, y: 7),
                            control1: CGPoint(x: -1, y: 15),
                            control2: CGPoint(x: 4, y: 14))
        dorsalPath.closeSubpath()
        fishDorsalFin = SKShapeNode(path: dorsalPath)
        fishDorsalFin.fillColor = NSColor(red: 1.0, green: 0.4, blue: 0.05, alpha: 0.85)
        fishDorsalFin.strokeColor = NSColor(red: 0.85, green: 0.3, blue: 0.0, alpha: 0.6)
        fishDorsalFin.lineWidth = 0.5
        fish.addChild(fishDorsalFin)

        // Pectoral fin
        let pectoralPath = CGMutablePath()
        pectoralPath.move(to: CGPoint(x: 2, y: -5))
        pectoralPath.addCurve(to: CGPoint(x: -3, y: -12),
                              control1: CGPoint(x: 4, y: -8),
                              control2: CGPoint(x: 1, y: -12))
        pectoralPath.addCurve(to: CGPoint(x: -2, y: -5),
                              control1: CGPoint(x: -5, y: -10),
                              control2: CGPoint(x: -4, y: -6))
        pectoralPath.closeSubpath()
        fishPectoralFin = SKShapeNode(path: pectoralPath)
        fishPectoralFin.fillColor = NSColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 0.7)
        fishPectoralFin.strokeColor = .clear
        fish.addChild(fishPectoralFin)

        // Eye
        fishEye = SKShapeNode(circleOfRadius: 3)
        fishEye.fillColor = .white
        fishEye.strokeColor = NSColor(white: 0.3, alpha: 0.5)
        fishEye.lineWidth = 0.5
        fishEye.position = CGPoint(x: 8, y: 2)
        fish.addChild(fishEye)

        // Pupil
        fishPupil = SKShapeNode(circleOfRadius: 1.8)
        fishPupil.fillColor = NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        fishPupil.strokeColor = .clear
        fishPupil.position = CGPoint(x: 0.5, y: 0)
        fishEye.addChild(fishPupil)

        // Pupil highlight
        let highlight = SKShapeNode(circleOfRadius: 0.6)
        highlight.fillColor = NSColor(white: 1.0, alpha: 0.9)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0.5, y: 0.5)
        fishPupil.addChild(highlight)

        // Mouth
        let mouthPath = CGMutablePath()
        mouthPath.addArc(center: CGPoint(x: 12, y: -1),
                         radius: 2,
                         startAngle: .pi * 0.1,
                         endAngle: .pi * 0.6,
                         clockwise: true)
        fishMouth = SKShapeNode(path: mouthPath)
        fishMouth.strokeColor = NSColor(red: 0.7, green: 0.25, blue: 0.0, alpha: 0.7)
        fishMouth.lineWidth = 0.7
        fishMouth.fillColor = .clear
        fish.addChild(fishMouth)

        // Eyelid (crop node — only visible inside eye area)
        let eyeCrop = SKCropNode()
        eyeCrop.position = CGPoint(x: 8, y: 2)
        eyeCrop.zPosition = 2

        let maskNode = SKShapeNode(circleOfRadius: 3)
        maskNode.fillColor = .white
        eyeCrop.maskNode = maskNode

        fishEyelid = SKShapeNode(circleOfRadius: 4)
        fishEyelid.fillColor = NSColor(red: 1.0, green: 0.55, blue: 0.15, alpha: 1.0)
        fishEyelid.strokeColor = .clear
        fishEyelid.position = CGPoint(x: 0, y: 8)
        eyeCrop.addChild(fishEyelid)

        fish.addChild(eyeCrop)
        addChild(fish)
        startIdleAnimation()
    }

    func startIdleAnimation() {
        let wagRight = SKAction.rotate(toAngle: 0.2, duration: 0.35)
        let wagLeft = SKAction.rotate(toAngle: -0.2, duration: 0.35)
        wagRight.timingMode = .easeInEaseOut
        wagLeft.timingMode = .easeInEaseOut
        fishTail.run(SKAction.repeatForever(SKAction.sequence([wagRight, wagLeft])), withKey: "tailWag")

        let finUp = SKAction.rotate(toAngle: 0.15, duration: 0.5)
        let finDown = SKAction.rotate(toAngle: -0.1, duration: 0.5)
        finUp.timingMode = .easeInEaseOut
        finDown.timingMode = .easeInEaseOut
        fishPectoralFin.run(SKAction.repeatForever(SKAction.sequence([finUp, finDown])), withKey: "finFlutter")
    }

    func applySettings() {
        let s = FishSettings.shared

        if s.fishColor != lastAppliedColor {
            lastAppliedColor = s.fishColor
            let c = s.fishColor
            fishBody.fillColor = c.bodyColor
            fishBody.strokeColor = c.strokeColor
            fishBelly.fillColor = c.bellyColor
            fishTail.fillColor = c.tailColor
            fishTail.strokeColor = c.strokeColor.withAlphaComponent(0.8)
            fishDorsalFin.fillColor = c.finColor.withAlphaComponent(0.85)
            fishDorsalFin.strokeColor = c.strokeColor.withAlphaComponent(0.6)
            fishPectoralFin.fillColor = c.bodyColor.withAlphaComponent(0.7)
            fishMouth.strokeColor = c.mouthColor.withAlphaComponent(0.7)
            fishEyelid.fillColor = c.eyelidColor
            for arc in fishScaleArcs {
                arc.strokeColor = c.scaleColor
            }
        }
    }
}
