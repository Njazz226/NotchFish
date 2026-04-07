import SpriteKit

/// State update methods: idle, swimming, fleeing, cowering, emerging.
extension FishScene {

    // MARK: - Idle

    func updateIdle(_ currentTime: TimeInterval, _ dt: TimeInterval) {
        if mouseIsActive && mouseDistance < scareRadius {
            enterFleeing()
            return
        }

        if sleepiness > 0.15 { return }

        if currentTime > nextActionTime {
            let fishX = fish.position.x
            if hasNotch {
                if Double.random(in: 0...1) < 0.3 {
                    swimDirection = fishX < notchCenter ? 1 : -1
                } else {
                    swimDirection = fishX < notchCenter ? -1 : 1
                }
            } else {
                if fishX < size.width * 0.3 {
                    swimDirection = 1
                } else if fishX > size.width * 0.7 {
                    swimDirection = -1
                } else {
                    swimDirection = Bool.random() ? 1 : -1
                }
            }
            currentSwimSpeedMult = CGFloat.random(in: 0.6...1.4)
            swimStartTime = lastTime
            state = .swimming
            scheduleNextAction(min: 3.0, max: 7.0)
        }
    }

    // MARK: - Swimming

    func updateSwimming(_ dt: TimeInterval) {
        if mouseIsActive && mouseDistance < scareRadius {
            enterFleeing()
            return
        }

        let rampT = min(1.0, CGFloat(lastTime - swimStartTime) / 1.5)
        let rampFactor = rampT * rampT

        let speedVariation = 1.0 + 0.15 * sin(swimTime * 1.2)
        let sleepFactor = max(0, 1.0 - sleepiness * 2.0)
        fish.position.x += effectiveSwimSpeed * CGFloat(dt) * swimDirection
            * CGFloat(speedVariation) * currentSwimSpeedMult * rampFactor * sleepFactor

        let fishX = fish.position.x

        // Notch zone
        if hasNotch && !crossingNotch {
            if swimDirection > 0 && fishX > notchLeftEdge && fishX < notchCenter {
                if Double.random(in: 0...1) < 0.35 {
                    crossingNotch = true
                } else {
                    fish.position.x = notchLeftEdge
                    swimDirection = -1
                }
            } else if swimDirection < 0 && fishX < notchRightEdge && fishX > notchCenter {
                if Double.random(in: 0...1) < 0.35 {
                    crossingNotch = true
                } else {
                    fish.position.x = notchRightEdge
                    swimDirection = 1
                }
            }
        }

        if crossingNotch && hasNotch {
            if swimDirection > 0 && fishX > notchRightEdge {
                crossingNotch = false
            } else if swimDirection < 0 && fishX < notchLeftEdge {
                crossingNotch = false
            }
        }

        // Screen edges
        if fishX < screenMinX {
            fish.position.x = screenMinX
            swimDirection = 1
        } else if fishX > screenMaxX {
            fish.position.x = screenMaxX
            swimDirection = -1
        }

        // Random turn or pause
        if lastTime > nextTurnCheckTime {
            nextTurnCheckTime = lastTime + Double.random(in: 4.0...8.0)
            let roll = Double.random(in: 0...1)
            if roll < 0.10 {
                state = .idle
                scheduleNextAction(min: 2.0, max: 4.0)
            } else if roll < 0.25 {
                swimDirection *= -1
            }
        }
    }

    // MARK: - Fleeing

    func enterFleeing() {
        swimDirection = (fish.position.x >= mousePosition.x) ? 1 : -1
        state = .fleeing
        hiddenBehindNotch = false
        hiddenOffScreenSide = 0
        committedToNotch = false
        committedToEdge = false
        crossingNotch = false
        fishPupil.setScale(1.4)
    }

