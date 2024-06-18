//
//  GameScene.swift
//  SpracyShooter
//
//  Created by stenio Lima on 18/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
    }
 
}
