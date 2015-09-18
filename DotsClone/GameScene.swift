//
//  GameScene.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright (c) 2015 Conjure. All rights reserved.
//

import SpriteKit



func pointForColumn(column: Int, row: Int) -> CGPoint {
    return CGPointMake(
        CGFloat(column) * TileWidth + TileWidth/2,
        CGFloat(row) * TileHeight + TileHeight/2
    )
}

func convertPointInGrid(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    if  point.x >= 0 &&
        point.x < CGFloat(NumColumns) * TileWidth &&
        point.y >= 0 &&
        point.y < CGFloat(NumRows)*TileHeight
    {
        return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
    } else {
        return (false, 0, 0)  // invalid location
    }
}

protocol GameSceneDelegate {
    func didFindMatches()
    func didSetNewScore(score: Int)
}


let TileWidth: CGFloat = 35.0
let TileHeight: CGFloat = 35.0
let SpriteSize: CGFloat = 15.0

class GameScene: SKScene {

    var level: Level!
    var gameDelegate: GameSceneDelegate?

    let gameLayer = SKNode()
    let dotsLayer = SKNode()
    
    var chain = Chain()
    
    var pathToDraw: CGMutablePathRef?
    var lineNode: SKShapeNode?
    var startPoint: CGPoint?
    var endPoint:   CGPoint?
    
    var square: Bool = false
    
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(gameLayer)
        
        dotsLayer.position = CGPoint(x: -TileWidth * CGFloat(NumColumns) / 2, y: -TileHeight * CGFloat(NumRows) / 2)
        gameLayer.addChild(dotsLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
        if chain.length >= 1 {
            setLine()
        }
    }
}

//MARK:
//MARK: Touch methods
extension GameScene {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let location = touch!.locationInNode(dotsLayer)
        let (success, column, row) = convertPointInGrid(location)

        if success, let dot = level.dotAtPosition(column: column, row: row) {
            chain.addDot(dot)
            startPoint = dot.sprite?.position
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        if chain.length > 0 {
            let touch = touches.first
            endPoint = touch!.locationInNode(dotsLayer)
            
            let (success, column, row) = convertPointInGrid(endPoint!)
            if success, let dot = level.dotAtPosition(column: column, row: row) {
                
                // TODO: this logic needs to be refactored
                if dot.canBeConnected(chain.lastDot()) && chain.firstDot().color == dot.color {
                    if chain.length > 1 && dot != chain.dots[chain.length - 2] {
                        square = chain.dots.contains(dot)
                        chain.addDot(dot)
                    } else if chain.length > 1 && dot == chain.dots[chain.length - 2] {
                        square = false
                        chain.removeLastDot()
                    } else if chain.length == 1 {
                        chain.addDot(dot)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.lineNode?.removeFromParent()
        if chain.length > 1 {
            handleMatches { self.cleanChains() }
        } else {
            cleanChains()
        }
    }
    
    func handleMatches(completion: () -> ()) {
        if square {
            let coloredDots = level.getAllDotsFromColor(chain.firstDot().color)
            chain.addDots(coloredDots)
        }
        level.removeDots(chain)
        chain.calculateScores()
        if let del = self.gameDelegate {
            del.didSetNewScore(chain.score)
        }
        animateMatchedDots(chain) {
            let columns = self.level.fillHoles()
            self.animateFallingDots(columns) {
                let columns = self.level.topUpDots()
                self.animateNewDots(columns) {
                    if let del = self.gameDelegate {
                        del.didFindMatches()
                    }
                    completion()
                }
            }
        }
    }
}

//MARK:
//MARK: Lauyout methods
extension GameScene {
    private func setLine() {
        if lineNode == nil {
            lineNode = SKShapeNode()
            lineNode!.strokeColor = chain.firstDot().color.color
            lineNode!.lineWidth = 10
            dotsLayer.addChild(lineNode!)
        }
        
        pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw!, nil, startPoint!.x, startPoint!.y)

        for dot in chain.dots {
            CGPathAddLineToPoint(pathToDraw!, nil, (dot.sprite?.position.x)!, (dot.sprite?.position.y)!)
        }

        if let ePoint = endPoint {
            CGPathAddLineToPoint(pathToDraw!, nil, ePoint.x, ePoint.y)
        }
        
        lineNode!.path = pathToDraw
    }
    
    func addSpritesForDots(dots: Set<Dot>) {
        for dot in dots {
            addSpriteForDot(dot, position: pointForColumn(dot.column, row:dot.row)).appearenceAnimation()
        }
    }
    
    private func addSpriteForDot(dot: Dot, position: CGPoint) -> SKShapeNode{
        let sprite = SKShapeNode.setup(dot, position: position)
        dotsLayer.addChild(sprite)
        return sprite
    }
    
    func removeAllDots(completion: () -> ()) {
        
        for sprite: SKShapeNode in dotsLayer.children as! [SKShapeNode] {
            sprite.removeAnimation()
        }
        
        runAction(SKAction.waitForDuration(1.0)) {
            self.dotsLayer.removeAllChildren()
            completion()
        }

    }
    
}


//MARK:
//MARK: Animations
extension GameScene {
    
    func animateMatchedDots(chain: Chain, completion: () -> ()) {
        for dot in chain.dots {
            if let sprite = dot.sprite where sprite.actionForKey("removing") == nil {
                sprite.animateMatches()
            }
        }
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    func animateFallingDots(columns: [[Dot]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, dot) in array.enumerate() {
                let totalDuration = dot.sprite!.animateFalling(dot, idx: idx)

                longestDuration = max(longestDuration, totalDuration)
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateNewDots(columns: [[Dot]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            let startRow = array[0].row + 1
            
            for (idx, dot) in array.enumerate() {
                
                let sprite = addSpriteForDot(dot, position: pointForColumn(dot.column, row: startRow))
                let totalDuration = sprite.animateNewDot(dot, startRow: startRow, totalLength: array.count - idx)

                longestDuration = max(longestDuration, totalDuration)
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
}


//MARK:
//MARK: Utilities
extension GameScene {
    
    func cleanChains() {
        self.chain.empty()
        
        self.pathToDraw  = nil
        self.lineNode    = nil
        self.startPoint  = nil
        self.endPoint    = nil
        self.square      = false
    }
}

