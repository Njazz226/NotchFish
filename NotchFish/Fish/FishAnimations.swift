import SpriteKit

/// Pupil tracking, sleep system, and bubble effects.
extension FishScene {

    // MARK: - Pupil Tracking

    func updatePupil(_ dt: TimeInterval) {
        let maxOffset: CGFloat = 1.2

        if state == .fleeing || state == .cowering {
            // Look backward at danger (negative x = toward tail in local space)
            pupilTargetX = -0.8
            pupilTargetY = 0
        } else if mouseIsActive && mouseDistance < safeRadius && state != .cowering {
            let dx = mousePosition.x - fish.position.x
            let dy = mousePosition.y - fish.position.y
            let lookX = max(-maxOffset, min(maxOffset, (dx / 60) * swimDirection))
            let lookY = max(-maxOffset, min(maxOffset, dy / 40))
            pupilTargetX = lookX
            pupilTargetY = lookY
        } else {
            pupilTargetX = 0.5
            pupilTargetY = CGFloat(sin(swimTime * 0.7)) * 0.3
        }

        let pupilSpeed: CGFloat = 6.0
        pupilCurrentX += (pupilTargetX - pupilCurrentX) * pupilSpeed * CGFloat(dt)
        pupilCurrentY += (pupilTargetY - pupilCurrentY) * pupilSpeed * CGFloat(dt)

        fishPupil.position = CGPoint(x: pupilCurrentX, y: pupilCurrentY)
    }

    // MARK: - Sleep

    func updateSleep(_ dt: TimeInterval) {
        let timeSinceMouseMove = lastTime - lastMouseMoveTime
        let effectiveSleepDelay = baseSleepDelay * activeMood.sleepDelayMult

        let targetSleepiness: CGFloat
        if !FishSettings.shared.sleepEnabled {
            targetSleepiness = 0
        } else if state == .fleeing || state == .cowering || state == .emerging {
            targetSleepiness = 0
        } else if lastMouseMoveTime > 0 && !mouseIsActive && timeSinceMouseMove > effectiveSleepDelay {
            let overtime = CGFloat(timeSinceMouseMove - effectiveSleepDelay)
            targetSleepiness = min(1.0, overtime / 20.0)
        } else {
            targetSleepiness = 0
        }

        let sleepSpeed: CGFloat = (targetSleepiness > sleepiness) ? 1.5 : 4.0
        sleepiness += (targetSleepiness - sleepiness) * sleepSpeed * CGFloat(dt)
        sleepiness = max(0, min(1, sleepiness))

        // Eyelid position
        let eyelidOpenY: CGFloat = 8
        let eyelidClosedY: CGFloat = 0
        fishEyelid.position.y = eyelidOpenY - sleepiness * (eyelidOpenY - eyelidClosedY)

        // Slow animations
        let tailSpeed: CGFloat = 1.0 - sleepiness * 0.7
        fishTail.speed = tailSpeed
        fishPectoralFin.speed = tailSpeed

        // Z particles
        if sleepiness > 0.8 && Int(lastTime * 2) % 4 == 0 {
            spawnSleepZ()
        }
    }

    func spawnSleepZ() {
        guard lastTime - lastZTime > 2.0 else { return }
        lastZTime = lastTime

        let z = SKLabelNode(text: "z")
        z.fontSize = 8
        z.fontColor = NSColor(white: 1.0, alpha: 0.6)
        z.fontName = "Helvetica-Bold"
        z.position = CGPoint(x: fish.position.x + swimDirection * 10, y: fish.position.y + 8)
        addChild(z)

        let rise = SKAction.moveBy(x: CGFloat.random(in: -6...6), y: 20, duration: 2.0)
        let grow = SKAction.scale(to: 1.5, duration: 2.0)
        let fade = SKAction.fadeOut(withDuration: 2.0)
        rise.timingMode = .easeOut
        z.run(SKAction.sequence([SKAction.group([rise, grow, fade]), SKAction.removeFromParent()]))
    }

    // MARK: - Bubbles

    func updateBubbles(_ currentTime: TimeInterval, _ dt: TimeInterval) {
        bubbleTimer += dt
        let fishVisible = fish.position.x > screenMinX - 5
            && fish.position.x < screenMaxX + 5
            && !(hasNotch && fish.position.x > notchLeftEdge && fish.position.x < notchRightEdge)
        let shouldBubble = fishVisible && (state == .idle || state == .swimming || state == .emerging)
        if shouldBubble && bubbleTimer > nextBubbleTime {
            bubbleTimer = 0
            nextBubbleTime = Double.random(in: 2.5...5.0) * activeMood.bubbleFreqMult
            spawnBubble()
        }
    }

    func spawnBubble() {
        let bubble = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.2...3.0))
        bubble.fillColor = NSColor(white: 1.0, alpha: 0.4)
        bubble.strokeColor = NSColor(white: 1.0, alpha: 0.65)
        bubble.lineWidth = 0.4
        bubble.position = CGPoint(
            x: fish.position.x + swimDirection * 12,
            y: fish.position.y + 5
        )
        addChild(bubble)

        let rise = SKAction.moveBy(x: CGFloat.random(in: -4...4), y: 25, duration: 1.8)
        let fade = SKAction.fadeOut(withDuration: 1.8)
        rise.timingMode = .easeOut
        bubble.run(SKAction.sequence([SKAction.group([rise, fade]), SKAction.removeFromParent()]))
    }
}
