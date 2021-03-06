//
//  MSButtonNode.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/6/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//


import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden
}

class MSButtonNode: SKSpriteNode {
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    var state: MSButtonNodeState = .MSButtonNodeStateActive {
        didSet {
            switch state {
            case .MSButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true
                
                /* Visible */
                self.alpha = 1
                break
            case .MSButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 0.7
            case .MSButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                
                /* Hide */
                self.alpha = 0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .MSButtonNodeStateSelected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            selectedHandler()
            state = .MSButtonNodeStateActive
        } else {
            state = .MSButtonNodeStateActive
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

//        let touch: AnyObject! = touches.first
//        let touchLocation = touch.location(in: parent!)
//
//        if (frame.contains(touchLocation)) {
//            state = .MSButtonNodeStateSelected
//        } else {
//            state = .MSButtonNodeStateActive
//        }
        
        for t in touches { self.touchMoved(toPoint: t.location(in: self))
            let touchLocation = t.location(in: parent!)
            if (frame.contains(touchLocation)) {
                state = .MSButtonNodeStateSelected
            } else {
                state = .MSButtonNodeStateActive
            }
        }
    }
    
    
}

