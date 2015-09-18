//
//  Extensions.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//

//import Foundation
import SwiftyJSON

extension JSON {
    static func loadJSONFromBundle(filename: String) -> JSON? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return JSON(data: data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}



import SpriteKit

let Radius: CGFloat = 15.0

extension SKShapeNode {
    
    static func setup(dot: Dot, position: CGPoint) -> SKShapeNode {
        let shapeNode = SKShapeNode(circleOfRadius: Radius)
        shapeNode.fillColor = dot.properColor
        shapeNode.position = position
        dot.sprite = shapeNode
        return shapeNode
    }
    
    func removeAnimation () {
        self.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(0.25, withRange: 0.5),
                SKAction.group([
                    SKAction.fadeOutWithDuration(0.25),
                    SKAction.scaleTo(0.0, duration: 0.25)
                    ])
                ]))
    }
    
    func appearenceAnimation() {
        self.alpha = 0
        self.xScale = 0.5
        self.yScale = 0.5
        
        self.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(0.25, withRange: 0.5),
                SKAction.group([
                    SKAction.fadeInWithDuration(0.25),
                    SKAction.scaleTo(1.0, duration: 0.25)
                    ])
                ]))
    }
    
    func animateMatches() {
        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
        scaleAction.timingMode = .EaseOut
        self.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
    }
    
    
    func animateNewDot(dot: Dot, startRow: Int, totalLength: Int) -> NSTimeInterval {
        
        let delay = 0.1 + 0.2 * NSTimeInterval(totalLength - 1)
        
        let duration = NSTimeInterval(startRow - dot.row) * 0.1
        
        let newPosition = pointForColumn(dot.column, row: dot.row)
        let moveAction = SKAction.moveTo(newPosition, duration: duration)
        moveAction.timingMode = .EaseOut
        self.alpha = 0
        self.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(delay),
                SKAction.group([
                    SKAction.fadeInWithDuration(0.05),
                    moveAction
                    ])]))
        
        return duration + delay
    }
    
    func animateFalling(dot: Dot, idx: Int) -> NSTimeInterval {
        
        let newPosition = pointForColumn(dot.column, row: dot.row)
        let delay = 0.05 + 0.15 * NSTimeInterval(idx)
        
        let duration = NSTimeInterval(((self.position.y - newPosition.y) / TileHeight) * 0.1)
        let moveAction = SKAction.moveTo(newPosition, duration: duration)
        moveAction.timingMode = .EaseOut
        self.runAction(
            SKAction.sequence([
                SKAction.waitForDuration(delay),
                moveAction]))
        
        return duration + delay
    }
}
