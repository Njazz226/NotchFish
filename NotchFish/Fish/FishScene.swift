import SpriteKit

/// Main SpriteKit scene — owns the fish node and runs the update loop.
/// Behavior is split across extensions in separate files:
///   FishNode.swift       — fish creation, idle animation, color/settings
///   FishStates.swift     — idle, swimming, fleeing, cowering, emerging
///   FishAnimations.swift — pupil tracking, sleep, bubbles
///   FishMood.swift       — mood cycling logic
class FishScene: SKScene {

    // MARK: - Fish Nodes

    var fish: SKNode!
    var fishBody: SKShapeNode!
    var fishTail: SKShapeNode!
    var fishEye: SKShapeNode!
    var fishPupil: SKShapeNode!
    var fishMouth: SKShapeNode!
    var fishDorsalFin: SKShapeNode!
    var fishPectoralFin: SKShapeNode!
    var fishBelly: SKShapeNode!
    var fishScaleArcs: [SKShapeNode] = []
    var fishEyelid: SKShapeNode!

    // MARK: - Configuration (set by AppDelegate)

    var actualNotchWidth: CGFloat = 0
    var menuBarHeight: CGFloat = 38

    // MARK: - State

    enum FishState {
        case idle, swimming, fleeing, cowering, emerging
    }

    var state: FishState = .idle
    var mousePosition: CGPoint = .zero
    var mouseDistance: CGFloat = 999
    var lastMouseMoveTime: TimeInterval = 0

    // MARK: - Movement

    var swimDirection: CGFloat = 1
    var visualDirection: CGFloat = 1
    var swimSpeed: CGFloat = 22
    var lastTime: TimeInterval = 0
    var nextActionTime: TimeInterval = 0
    var swimTime: TimeInterval = 0
    var nextTurnCheckTime: TimeInterval = 0
    var currentSwimSpeedMult: CGFloat = 1.0
    var swimStartTime: TimeInterval = 0

    // MARK: - Notch

    var notchCenter: CGFloat = 0
    var notchHalfWidth: CGFloat = 0

    // MARK: - Thresholds (adjusted by mood)

    let baseScareRadius: CGFloat = 100
    let baseSafeRadius: CGFloat = 200
    var scareRadius: CGFloat { baseScareRadius * activeMood.scareRadiusMult }
    var safeRadius: CGFloat { baseSafeRadius * activeMood.scareRadiusMult }

    // MARK: - Mood

    var activeMood: FishSettings.FishMood = .auto
    var autoMoodTimer: TimeInterval = 0
    var nextMoodChangeTime: TimeInterval = 0
    let autoMoodCycleMoods: [FishSettings.FishMood] = [.happy, .calm, .nervous, .happy, .calm]
    var autoMoodIndex: Int = 0

    // MARK: - Sleep

    var sleepiness: CGFloat = 0
    let baseSleepDelay: TimeInterval = 45

    // MARK: - Cowering / Emerging

    var cowerStartTime: TimeInterval = 0
    var emergeTargetX: CGFloat = 0
    var emergeStartTime: TimeInterval = 0
    var emergeStartX: CGFloat = 0

    // MARK: - Fleeing

    var hiddenBehindNotch: Bool = false
    var hiddenOffScreenSide: CGFloat = 0
    let fishFullLength: CGFloat = 42
    var committedToNotch: Bool = false
    var committedToEdge: Bool = false

    // MARK: - Misc

    var crossingNotch: Bool = false
    var currentSizeScale: CGFloat = 1.0
    var bubbleTimer: TimeInterval = 0
    var nextBubbleTime: TimeInterval = 3.0
    let bodyMargin: CGFloat = 28
    var settingsCheckTimer: TimeInterval = 0
    var lastAppliedColor: FishSettings.FishColor = .orange

    // MARK: - Pupil

    var pupilTargetX: CGFloat = 0.5
    var pupilTargetY: CGFloat = 0
    var pupilCurrentX: CGFloat = 0.5
    var pupilCurrentY: CGFloat = 0

    // MARK: - Sleep Z

    var lastZTime: TimeInterval = 0

    // MARK: - Computed Properties

    var fishCenterY: CGFloat {
        menuBarHeight / 2 + max(0, (currentSizeScale - 1.0)) * 8
    }

    var mouseIsActive: Bool {
        lastMouseMoveTime > 0 && (lastTime - lastMouseMoveTime) < 2.0
    }

    var notchLeftEdge: CGFloat { notchCenter - notchHalfWidth - bodyMargin }
    var notchRightEdge: CGFloat { notchCenter + notchHalfWidth + bodyMargin }
    var hasNotch: Bool { notchHalfWidth > 5 }
    var screenMinX: CGFloat { bodyMargin }
    var screenMaxX: CGFloat { size.width - bodyMargin }

    var effectiveSwimSpeed: CGFloat {
        swimSpeed * CGFloat(FishSettings.shared.speedMultiplier) * activeMood.speedMult
    }

    // MARK: - Setup

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        notchCenter = size.width / 2
        notchHalfWidth = actualNotchWidth > 10 ? actualNotchWidth / 2 : 0
        createFish()
        scheduleNextAction()
    }

    // MARK: - Mouse Input

    func updateMousePosition(_ point: CGPoint) {
        mousePosition = point
        mouseDistance = hypot(point.x - fish.position.x, point.y - fish.position.y)
        lastMouseMoveTime = lastTime
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        let dt = lastTime == 0 ? 0 : currentTime - lastTime
        lastTime = currentTime
        guard dt < 1.0 else { return }

        if state != .cowering {
            swimTime += dt
        }

        // Settings check
        settingsCheckTimer += dt
        if settingsCheckTimer > 0.5 {
            settingsCheckTimer = 0
            applySettings()
        }

        updateMood(dt)

        // State updates
        switch state {
        case .idle:     updateIdle(currentTime, dt)
        case .swimming: updateSwimming(dt)
        case .fleeing:  updateFleeing(dt)
        case .cowering: updateCowering(dt)
        case .emerging: updateEmerging(dt)
        }

        // Vertical bob
        if state != .cowering {
            let centerY = fishCenterY
            fish.position.y = centerY + CGFloat(sin(swimTime * 1.5)) * 2.5
        }

        updatePupil(dt)
        updateSleep(dt)
        updateBubbles(currentTime, dt)

        // Smooth turn
        if sleepiness < 0.15 {
            let turnSpeed: CGFloat = (state == .fleeing) ? 12.0 : 8.0
            let diff = swimDirection - visualDirection
            if abs(diff) < 0.05 {
                visualDirection = swimDirection
            } else {
                visualDirection += diff * turnSpeed * CGFloat(dt)
            }
        }

        // Smooth size
        let targetSize = CGFloat(FishSettings.shared.sizeMultiplier)
        let sizeDiff = targetSize - currentSizeScale
        if abs(sizeDiff) < 0.005 {
            currentSizeScale = targetSize
        } else {
            currentSizeScale += sizeDiff * 6.0 * CGFloat(dt)
        }
        fish.xScale = visualDirection * currentSizeScale
        fish.yScale = currentSizeScale
    }

    // MARK: - Utilities

    func scheduleNextAction(min: Double = 3.0, max: Double = 7.0) {
        nextActionTime = lastTime + Double.random(in: min...max)
    }
}
