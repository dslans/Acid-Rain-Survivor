//
//  GameScene.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/3/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds
import GameKit

// game states
enum GameSceneState {
    case active, gameOver, paused
}


class GameScene: SKScene, SKPhysicsContactDelegate, GADInterstitialDelegate, GKGameCenterControllerDelegate {
    
    // Dismiss Game Center
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
    static var sharedInstance = GameScene()
    
    // Gestures
//    let swipeRightRec = UISwipeGestureRecognizer()
//    let swipeLeftRec = UISwipeGestureRecognizer()
    
    var debugLabel: SKLabelNode!
    
    // Layers
    var gameLayer: SKNode!
    var rapSheetLayer: SKNode!
    
    // Characters
    var hero:SKSpriteNode!
    var acid:SKSpriteNode!
    var umbrella:SKSpriteNode!
    var purpleRain: SKSpriteNode!
    
    // Power Ups
    var powerUp_2x: SKSpriteNode!
    var powerUp_4x: SKSpriteNode!
    var powerUpGlow: SKEmitterNode!
    var pointsMultiplier: Int = 1
    var powerUpMeter: SKSpriteNode!
    var powerUpMeterLabel: SKLabelNode!
    var powerUpStartTime: Int = 1200
    
    // Scene features
    var surface:SKNode!
    var musicOn = UserDefaults.standard.bool(forKey: "musicOn")
    var easyOn = UserDefaults.standard.bool(forKey: "easyOn")
    
    // Scoring
    var scoreDisplay: SKLabelNode! // scoreboard
    var score: Int = 0 // actual score
    var timeDisplay: SKLabelNode! // seen at survival bonus
    var gameTime: Int = 0 // game time in hundreths
    var umbrellaDisplay: SKLabelNode! // umbrella hud scoreboard
    var umbrellaCount: Int = 0 // umbrella counts
    var umbrellaStreak: Int = 0
    var pointsDisplay: SKLabelNode! // points displayed on poncho
    var multiplier: Int = 1 // streak multiplier, not points multiplier
    var bonusDisplay: SKLabelNode! // survival bonus every 30 secs
    var bonusTracker: Int = 0 // number of survival bonuses
    var highScoreDisplay: SKLabelNode! // not used
    var newHighScore: SKLabelNode! // used for rap sheet
    var newHighTime: SKLabelNode! // used for rap sheet
    var newHighUmbrella: SKLabelNode! // used for rap sheet
    
    // Rap Sheet
    var rapSheetScore: SKLabelNode!
    var rapSheetUmbrellaCount: SKLabelNode!
    var rapSheetSurvivalTime: SKLabelNode!
    
    // Buttons
    var buttonRestart: MSButtonNode!
    var buttonMainMenu: MSButtonNode!
    var buttonPause: MSButtonNode!
    var buttonPauseImage: SKSpriteNode!
    var buttonResume: MSButtonNode!
    
    // Gameplay Features
    var speedFactor: Double = 3.0
    var rainSpacing: CGFloat = 6.5
    var rainSpeed: CGFloat = 700 // raindrop speed
    var purpleRainSpeed: CGFloat = 300
    var umbrellaSpeed: CGFloat = 300
    var spawnTimer: Double = 0.0 // spawn time for rain
    var umbrellaSpawnTimer: Double = 0.0 // spawn time for umbrella rain
    var purpleRainSpawnTimer: Double = 0.0 // spawn time for purple rain
    var powerUpSpawnTimer: Double = 0.0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    
    // game state
    var gameState: GameSceneState = .active
    
    // game over
    var gameOverDisplay: SKLabelNode!
    var gameOverFilter: SKSpriteNode!
    
    // Play Count
    static var playCount: Int = 1

    //MARK: ---- didMove Function ----
    
