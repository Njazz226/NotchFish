import Foundation

/// Mood cycling logic for auto-mood mode.
extension FishScene {

    func updateMood(_ dt: TimeInterval) {
        let settingsMood = FishSettings.shared.fishMood
        if settingsMood != .auto {
            activeMood = settingsMood
            return
        }

        // First run: pick random starting mood
        if activeMood == .auto {
            autoMoodIndex = Int.random(in: 0..<autoMoodCycleMoods.count)
            activeMood = autoMoodCycleMoods[autoMoodIndex]
            nextMoodChangeTime = Double.random(in: 60...120)
        }

        // Cycle at fixed intervals
        autoMoodTimer += dt
        if autoMoodTimer > nextMoodChangeTime {
            autoMoodTimer = 0
            nextMoodChangeTime = Double.random(in: 60...120)
            autoMoodIndex = (autoMoodIndex + 1) % autoMoodCycleMoods.count
            activeMood = autoMoodCycleMoods[autoMoodIndex]
        }
    }
}
