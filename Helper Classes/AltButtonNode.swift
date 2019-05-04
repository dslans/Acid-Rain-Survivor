//
//  AltButtonNode.swift
//  AcidRain_2
//
//  Created by Daniel Lans on 3/6/18.
//  Copyright © 2018 lessThanAlpha. All rights reserved.
//


import SpriteKit

enum AltButtonNodeState {
    case AltButtonNodeStateActive, AltButtonNodeStateSelected, AltButtonNodeStateHidden
}

class AltButtonNode: SKSpriteNode {
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    var state: AltButtonNodeState = .AltButtonNodeStateActive {
        didSet {
            switch state {
            case .AltButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true
                
                /* Visible */
                self.alpha = 0.7
                break
            case .AltButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 1
            case .AltButtonNodeStateHidden:
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
        state = .AltButtonNodeStateSelected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            selectedHandler()
            state = .AltButtonNodeStateActive
        } else {
            state = .AltButtonNodeStateActive
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
                state = .AltButtonNodeStateSelected
            } else {
                state = .AltButtonNodeStateActive
            }
        }
    }
    
    
}