    override func didMove(to view: SKView) {
    
        // Control GameScene from other Views
        GameScene.sharedInstance = self
        
        // Set in-game state
        GameViewController.currentInGame = true
        
        // Gestures
//        if gameState == .active {
//            swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight))
//            swipeRightRec.direction = .right
//            self.view?.addGestureRecognizer(swipeRightRec)
//
//            swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft))
//            swipeLeftRec.direction = .left
//            self.view?.addGestureRecognizer(swipeLeftRec)
//        }
        
        debugLabel = self.childNode(withName: "debug") as? SKLabelNode
        
        // Game Layers
        gameLayer = self.childNode(withName: "gameLayer")
        rapSheetLayer = self.childNode(withName: "rapSheetLayer")
//        addChild(pauseLayer)
        
        // Characters
        hero = gameLayer.childNode(withName: "hero") as? SKSpriteNode
//        let heroTexture = SKTexture(imageNamed: "poncho.png")
//        hero.physicsBody = SKPhysicsBody(texture: heroTexture, size: CGSize(width: 45, height: 96))
        acid = gameLayer.childNode(withName: "acid") as? SKSpriteNode
        umbrella = gameLayer.childNode(withName: "umbrella") as? SKSpriteNode
        purpleRain = gameLayer.childNode(withName: "purpleRain") as? SKSpriteNode
        
        
        // Power Ups
        powerUp_2x = gameLayer.childNode(withName: "powerUp_2x") as? SKSpriteNode
        powerUp_4x = gameLayer.childNode(withName: "powerUp_4x") as? SKSpriteNode
        powerUpGlow = hero.childNode(withName: "powerUpGlow") as? SKEmitterNode
        powerUpMeter = gameLayer.childNode(withName: "powerUpMeter") as? SKSpriteNode
        powerUpMeterLabel = powerUpMeter.childNode(withName: "powerUpMeterLabel") as? SKLabelNode
        powerUpMeter.alpha = 0
        powerUpGlow.isHidden = true
        powerUpGlow.particleColorSequence = nil
        powerUpGlow.particleColor = UIColor.clear
        
        // Scene Features
        surface = self.childNode(withName: "surface")
        
        // Assign Physics to Game Scene
        physicsWorld.contactDelegate = self
        
//        // Add Music
//        let backgroundMusic = SKAudioNode(fileNamed: "AcidRainGameplay1.mp3")
//        backgroundMusic.autoplayLooped = true
//        addChild(backgroundMusic)
        
        // Score: Umbrella Count
        umbrellaDisplay = self.childNode(withName: "umbrellaDisplay") as? SKLabelNode
        umbrellaDisplay.text = "\(umbrellaCount)"
        
        // Points Indicator
        pointsDisplay = hero.childNode(withName: "pointsDisplay") as? SKLabelNode
        pointsDisplay.alpha = 0
        
        // Score Display
        scoreDisplay = self.childNode(withName: "scoreDisplay") as? SKLabelNode
        scoreDisplay.text = "\(score)"
        
        
        // Points highScore Display
        highScoreDisplay = self.childNode(withName: "highScoreDisplay") as? SKLabelNode
        if let highScore = UserDefaults.standard.object(forKey: "highScore"){
            highScoreDisplay.text = "\(highScore)"
        } else {
            highScoreDisplay.text = "0"
        }
        
        // Bonus Display
        bonusDisplay = self.childNode(withName: "bonusDisplay") as? SKLabelNode
        bonusDisplay.alpha = 1
        
        // Game Over Display
        gameOverDisplay = self.childNode(withName: "gameOverDisplay") as? SKLabelNode
        gameOverDisplay.alpha = 0
        gameOverFilter = self.childNode(withName: "gameOverFilter") as? SKSpriteNode
        
        // New High! Labels
        newHighScore = rapSheetLayer.childNode(withName: "newHighScore") as? SKLabelNode
        newHighTime = rapSheetLayer.childNode(withName: "newHighTime") as? SKLabelNode
        newHighUmbrella = rapSheetLayer.childNode(withName: "newHighUmbrella") as? SKLabelNode
        newHighScore.alpha = 0
        newHighTime.alpha = 0
        newHighUmbrella.alpha = 0
        
        
        // Timer
        timeDisplay = bonusDisplay.childNode(withName: "timeDisplay") as? SKLabelNode
//        timeDisplay.text = "\(gameTime)"
//        timeDisplay.text = convertTime(time: gameTime)
        
        // Rap Sheet
        rapSheetScore = rapSheetLayer.childNode(withName: "rapSheetScore") as? SKLabelNode
        rapSheetUmbrellaCount = rapSheetLayer.childNode(withName: "rapSheetUmbrellaCount") as? SKLabelNode
        rapSheetSurvivalTime = rapSheetLayer.childNode(withName: "rapSheetSurvivalTime") as? SKLabelNode
        rapSheetLayer.alpha = 0

        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            if self.gameState == .active {
                self.gameTime += 1
            }
            
            self.showBonus()
//            self.timeDisplay.text = "\(self.gameTime)"
            },SKAction.wait(forDuration: 0.01)])))
        

        //MARK: Buttons
        buttonRestart = self.childNode(withName: "buttonRestart") as? MSButtonNode
        buttonMainMenu = self.childNode(withName: "buttonMainMenu") as? MSButtonNode
        self.buttonMainMenu.position = CGPoint(x: 375, y: 320)
        buttonPause = self.childNode(withName: "buttonPause") as? MSButtonNode
        buttonPauseImage = buttonPause.childNode(withName: "buttonPauseImage") as? SKSpriteNode
        buttonResume = self.childNode(withName: "buttonResume") as? MSButtonNode
        
        // Hide buttons
        buttonRestart.state = .MSButtonNodeStateHidden
        buttonMainMenu.state = .MSButtonNodeStateHidden
        buttonResume.state = .MSButtonNodeStateHidden
        
        
        // Setup restart button selection handler
        buttonRestart.selectedHandler = {
            self.score = 0
            self.umbrellaCount = 0
            
            // Show Interstitial Ad every 3 replays
//            if GameScene.playCount % 4 == 0 {
//                self.displayAd()
//                GameScene.playCount  += 1
//            } else {
                self.buttonPresentScene(sceneName: "GameScene")
//            }
        }
        
        // Setup main menu button selection handler
        buttonMainMenu.selectedHandler = {
            self.buttonFadeToScene(sceneName: "MainMenuScene")
            MusicManager.shared.setup(songName: "AcidRainTitleSequence")
            if self.musicOn {
                MusicManager.shared.play()
            }
        }
        
        // Setup for Resume Button
        buttonResume.selectedHandler = {
                self.resumeTheGame()
        }
        
        // Setup Pause Button
        buttonPause.selectedHandler = {
            if self.gameState == .active {
                self.pauseTheGame()
            }
        }

    }
    
    //MARK: ---- Physics ----
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        // Allows you to set physics bodies to nil on contact
        if contactA.node == nil || contactB.node == nil {
            return
        }
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Ensure only called while game running */
        if gameState != .active { return }
        
        
        // Actions for hero collects umbrella
        if nodeA.name == "hero" && nodeB.name == "umbrella" {
            
            /* Apply action to nodes  */
            nodeB.physicsBody = nil
            nodeB.removeAllActions()
            nodeB.run(SKAction.removeFromParent())
            
            // show points scored
            showPoints()
            
            // Update Score
            umbrellaCount += 1
            umbrellaDisplay.text = "\(umbrellaCount)"
            
            // update streak
            umbrellaStreak += 1
            
            // Increase multiplier
            if multiplier < 4 {
                multiplier += 1
            }
            
        }
        
        // Actions for hero collects powerUp multiplier
        if nodeA.name == "hero" && (nodeB.name == "powerUp_2x" || nodeB.name == "powerUp_4x") {
            
            /* Apply action to nodes  */
            nodeB.physicsBody = nil
            nodeB.removeAllActions()
            nodeB.run(SKAction.removeFromParent())
            
            // set score multiplier attributes
            if nodeB.name == "powerUp_2x" {
                pointsMultiplier = 2
                powerUpMeter.color = UIColor.cyan
                powerUpMeterLabel.text = "2X"
                powerUpGlow.particleColor = UIColor.cyan
            } else if nodeB.name == "powerUp_4x" {
                pointsMultiplier = 4
                powerUpMeter.color = UIColor.orange
                powerUpMeterLabel.text = "4X"
                powerUpGlow.particleColor = UIColor.orange
            }
            
            
            // power up meter
            powerUpMeter.alpha = 1
            powerUpGlow.isHidden = false
            let resizeMeter = SKAction.resize(toWidth: 0, duration: 10)
            let meterReset = SKAction.run {
                self.pointsMultiplier = 1
                self.powerUpMeter.alpha = 0
                self.powerUpMeter.size.width = 150
                self.powerUpGlow.isHidden = true
                self.powerUpGlow.particleColor = UIColor.clear
                self.powerUpSpawnTimer = -3
            }
            powerUpMeter.run(SKAction.sequence([resizeMeter, meterReset]))

        }
        
        // Actions for umbrella or power up hits ground
        if nodeA.name == "surface" && (nodeB.name == "umbrella" || nodeB.name == "powerUp_2x" || nodeB.name == "powerUp_4x") {
            
            /* Apply action to nodes  */
            nodeB.physicsBody = nil
            nodeB.removeAllActions()
            nodeB.run(SKAction.removeFromParent())
            
            // reset multiplier and streak
            if nodeB.name == "umbrella" {
                multiplier = 1
                umbrellaStreak = 0
            }
            
        }
        
        // Actions for when acid hits ground
        if nodeA.name == "surface" && nodeB.name == "acid" {
            
            /* Apply action to nodes  */
            nodeB.physicsBody = nil
            nodeB.removeAllActions()
            let animateRain: SKAction = SKAction(named: "animateRain")!
            nodeB.run(SKAction.sequence([animateRain, SKAction.removeFromParent()]))
            
        }
        
        // Actions for when purple rain hits ground
        if nodeA.name == "surface" && nodeB.name == "purpleRain" {
            
            /* Apply action to nodes  */
            nodeB.physicsBody = nil
            nodeB.removeAllActions()
            let adjustPurpleRainPosition: SKAction = SKAction.moveBy(x: 0, y: -10, duration: 0.05)
            let animateRain: SKAction = SKAction(named: "animatePurpleRain")!
            let fadePurpleRain: SKAction = SKAction.fadeOut(withDuration: 2)
            nodeB.run(SKAction.sequence([adjustPurpleRainPosition, animateRain, fadePurpleRain, SKAction.removeFromParent()]))
            
        }
        
        //MARK: Actions for when acid hits hero (Game Over)
        if nodeA.name == "hero" && nodeB.name == "acid" {
            
            nodeA.run(SKAction.wait(forDuration: 0.1))
            nodeA.removeAllActions()
            
            
            /* Change game state to game over */
            gameState = .gameOver
            bonusDisplay.alpha = 0
            powerUpMeter.alpha = 0
            powerUpGlow.isHidden = true
            
            // change in-game state
            GameViewController.currentInGame = false
            
            // increment playCount and call Interstitial Ad
            GameScene.playCount += 1
            print("Play Count: \(GameScene.playCount)")
            
            // Show game over text
            let moveTextDown:SKAction = SKAction.moveTo(y: 947, duration: 0.5)
            let textFadeIn:SKAction = SKAction.fadeIn(withDuration: 1)
            let textFadeOut:SKAction = SKAction.fadeAlpha(to: 0.6, duration: 1)
            let textFadeRepeat:SKAction = SKAction.repeatForever(SKAction.sequence([textFadeIn, textFadeOut]))
            gameOverDisplay.run(SKAction.sequence([moveTextDown, textFadeIn]))
            gameOverDisplay.run(textFadeRepeat)
            
            // Remove HUD
            scoreDisplay.alpha = 0
            umbrellaDisplay.alpha = 0
            buttonPauseImage.alpha = 0
            highScoreDisplay.alpha = 0
            
            
            // Update Rap Sheet
            rapSheetScore.text = "\(score) points"
            rapSheetUmbrellaCount.text = "\(umbrellaCount)"
            rapSheetSurvivalTime.text = convertTime(time: gameTime)
            rapSheetSurvivalTime.text = convertTime(time: gameTime)
            
            // Delay rap sheet
            let waitAd:SKAction = SKAction.wait(forDuration: 0.25)
            let waitRapSheet:SKAction = SKAction.wait(forDuration: 1.75)
            
            self.run(waitAd) {
                // Interstitial Ad every 3 replays or after a 3 min game
                if GameScene.playCount % 3 == 0 && self.gameTime < 18000 {
                    self.displayAd()
                } else if self.gameTime >= 18000 {
                    self.displayAd()
                    GameScene.playCount = 0
                }
            }
            
            self.run(waitRapSheet) {
                
                // show buttons
                self.buttonRestart.state = .MSButtonNodeStateActive
                self.buttonMainMenu.state = .MSButtonNodeStateActive
                
                // fade rain
                self.gameLayer.alpha = 0.5
                
                // show rap sheet
                self.rapSheetLayer.alpha = 1
                
                // use Game Over Filter
                self.gameOverFilter.position = CGPoint(x: 0, y: 0)
                self.gameOverFilter.size = CGSize(width: self.frame.maxX, height: self.frame.maxY)
            }
            
            /* Load the fade action resource */
            let fadeSprite:SKAction = SKAction.init(named: "Fade")!
            let removeHero = SKAction.removeFromParent()
            
            /* Apply action to nodes  */
            hero.zPosition = 1
            self.hero.physicsBody = nil
            nodeB.physicsBody = nil
            hero.run(SKAction.sequence([fadeSprite, removeHero]))
            nodeB.removeAllActions()
            nodeB.run(SKAction.moveBy(x: 0, y: -50, duration: 2))
            nodeB.run(SKAction.sequence([fadeSprite, SKAction.removeFromParent()]))
            
            //MARK: high score update
            
            // Points
            if UserDefaults.standard.object(forKey: "highScore") != nil {
                let hscore = UserDefaults.standard.integer(forKey: "highScore")
                if hscore < score {
                    UserDefaults.standard.set(scoreDisplay.text, forKey: "highScore")
                    // diplay new high text
                    newHighScore.alpha = 1
                }
            } else {
                UserDefaults.standard.set(score, forKey: "highScore")
            }
            
            // Umbrella Count
            if UserDefaults.standard.object(forKey: "umbrellaHighScore") != nil {
                let umbrellaScore = UserDefaults.standard.integer(forKey: "umbrellaHighScore")
                if umbrellaScore < umbrellaCount {
                    UserDefaults.standard.set(umbrellaDisplay.text, forKey: "umbrellaHighScore")
                    // diplay new high text
                    newHighUmbrella.alpha = 1
                }
            } else {
                UserDefaults.standard.set(umbrellaCount, forKey: "umbrellaHighScore")
            }
            
            // Best Survival Time
            if UserDefaults.standard.object(forKey: "survivalBestTime") != nil {
                let survivalTimeText = UserDefaults.standard.string(forKey: "survivalBestTime")
                let survivalTime = Int(minutesSecondsInterval(survivalTimeText!) * 100)
                print("survivalTime: \(survivalTime)")
                if survivalTime < gameTime {
                    UserDefaults.standard.set(rapSheetSurvivalTime.text, forKey: "survivalBestTime")
                    // diplay new high text
                    newHighTime.alpha = 1
                }
            } else {
                UserDefaults.standard.set(rapSheetSurvivalTime.text, forKey: "survivalBestTime")
            }
            
            //MARK: Update Game Center
            
            // Submit high score to GC leaderboard
            let bestScoreInt = GKScore(leaderboardIdentifier: "survivor_top_scores")
            bestScoreInt.value = Int64(score)
            GKScore.report([bestScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Best Score submitted to your Leaderboard!")
                }
            }
            
            // Submit umbrella count to GC leaderboard
            let bestUmbrellaInt = GKScore(leaderboardIdentifier: "survivor_most_umbrellas")
            bestUmbrellaInt.value = Int64(umbrellaCount)
            GKScore.report([bestUmbrellaInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Best Umbrella Count submitted to your Leaderboard!")
                }
            }
            
        }
    
    }
    
    //MARK: ---- Touches ----
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {
  
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
        
        // Choosing a touch to work with
        guard let touch = touches.first else {
            return
        }

        // Record Location of touch and move hero
        let touchLocation = touch.location(in: self)
        if hero.position.x <= 150 && touchLocation.x < hero.position.x + hero.size.width && touchLocation.y < 1100 {
            moveLeft()
        } else if hero.position.x >= 600 && touchLocation.x > hero.position.x - hero.size.width && touchLocation.y < 1100 {
            moveRight()
        } else if touchLocation.x > hero.position.x && touchLocation.y < 1100{
            moveRight()
        } else if touchLocation.x < hero.position.x && touchLocation.y < 1100{
            moveLeft()
        }
        
        // Touch right half and left half of screen to move
//        let touchLocation = touch.location(in: self)
//        if touchLocation.x > frame.maxX / 2 && touchLocation.y < 1100{
//            moveRight()
//        } else if touchLocation.x < frame.maxX / 2 && touchLocation.y < 1100{
//            moveLeft()
//        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches { self.touchUp(atPoint: t.location(in: self))
        
            }
        
