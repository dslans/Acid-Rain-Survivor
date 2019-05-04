//
//  Achievements.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/27/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//

import GameKit

class GCAchievement {
    static let GCfunction = GCAchievement()
    
    func umbrellaStreak1 (streak: Int) {
        
        if streak == 10 {
            let achievement = GKAchievement(identifier: "survivor_umbrella_streak_10")
            
            achievement.showsCompletionBanner = true  // use Game Center's UI
            
            GKAchievement.report([achievement], withCompletionHandler: nil)
        }
    }

    
    
}


