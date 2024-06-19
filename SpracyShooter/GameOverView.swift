//
//  GameOverView.swift
//  SpracyShooter
//
//  Created by stenio Lima on 19/06/24.
//

import Foundation
import SpriteKit

class GameOverView: SKScene {
    
    let restartLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode()
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontName = "Chalkduster"
        gameOverLabel.fontColor = .white
        gameOverLabel.fontSize = 100
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
            
        let scoreLabel = SKLabelNode()
        scoreLabel.text = "Socre: \(gameScore)"
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 85
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highSocreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highSocreNumber{
            highSocreNumber = gameScore
            defaults.set(highSocreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode()
        highScoreLabel.text = "High Socre: \(highSocreNumber)"
        highScoreLabel.fontName = "Chalkduster"
        highScoreLabel.fontColor = .white
        highScoreLabel.fontSize = 85
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Restart"
        restartLabel.fontName = "Chalkduster"
        restartLabel.fontColor = .white
        restartLabel.fontSize = 50
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