//        guard let touch = touches.first else {
//            return
//        }
//
//        let touchLocation = touch.location(in: self)
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    //MARK: ---- Update Function ----
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // debug label
        var gameStateText: String = "xxx"
        switch gameState {
        case .active:
            gameStateText = "active"
        case .paused:
            gameStateText = "paused"
        case .gameOver:
            gameStateText = "gameover"
        }
        
        debugLabel.text = gameStateText
        
        if gameState == .gameOver {
            updateRain()
            spawnTimer += fixedDelta
            self.buttonResume.state = .MSButtonNodeStateHidden
            
        } else if gameState == .active {
            
            self.buttonResume.state = .MSButtonNodeStateHidden
            spawnTimer += fixedDelta
            umbrellaSpawnTimer += fixedDelta
            purpleRainSpawnTimer += fixedDelta
            
            if gameTime > powerUpStartTime && pointsMultiplier == 1 {
                powerUpSpawnTimer += fixedDelta
            }
            
            if easyOn == false {
                gameFlow()
            }
            
        } else if gameState == .paused {
            gameLayer.isPaused = true
        }else if gameState != .active {
            debugLabel.text = gameStateText
            return
        }
        
        
        // Player is bounded to the frame
        keepPlayerInBounds()
        
        // Increase the spawn timer