    func updateFleeing(_ dt: TimeInterval) {
        let fishX = fish.position.x
        let physNotchLeft = notchCenter - notchHalfWidth
        let physNotchRight = notchCenter + notchHalfWidth

        // Flip if mouse moves ahead
        if mouseIsActive && mouseDistance < scareRadius && !committedToNotch && !committedToEdge {
            let mouseAhead = (swimDirection > 0 && mousePosition.x < fishX + 30) ||
                             (swimDirection < 0 && mousePosition.x > fishX - 30)
            if mouseAhead {
                swimDirection = (fishX >= mousePosition.x) ? 1 : -1
            }
        }

        // Commit to notch
        if !committedToNotch && hasNotch {
            let fishFront = fishX + 14 * swimDirection
            if fishFront > physNotchLeft && fishFront < physNotchRight {
                committedToNotch = true
            }
        }

        // Commit to edge
        if !committedToEdge {
            let fishFrontX = fishX + 14 * swimDirection
            if fishFrontX < 0 || fishFrontX > size.width {
                committedToEdge = true
            }
        }

        // Mouse gone?
        if !mouseIsActive || mouseDistance > safeRadius {
            if committedToNotch || committedToEdge {
                // Keep going until hidden
            } else if hiddenBehindNotch || hiddenOffScreenSide != 0 {
                state = .cowering
                cowerStartTime = lastTime
                return
            } else {
                fishPupil.setScale(1.0)
                if hasNotch && fishX > notchLeftEdge && fishX < notchCenter {
                    fish.position.x = notchLeftEdge
                    swimDirection = -1
                } else if hasNotch && fishX < notchRightEdge && fishX > notchCenter {
                    fish.position.x = notchRightEdge
                    swimDirection = 1
                }
                state = .swimming
                swimStartTime = lastTime
                scheduleNextAction(min: 2.0, max: 4.0)
                return
            }
        }

        // Movement
        let mouseGone = !mouseIsActive || mouseDistance > safeRadius
        let speed: CGFloat
        if (committedToNotch || committedToEdge) && mouseGone {
            speed = effectiveSwimSpeed * 1.5
        } else {
            speed = effectiveSwimSpeed * 3.0 * activeMood.fleeSpeedMult
        }
        fish.position.x += speed * CGFloat(dt) * swimDirection

        let newFishX = fish.position.x

        if newFishX <= -fishFullLength {
            fish.position.x = -fishFullLength
            hiddenOffScreenSide = -1
            committedToNotch = false
            committedToEdge = false
            state = .cowering
            cowerStartTime = lastTime
        } else if newFishX >= size.width + fishFullLength {
            fish.position.x = size.width + fishFullLength
            hiddenOffScreenSide = 1
            committedToNotch = false
            committedToEdge = false
            state = .cowering
            cowerStartTime = lastTime
        } else if hasNotch && abs(newFishX - notchCenter) < 8
                    && (committedToNotch || (newFishX > notchLeftEdge && newFishX < notchRightEdge)) {
            fish.position.x = notchCenter
            hiddenBehindNotch = true
            committedToNotch = false
            state = .cowering
            cowerStartTime = lastTime
        }
    }

    // MARK: - Cowering

    func updateCowering(_ dt: TimeInterval) {
        let mouseGone = !mouseIsActive || mouseDistance > safeRadius
        let waited = (lastTime - cowerStartTime) > 2.5

        if mouseGone && waited {
            fishPupil.setScale(1.0)

            if hiddenBehindNotch {
                let side: CGFloat
                if mouseIsActive {
                    side = mousePosition.x < notchCenter ? 1 : -1
                } else {
                    side = Bool.random() ? 1 : -1
                }
                swimDirection = side
                emergeTargetX = side > 0 ? notchRightEdge + 20 : notchLeftEdge - 20
                emergeStartX = fish.position.x
                emergeStartTime = lastTime
                hiddenBehindNotch = false
                state = .emerging

            } else if hiddenOffScreenSide != 0 {
                swimDirection = hiddenOffScreenSide < 0 ? 1 : -1
                emergeTargetX = hiddenOffScreenSide < 0 ? screenMinX + 40 : screenMaxX - 40
                emergeStartX = fish.position.x
                emergeStartTime = lastTime
                hiddenOffScreenSide = 0
                state = .emerging

            } else {
                swimDirection = fish.position.x < notchCenter ? -1 : 1
                state = .swimming
                swimStartTime = lastTime
                scheduleNextAction(min: 2.0, max: 5.0)
            }
        }
    }

    // MARK: - Emerging

    func updateEmerging(_ dt: TimeInterval) {
        if mouseIsActive && mouseDistance < scareRadius * 0.7 {
            enterFleeing()
            return
        }

        let elapsed = CGFloat(lastTime - emergeStartTime)
        let duration: CGFloat = 3.5
        let t = min(1.0, elapsed / duration)
        let easedT = t * t

        let totalDist = emergeTargetX - emergeStartX
        fish.position.x = emergeStartX + totalDist * easedT

        if t >= 1.0 {
            fish.position.x = emergeTargetX
            state = .swimming
            scheduleNextAction(min: 2.0, max: 5.0)
        }
    }
}
