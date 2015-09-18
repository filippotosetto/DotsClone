//
//  GameViewController.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright (c) 2015 Conjure. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate{

    var scene: GameScene!
    
    var level: Level!
    
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverLavel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.backgroundColor = UIColor.whiteColor()
        scene.scaleMode = .AspectFill
        scene.gameDelegate = self
        
        level = Level(fileName: "Level_0")
        scene.level = level
        
        // Present the scene.
        skView.presentScene(scene)
        
        
        beginGame()

    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    @IBAction func restartAction(sender: AnyObject) {
        level.cleanDots()
        scene.removeAllDots() {
            self.beginGame()
        }

    }
    
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0

        gameOverLavel.hidden = true
        restartButton.hidden = true

        updateLabels()
        shuffle()
    }
    
    func shuffle() {
        scene.addSpritesForDots(level.shuffle())
    }
    
    func didSetNewScore(score: Int) {
        self.score += score
    }
    
    func didFindMatches() {
        --movesLeft
        updateLabels()
        
        if score >= level.targetScore {
            gameOverLavel.text = "YOU WIN"
            gameOverLavel.hidden = false
            restartButton.hidden = false
        } else if movesLeft == 0 {
            gameOverLavel.text = "GAME OVER"
            gameOverLavel.hidden = false
            restartButton.hidden = false
        }
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
}