//        spawnTimer += fixedDelta
//        umbrellaSpawnTimer += fixedDelta
        
        // GameCenter Achievement
//        GCAchievement.GCfunction.umbrellaStreak1(streak: umbrellaStreak)
        
        // Create acid rain drops
        updateRain()
//        if umbrellaCount >= 10 {
//            updatePurpleRain()
//        }
//        
        // Create umbrella Rain
        updateUmbrella()
        
        // spawn power ups
        updatePowerUp()
        
        // Update Score
        scoreDisplay.text = "\(score)"
        timeDisplay.text = convertTime(time: gameTime)

    }
    
    
    //MARK: ---- Action Functions ----
    
    // Player Movements
    func moveRight() {

        let walkRight:SKAction = SKAction(named: "walkRight")!
        let moveRight = SKAction.moveBy(x: hero.size.width, y:0, duration:0.2)
        let moveRightAnimation = SKAction.group([walkRight, moveRight])

        if gameState != .active { return }

        hero.run(moveRightAnimation)
//        hero.run(SKAction.repeatForever(moveRightAnimation))
    }
    

    func moveLeft() {

        let walkLeft:SKAction = SKAction(named: "walkLeft")!
        let moveLeft = SKAction.moveBy(x: -hero.size.width, y:0, duration:0.2)
        let moveLeftAnimation = SKAction.group([walkLeft, moveLeft])

        if gameState != .active { return }

        hero.run(moveLeftAnimation)
//        hero.run(SKAction.repeatForever(moveLeftAnimation))
    }
    
