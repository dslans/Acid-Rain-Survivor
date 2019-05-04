//
//  TrainingScene.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/25/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

// game states
enum TrainingSceneState {
    case active, gameOver, paused
}

class TrainingScene: SKScene, SKPhysicsContactDelegate {
    
    // Layers
    var gameLayer: SKNode!
    
    // Characters
    var hero:SKSpriteNode!
    var acid:SKSpriteNode!
    var umbrella:SKSpriteNode!
    
    // Scene features
    var surface:SKNode!
    var acidLabel:SKLabelNode!
    var umbrellaLabel:SKLabelNode!
    var arrowUp:SKSpriteNode!
    var highlightLeft: SKSpriteNode!
    var highlightRight: SKSpriteNode!
    var ponchoSpeech: SKLabelNode!
    
    // Buttons
    var buttonMainMenu: MSButtonNode!
    
    // Gameplay Features
    var speedFactor: Double = 1.0
    var rainSpeed: CGFloat = 900 // raindrop speed
    var umbrellaSpeed: CGFloat = 900 / 3
    var spawnTimer: Double = 0.0 // spawn time for rain
    var umbrellaSpawnTimer: Double = 0.0 // spawn time for umbrella rain
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    
    // game state
    var gameState: TrainingSceneState = .active

    
    //MARK: didMove Function
    override func didMove(to view: SKView) {
        
        // Game Layers
        gameLayer = self.childNode(withName: "gameLayer")
        
        // Characters
        hero = gameLayer.childNode(withName: "hero") as? SKSpriteNode
//        acid = gameLayer.childNode(withName: "acid") as! SKSpriteNode
//        acid.position = CGPoint(x: 160, y: 1000)
//        acid.alpha = 0
//        umbrella = gameLayer.childNode(withName: "umbrella") as! SKSpriteNode
//        umbrella.position = CGPoint(x: 160, y: 1000)
//        umbrella.alpha = 0
        
        // Scene Features
        highlightLeft = self.childNode(withName: "highlightLeft") as? SKSpriteNode
        highlightRight = self.childNode(withName: "highlightRight") as? SKSpriteNode
        ponchoSpeech = hero.childNode(withName: "ponchoSpeech") as? SKLabelNode
        surface = self.childNode(withName: "surface")
        acidLabel = self.childNode(withName: "acidLabel") as? SKLabelNode
//        acidLabel.position = CGPoint(x: 375, y: 980)
//        acidLabel.alpha = 0
        umbrellaLabel = self.childNode(withName: "umbrellaLabel") as? SKLabelNode
//        umbrellaLabel.position = CGPoint(x: 375, y: 980)
//        umbrellaLabel.alpha = 0
        
        // Assign Physics to Game Scene
        physicsWorld.contactDelegate = self
        
        
        //MARK: Buttons
        buttonMainMenu = self.childNode(withName: "buttonMainMenu") as? MSButtonNode
        arrowUp = buttonMainMenu.childNode(withName: "arrowUp") as? SKSpriteNode
        let flash: SKAction = SKAction.sequence([SKAction.fadeOut(withDuration: 0.75
            ), SKAction.fadeIn(withDuration: 0.5)])
        arrowUp.run(SKAction.repeatForever(flash))

        // Setup main menu button selection handler
        buttonMainMenu.selectedHandler = {
            self.buttonPresentScene(sceneName: "MainMenuScene")
        }

        
        // Show buttons
        buttonMainMenu.state = .MSButtonNodeStateActive
        
        // show tips
        ponchoTalk()
//        showTip1(currentTip: acidLabel)
//        showTip2(currentTip: umbrellaLabel)
    }
    
  
    //MARK: Touches
    
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
        
        let touchLocation = touch.location(in: self)
//        if touchLocation.x > frame.maxX / 2 && touchLocation.y < 1100{
//            moveRight()
//        } else if touchLocation.x < frame.maxX / 2 && touchLocation.y < 1100{
//            moveLeft()
//        }
//
        if hero.position.x <= 150 && touchLocation.x < hero.position.x + hero.size.width && touchLocation.y < 1100 {
            moveLeft()
        } else if hero.position.x >= 600 && touchLocation.x > hero.position.x - hero.size.width && touchLocation.y < 1100 {
            moveRight()
        } else if touchLocation.x > hero.position.x && touchLocation.y < 1100{
            moveRight()
            highlightLeft.run(SKAction.moveTo(x: hero.position.x + 75, duration: 0.2))
            highlightRight.run(SKAction.moveTo(x: hero.position.x + 75, duration: 0.2))
        } else if touchLocation.x < hero.position.x && touchLocation.y < 1100{
            moveLeft()
            highlightLeft.run(SKAction.moveTo(x: hero.position.x - 75, duration: 0.2))
            highlightRight.run(SKAction.moveTo(x: hero.position.x - 75, duration: 0.2))
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: ---- Update Function ----
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Player is bounded to the frame
        keepPlayerInBounds()
        
    }
    
