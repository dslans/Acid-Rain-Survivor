//
//  MenuScene.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/6/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//

import SpriteKit
//import GameplayKit
import GameKit
import UIKit

class MainMenuScene: SKScene, GKGameCenterControllerDelegate {
    
    // Dismiss Game Center
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Declarations
    
    var subtitle: SKSpriteNode!
    
    // new player screen
    var newPlayerLayer: SKNode!
    
    // Buttons
    var buttonPlay: MSButtonNode!
    var buttonLeaderboard: AltButtonNode!
    var buttonSettings: AltButtonNode!
    var buttonHelp: AltButtonNode!
    
    // Labels
    var highScoreDisplay: SKLabelNode!
    var umbrellaHighScoreDisplay: SKLabelNode!
    var survivalTimeBestDisplay: SKLabelNode!
    var easyOnLabel: SKLabelNode!
    
    // settings View
    var settingsLayer: SKSpriteNode!
    var settingsReturnToMain: MSButtonNode!
    var settingsTitle: SKLabelNode!
    var musicButton: MSButtonNode!
    var easyButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        GameViewController.currentInGame = false
        
        // new player detection - instruct a new player to view the tutorial
        newPlayerLayer = self.childNode(withName: "newPlayerLayer")
        if UserDefaults.standard.object(forKey: "newPlayerStatus") != nil {
            UserDefaults.standard.set(false, forKey: "newPlayerStatus")
            newPlayerLayer.position.x = -1000
        } else {
            UserDefaults.standard.set(true, forKey: "newPlayerStatus")
            newPlayerLayer.position.x = 0
        }
        
        // Subtitle: Survivor
        subtitle = self.childNode(withName: "subtitle") as? SKSpriteNode
        subtitle.alpha = 0
//        subtitle.size = CGSize(width: 100, height: 20)
//        let subtitleZoom = SKAction.resize(toWidth: 600, height: 125, duration: 1)
        let subtitleFadeIn = SKAction.fadeIn(withDuration: 3)
        let subtitlePulse = SKAction.repeatForever(SKAction.sequence([SKAction.fadeAlpha(to: 0.6, duration: 2), SKAction.fadeIn(withDuration: 2)]))
        let subtitleAction = SKAction.sequence([subtitleFadeIn, subtitlePulse])
//        let subtitleSound = SKAction.playSoundFileNamed("SubtitleSoundEffect2.mp3", waitForCompletion: false)
        subtitle.run(subtitleAction)
        
        //MARK: Score Displays
        
        // High Score Display
        highScoreDisplay = self.childNode(withName: "highScoreDisplay") as? SKLabelNode
        if let highScore = UserDefaults.standard.object(forKey: "highScore"){
            highScoreDisplay.text = "High Score: \(highScore)"
        } else {
            highScoreDisplay.text = "High Score: 0"
        }
        
        // Most Umbrella Display
        umbrellaHighScoreDisplay = self.childNode(withName: "umbrellaHighScoreDisplay") as? SKLabelNode
        if let umbrellaScore = UserDefaults.standard.object(forKey: "umbrellaHighScore"){
            umbrellaHighScoreDisplay.text = "\(umbrellaScore)"
        } else {
            umbrellaHighScoreDisplay.text = "0"
        }
        
        // Best Survival Time Display
        survivalTimeBestDisplay = self.childNode(withName: "survivalTimeBestDisplay") as? SKLabelNode
        if let survivalTime = UserDefaults.standard.object(forKey: "survivalBestTime"){
            survivalTimeBestDisplay.text = "\(survivalTime)"
        } else {
            survivalTimeBestDisplay.text = "00:00.00"
        }
        
        //MARK: Settings
        
        // Settings Layer
        settingsLayer = self.childNode(withName: "settingsLayer") as? SKSpriteNode
        settingsLayer.alpha = 0
        
        // Settings Contents
        settingsTitle = settingsLayer.childNode(withName: "settingsTitle") as? SKLabelNode
        settingsReturnToMain = settingsLayer.childNode(withName: "settingsReturnToMain") as? MSButtonNode
        settingsReturnToMain.state = .MSButtonNodeStateHidden
        
        // Settings Actions
        settingsReturnToMain.selectedHandler = {
            self.settingsLayer.alpha = 0
            self.settingsLayer.position = CGPoint(x: 1015, y: 0)
            self.settingsReturnToMain.state = .MSButtonNodeStateHidden
            self.buttonPlay.state = .MSButtonNodeStateActive
            self.buttonSettings.state = .AltButtonNodeStateActive
            self.buttonLeaderboard.state = .AltButtonNodeStateActive
            self.highScoreDisplay.alpha = 1
        }
        
        // Music On/Off Button
        musicButton = settingsLayer.childNode(withName: "musicButton") as? MSButtonNode
        var musicOn = UserDefaults.standard.bool(forKey: "musicOn")
        