//    @objc func swipedRight(){
//        print("swiped right")
//        let walkRight:SKAction = SKAction(named: "walkRight")!
//        let moveRight = SKAction.moveBy(x: hero.size.width, y:0, duration:0.1)
//        let moveRightAnimation = SKAction.group([walkRight, moveRight])
//
//        if gameState != .active { return }
//
//        hero.run(moveRightAnimation)
//    }
//
//    @objc func swipedLeft(){
//        print("swiped left")
//        let walkLeft:SKAction = SKAction(named: "walkLeft")!
//        let moveLeft = SKAction.moveBy(x: -hero.size.width, y:0, duration:0.1)
//        let moveLeftAnimation = SKAction.group([walkLeft, moveLeft])
//
//        if gameState != .active { return }
//
//        hero.run(moveLeftAnimation)
//    }

    // Keep Player in bounds
    func keepPlayerInBounds() {
        if hero.position.x < frame.minX + hero.size.width/2 {
            hero.position.x = frame.minX + hero.size.width/2
        }
        if hero.position.x > frame.maxX - hero.size.width/2 {
            hero.position.x = frame.maxX - hero.size.width/2
        }
    }
    
    // Points scored
    func showPoints(){
        var points: Int = 25 * pointsMultiplier
        points *= multiplier
        score += points
        pointsDisplay.text = "+\(points)"
        print("CURRENT MULTIPLIER: \(multiplier)")
        print("CURRENT POINTS MULTIPLIER: \(pointsMultiplier)")
        
        // set color
        if pointsMultiplier == 2 {
            pointsDisplay.fontColor = UIColor.cyan
        } else if pointsMultiplier == 4 {
            pointsDisplay.fontColor = UIColor.orange
        } else {
            pointsDisplay.fontColor = UIColor.white
        }
        
        pointsDisplay.alpha = 1
        
        // move display up and fade
        let pointsUp:SKAction = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        let pointsDown:SKAction = SKAction.moveBy(x: 0, y: -50, duration: 0.01)
        let pointsFade:SKAction = SKAction.fadeOut(withDuration: 0.5)
        
        pointsDisplay.run(SKAction.sequence([pointsUp, pointsFade, pointsDown]))
        
    }
    
    // Bonus Text
    func showBonus(){
        
        // time bonus (every 30 seconds)
        if gameTime > 0 && gameTime % 3000 == 0 {
            bonusDisplay.text = "Survival Bonus"
            bonusDisplay.alpha = 0.5

            let bonusUp:SKAction = SKAction.moveBy(x: 0, y: 200, duration: 2)
            let bonusDown:SKAction = SKAction.moveBy(x: 0, y: -200, duration: 1)
            let bonusFadeOut:SKAction = SKAction.fadeOut(withDuration: 3)
            let bonusWait: SKAction = SKAction.wait(forDuration: 2)
            let bonusAnimation = SKAction.group([bonusDown])
            let bonusAnimationOut = SKAction.group([bonusUp, bonusFadeOut])
            bonusDisplay.run(SKAction.sequence([bonusAnimation, bonusWait, bonusAnimationOut]))
            
            // add 300 points
            score += 300
            
            // increase speed slightly
            if rainSpeed < 1100 && gameTime > 12000 {
                rainSpeed += 25
            }
            
            // increment Bonus Tracker
            bonusTracker += 1

        }
    }
    
    // Reproduce Acid Rain
    func updateRain(){
        
        // Decide intervals to spawn new rain drops (time for rain to travel 3x hero's height)
        if spawnTimer >= (Double(rainSpacing * hero.size.height) / Double(rainSpeed)){
            
            let newRain = acid.copy() as! SKSpriteNode
            // Create lanes for the rain
            var lanes: [CGFloat] = [size.width / 20]
            for lane in 0...8 {
                let newLanePosition = lanes[lane] + size.width / 10
                lanes.append(newLanePosition)
            }
            
            // Determine where to spawn the rain along the X axis
            let randomIndex = Int(arc4random_uniform(10))
            let actualX: CGFloat = lanes[randomIndex]
            let randomPosition = CGPoint(x: actualX , y: size.height + newRain.size.height/2)
            
            // Set Rain Position
            newRain.position = randomPosition
            gameLayer.addChild(newRain)
            
            // Determine speed of the rain
            let surfaceTop = surface.position.y + surface.frame.height / 2
            let actualDuration = CGFloat((size.height - surfaceTop) / rainSpeed)
            
            // Create the actions
            let actionMove = SKAction.move(to: CGPoint(x: actualX, y: surfaceTop), duration: CFTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            let rainDropAnimation:SKAction = SKAction(named: "animateRain")!
            newRain.run(SKAction.sequence([actionMove, rainDropAnimation, actionMoveDone]))
            
            // Reset the spawn timer
            spawnTimer = 0
            
        }
        
    }
    
    func updateUmbrella(){
        
        // Decide intervals to spawn umbrella
        if umbrellaSpawnTimer >= 4 {
            
            // only drop umbrella if the game is active
            if gameState != .active { return }
            
            let newUmbrella = umbrella.copy() as! SKSpriteNode

            // Create lanes for the umbrella
            var lanes: [CGFloat] = [size.width / 20]
            for lane in 0...8 {
                let newLanePosition = lanes[lane] + size.width / 10
                lanes.append(newLanePosition)
            }
            
            // Determine where to spawn the umbrella along the X axis
            let randomIndex = Int(arc4random_uniform(10))
            let actualX: CGFloat = lanes[randomIndex]
            let randomPosition = CGPoint(x: actualX , y: size.height + newUmbrella.size.height/2)
            
            // Set umbrella position
            newUmbrella.position = randomPosition
            gameLayer.addChild(newUmbrella)
            
            // Determine speed of the umbrella
            let surfaceTop = surface.position.y + surface.frame.size.height / 2
            let actualDuration = CGFloat((size.height - surfaceTop) / umbrellaSpeed)
            
            
            // Create the actions
            let actionMove = SKAction.move(to: CGPoint(x: actualX, y: surfaceTop), duration: CFTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            let fadeSprite:SKAction = SKAction.init(named: "Fade")!
            newUmbrella.run(SKAction.sequence([actionMove, fadeSprite, actionMoveDone]))
            
            // Reset the spawn timer
            umbrellaSpawnTimer = 0
            
        }
        
    }
    
    // Reproduce Acid Rain
    func updatePurpleRain(){
        
        // Decide intervals to spawn new rain drops (time for rain to travel 2x hero's height)
        if purpleRainSpawnTimer >= (Double(25 * hero.size.height) / Double(purpleRainSpeed)) / speedFactor {
            
            let newRain = purpleRain.copy() as! SKSpriteNode
            // Create lanes for the rain
            var lanes: [CGFloat] = [size.width / 20]
            for lane in 0...8 {
                let newLanePosition = lanes[lane] + size.width / 10
                lanes.append(newLanePosition)
            }
            
            // Determine where to spawn the rain along the X axis
            let randomIndex = Int(arc4random_uniform(10))
            let actualX: CGFloat = lanes[randomIndex]
            let randomPosition = CGPoint(x: actualX , y: size.height + newRain.size.height/2)
            
            // Set Rain Position
            newRain.position = randomPosition
            gameLayer.addChild(newRain)
            
            // Determine speed of the rain
            let surfaceTop = surface.position.y + surface.frame.height / 2
            let actualDuration = CGFloat((size.height - surfaceTop) / purpleRainSpeed)
            
            // Create the actions
            let actionMove = SKAction.move(to: CGPoint(x: actualX, y: surfaceTop), duration: CFTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            let rainDropAnimation:SKAction = SKAction(named: "animatePurpleRain")!
            newRain.run(SKAction.sequence([actionMove, rainDropAnimation, actionMoveDone]))
            
            // Reset the spawn timer
            purpleRainSpawnTimer = 0
            
        }
        
    }
    
    
    // power ups
    func updatePowerUp(){
        
        // Decide intervals to spawn power ups
        if powerUpSpawnTimer >= 5 && pointsMultiplier == 1 {
            
            // only drop power up if the game is active
            if gameState != .active { return }
            
            // only drop after certain time seconds
            if gameTime < powerUpStartTime { return }
            
            // random number generator
            let rannum = drand48()
            
            // 2x points multiplier
            var newPowerUp: SKSpriteNode!
            
            if rannum < 0.075 {
                newPowerUp = powerUp_4x.copy() as? SKSpriteNode
                powerUpGlow.particleColor = UIColor.orange
            } else if rannum < 0.30 {
                newPowerUp = powerUp_2x.copy() as? SKSpriteNode
                powerUpGlow.particleColor = UIColor.cyan
            } else {
                powerUpSpawnTimer = 0
                return

            }
            
            
            
            // Create lanes for the umbrella
            var lanes: [CGFloat] = [size.width / 20]
            for lane in 0...8 {
                let newLanePosition = lanes[lane] + size.width / 10
                lanes.append(newLanePosition)
            }
            
            // Determine where to spawn the umbrella along the X axis
            let randomIndex = Int(arc4random_uniform(10))
            let actualX: CGFloat = lanes[randomIndex]
            let randomPosition = CGPoint(x: actualX , y: size.height + newPowerUp.size.height/2)
            
            // Set umbrella position
            newPowerUp.position = randomPosition
            gameLayer.addChild(newPowerUp)
            
            // Determine speed of the powerUp
            let surfaceTop = surface.position.y + surface.frame.size.height / 2
            let actualDuration = CGFloat((size.height - surfaceTop) / (umbrellaSpeed + 50))
            
            
            // Create the actions
            let actionMove = SKAction.move(to: CGPoint(x: actualX, y: surfaceTop), duration: CFTimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            let fadeSprite:SKAction = SKAction.init(named: "Fade")!
            newPowerUp.run(SKAction.sequence([actionMove, fadeSprite, actionMoveDone]))
            
            // Reset the spawn timer
            powerUpSpawnTimer = 0
            
        }
    }
    
    // Game Flow
    func gameFlow() {
        
        if rainSpeed < 900 {
            rainSpeed += 0.5
        }
        
        if gameTime > 500  && gameTime < 1000 && rainSpacing > 4 {
            rainSpacing -= 0.005
        } else if gameTime > 1000  && gameTime < 12000 {
            rainSpacing = CGFloat(drand48() + drand48() / 2 + 3.25)
        } else if gameTime > 12000 {
            rainSpacing = CGFloat(drand48() + 3.25)
        }
    }
    
    //MARK: ---- Helper Functions ----
    
    // pausing the game
    @objc func pauseTheGame() {
        self.buttonResume.state = .MSButtonNodeStateActive
        self.buttonMainMenu.state = .MSButtonNodeStateActive
        self.buttonMainMenu.position = CGPoint(x: 375, y: 547)
        self.gameLayer.isPaused = true
        self.gameState = .paused
        if musicOn {
            MusicManager.shared.pause()
        }
        
    }
    
    
    // resuming the game
    func resumeTheGame() {
        self.gameLayer.isPaused = false
        self.buttonResume.state = .MSButtonNodeStateHidden
        self.buttonMainMenu.state = .MSButtonNodeStateHidden
        self.buttonMainMenu.position = CGPoint(x: 375, y: 320)
        self.gameState = .active
        if musicOn {
            MusicManager.shared.play()
        }
    }
    
    // button action to present scene
    func buttonPresentScene(sceneName: String) {
        // Grab reference to our SpriteKit view
        let skView = self.view as SKView?
        
        // Load Game scene
        let scene = GameScene(fileNamed:sceneName) as GameScene?
        
        // Ensure correct aspect mode
        scene?.scaleMode = .aspectFit
        
        // Restart game scene
        skView?.presentScene(scene)
    }
    
    // button action to present scene
    func buttonFadeToScene(sceneName: String) {
        // Grab reference to our SpriteKit view
        let skView = self.view as SKView?
        
        // Load Game scene
        let scene = GameScene(fileNamed:sceneName) as GameScene?
        
        // Ensure correct aspect mode
        scene?.scaleMode = .aspectFit
        
        // Restart game scene
        skView?.presentScene(scene!, transition: SKTransition.fade(withDuration: 1))
    }
    
    // convert time format
    func convertTime(time: Int) -> String {
        
        // initialize time display
        var timeLabel:String = "00:00.00"
        
        // hundredths text
        let timeHundredths = String(Int(time)).suffix(2)
        
        // seconds text
        let timeSeconds = (Int(time / 100) % 3600) % 60
        var timeSecondsText = "00"
        if String(timeSeconds).count < 2{
            timeSecondsText = "0" + String(timeSeconds)
        } else {
            timeSecondsText = String(timeSeconds)
        }
        
        // minutes text
        let timeMinutes = (Int(time / 100) % 3600) / 60
        var timeMinutesText = "00"
        if String(timeMinutes).count < 2{
            timeMinutesText = "0" + String(timeMinutes)
        } else {
            timeMinutesText = String(timeMinutes)
        }
        
        // final time display
        timeLabel = timeMinutesText + ":" + timeSecondsText + "." + timeHundredths
        
        return timeLabel
    }
    
    // Convert Time Text into Numeric
    func minutesSecondsInterval(_ timeString:String)->TimeInterval!{
        var time = timeString.components(separatedBy: ":")
        print("time: \(time)")
        if let seconds = Double(time[1]){
            if let minutes = Double(time[0]){
                return (seconds + (minutes * 60.0))
            }
        }
        return nil
    }

    
    // Display Interstitial Ads
    func displayAd() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAndShow"), object: nil)
//        GameScene.playCount += 1
    }
    
//    func checkAd() {
//        if GameScene.playCount % 3 == 0 {
//            displayAd()
//        }
//    }
    
    
}