        //MARK: ---- Action Functions ----
        
        // Player Movements
        func moveRight() {
            
            let walkRight:SKAction = SKAction(named: "walkRight")!
            let moveRight = SKAction.moveBy(x: hero.size.width, y:0, duration:0.2)
            let moveRightAnimation = SKAction.group([walkRight, moveRight])
            
            if gameState != .active { return }
            
            hero.run(moveRightAnimation)
        }
        
        
        func moveLeft() {
            
            let walkLeft:SKAction = SKAction(named: "walkLeft")!
            let moveLeft = SKAction.moveBy(x: -hero.size.width, y:0, duration:0.2)
            let moveLeftAnimation = SKAction.group([walkLeft, moveLeft])
            
            if gameState != .active { return }
            
            hero.run(moveLeftAnimation)
        }
        
        
        // Keep Player in bounds
        func keepPlayerInBounds() {
            if hero.position.x < frame.minX + hero.size.width/2 {
                hero.position.x = frame.minX + hero.size.width/2
            }
            if hero.position.x > frame.maxX - hero.size.width/2 {
                hero.position.x = frame.maxX - hero.size.width/2
            }
        }
    
        
    //MARK: Helper Functions
    
    
    // button action to present scene
    func buttonPresentScene(sceneName: String) {
        // Grab reference to our SpriteKit view
        let skView = self.view as SKView?
        
        // Load Game scene
        let scene = GameScene(fileNamed:sceneName) as GameScene?
        
        // Ensure correct aspect mode
        scene?.scaleMode = .aspectFit
        
        // Present scene
        let transition = SKTransition.push(with: .down, duration: 1)
        skView?.presentScene(scene!, transition: transition)
//        skView?.presentScene(scene)
    }
    
    func showTip1(currentTip: SKLabelNode) {
//        let moveTipDown: SKAction = SKAction.moveTo(y: 960, duration: 2)
        let tipWait: SKAction = SKAction.wait(forDuration: 3)
//        let returnTip: SKAction = SKAction.moveTo(y: 1140, duration: 2)
        let tipFadeIn: SKAction = SKAction.fadeIn(withDuration: 2)
        let tipFadeOut: SKAction = SKAction.fadeOut(withDuration: 2)
        let tipActions: SKAction = SKAction.sequence([tipFadeIn, tipWait, tipFadeOut, tipWait, tipWait])
        
        currentTip.run(SKAction.repeatForever(tipActions))
    }
    
    func showTip2(currentTip: SKLabelNode) {
//        let moveTipDown: SKAction = SKAction.moveTo(y: 960, duration: 2)
        let tipWait: SKAction = SKAction.wait(forDuration: 3)
//        let returnTip: SKAction = SKAction.moveTo(y: 1140, duration: 2)
        let tipFadeIn: SKAction = SKAction.fadeIn(withDuration: 2)
        let tipFadeOut: SKAction = SKAction.fadeOut(withDuration: 2)
        let tipActions: SKAction = SKAction.sequence([tipWait, tipWait, tipFadeIn, tipWait, tipFadeOut])
        
        currentTip.run(SKAction.repeatForever(tipActions))
    }
    
    func ponchoTalk() {
        var speechArray: [String] = []
        speechArray.append("Hi! I'm Poncho")
        speechArray.append("Tap to my right to move right")
        speechArray.append("Tap to my left to move left")
        
        var speechIndex = 0
        
        let speechWait:SKAction = SKAction.wait(forDuration: 3)
        let speechFadeIn:SKAction = SKAction.fadeIn(withDuration: 1)
        let speechFadeOut:SKAction = SKAction.fadeOut(withDuration: 1)
        let speechChange:SKAction = SKAction.run {
            if speechIndex < 2 {
                speechIndex += 1
            } else {
                speechIndex = 0
            }
            self.ponchoSpeech.text = speechArray[speechIndex]
        }
        
        let speechActions:SKAction = SKAction.sequence([speechWait, speechFadeOut, speechChange, speechFadeIn])
        ponchoSpeech.run(SKAction.repeatForever(speechActions))
        
    }
    
}