        // default button image state
        if UserDefaults.standard.object(forKey: "musicOn") != nil {
            if musicOn {
                self.musicButton.texture = SKTexture(imageNamed: "musicSliderOn_Small.png")
            } else {
                self.musicButton.texture = SKTexture(imageNamed: "musicSliderOff_Small.png")
            }
        } else {
            musicOn = true
            self.musicButton.texture = SKTexture(imageNamed: "musicSliderOn_Small.png")
        }
        
        // music button action
        musicButton.selectedHandler = {
            if musicOn {
                self.musicButton.texture = SKTexture(imageNamed: "musicSliderOff_Small.png")
                musicOn = false
                MusicManager.shared.stop()
                UserDefaults.standard.set(false, forKey: "musicOn")
            } else {
                self.musicButton.texture = SKTexture(imageNamed: "musicSliderOn_Small.png")
                musicOn = true
                MusicManager.shared.play()
                UserDefaults.standard.set(true, forKey: "musicOn")
            }
            
        }
        
        // Easy Mode On/Off Button
        easyOnLabel = self.childNode(withName: "easyOnLabel") as? SKLabelNode
        easyOnLabel.alpha = 0
        easyButton = settingsLayer.childNode(withName: "easyButton") as? MSButtonNode
        var easyOn = UserDefaults.standard.bool(forKey: "easyOn")
        
        // default button image state
        if UserDefaults.standard.object(forKey: "easyOn") != nil {
            if easyOn {
                self.easyButton.texture = SKTexture(imageNamed: "musicSliderOn_Small.png")
                self.easyOnLabel.alpha = 1
            } else {
                self.easyButton.texture = SKTexture(imageNamed: "musicSliderOff_Small.png")
                self.easyOnLabel.alpha = 0
            }
        } else {
            easyOn = false
            self.easyButton.texture = SKTexture(imageNamed: "musicSliderOff_Small.png")
            self.easyOnLabel.alpha = 0
        }
        
        // easy button action
        easyButton.selectedHandler = {
            if easyOn {
                self.easyButton.texture = SKTexture(imageNamed: "musicSliderOff_Small.png")
                easyOn = false
                self.easyOnLabel.alpha = 0
                UserDefaults.standard.set(false, forKey: "easyOn")
            } else {
                self.easyButton.texture = SKTexture(imageNamed: "musicSliderOn_Small.png")
                easyOn = true
                self.easyOnLabel.alpha = 1
                UserDefaults.standard.set(true, forKey: "easyOn")
            }
            
        }
    
        
        //MARK: Buttons
        
        // Leaderboard Button
        buttonLeaderboard = self.childNode(withName: "buttonLeaderboard") as? AltButtonNode
        buttonLeaderboard.selectedHandler = {
            let gcVC = GKGameCenterViewController()
            gcVC.gameCenterDelegate = self
            gcVC.viewState = .leaderboards
//            gcVC.leaderboardIdentifier = "survivor_top_scores"
//            present(gcVC, animated: true, completion: nil)
            let currentViewController:UIViewController=UIApplication.shared.keyWindow!.rootViewController!
            
            currentViewController.present(gcVC, animated: true, completion: nil)
        }
        
        // Settings Button
        buttonSettings = self.childNode(withName: "buttonSettings") as? AltButtonNode
        buttonSettings.selectedHandler = {
            self.settingsLayer.position = CGPoint(x: 0, y: 0)
            self.settingsLayer.alpha = 1
            self.settingsReturnToMain.state = .MSButtonNodeStateActive
            self.buttonPlay.state = .MSButtonNodeStateHidden
            self.buttonSettings.state = .AltButtonNodeStateHidden
            self.buttonLeaderboard.state = .AltButtonNodeStateHidden
            self.highScoreDisplay.alpha = 0
        }
        
        // Help button
        buttonHelp = self.childNode(withName: "buttonHelp") as? AltButtonNode
        buttonHelp.selectedHandler = {
            // Grab reference to our SpriteKit view
            let skView = self.view as SKView?
            
            // Load Game scene
            let scene = GameScene(fileNamed:"TrainingScene") as GameScene?
            
            // Ensure correct aspect mode
            scene?.scaleMode = .aspectFit
            
            // Present game scene
            let transition = SKTransition.push(with: .up, duration: 1)
            skView?.presentScene(scene!, transition: transition)
//            skView?.presentScene(scene)
        }
        
        // Play Button
        buttonPlay = self.childNode(withName: "buttonPlay") as? MSButtonNode
        buttonPlay.selectedHandler = {
            self.buttonPresentScene(sceneName: "GameScene")
            MusicManager.shared.setup(songName: "AcidRainGameplay1")
            if musicOn {
                MusicManager.shared.play()
            }
        }
        
    }
    
    
    //MARK: Helper Functions
    func buttonPresentScene(sceneName: String) {
        // Grab reference to our SpriteKit view
        let skView = self.view as SKView?
        
        // Load Game scene
        let scene = GameScene(fileNamed:sceneName) as GameScene?
        
        // Ensure correct aspect mode
        scene?.scaleMode = .aspectFit
        
        // Present game scene
//        skView?.presentScene(scene)
        let transition = SKTransition.fade(withDuration: 1)
        skView?.presentScene(scene!, transition: transition)
    }
    
    
}
