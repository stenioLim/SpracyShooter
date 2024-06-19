//
//  GameScene.swift
//  SpracyShooter
//
//  Created by stenio Lima on 18/06/24.

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    

    var scoreLabel = SKLabelNode()
    
    var livesNumber = 3
    var livesLabel = SKLabelNode()
    
    var levels = 0
    
    let bulletSound = SKAction.playSoundFileNamed("whizzby-41134", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSound", waitForCompletion: false)
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let tapToStartLabel = SKLabelNode()
    // statudo do game, para podermos modificar telas
    enum gameState {
        case preGame
        case inGame
        case afterGame
    }
    var currentGameState = gameState.preGame
    
    // estura fisica 
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //3
        
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    var gameArea: CGRect
    
    override init(size: CGSize){
        let  maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        
        
        self.physicsWorld.contactDelegate = self
        //BUILDING BAKCGROUND SCENE
        
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        // BUILDING PLAYER
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.25, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        
        livesLabel.text = "Lives"
        livesLabel.fontName = "Chalkduster"
        livesLabel.fontSize = 70
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.75, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y:self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontName = "Chalkduster"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = .white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime : TimeInterval = 0
    var deltaFramTime : TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else{
            deltaFramTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFramTime)
        
        self.enumerateChildNodes(withName: "Background"){background,stop in
            background.position.y -= amountToMoveBackground
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
            
        }
        
    }
    //começando o jogo
    func startGame(){
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    //somatorias de vida
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives\(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    //somatoria de pontos
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
    }
    
    // mudando de cena quando o a pessoa perde
    
    func changeScene(){
        let sceneToMoveTo = GameOverView(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: transition)
        
    }
    // game over
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "bullet"){ bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "enemy"){ enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitChanceScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitChanceScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        
        }else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        // se o jogador acerta o inimigo
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            if body1.node != nil {
                spwnExplosion(spawPosition: body1.node!.position)
            }
            if body2.node != nil {
                spwnExplosion( spawPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            runGameOver()
        }
        // se o tiro acerta o inimigo ele some
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            addScore()
            if body2.node != nil {
                spwnExplosion(spawPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
        }
    }
    // explosão efeito
    func spwnExplosion(spawPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequece = SKAction.sequence([explosionSound,scaleIn, fadeOut, delete])
        explosion.run(explosionSequece)
    }
    
    // mudando nivel de dificildade baseando no tempo jogando
    func startNewLevel(){
        
        levels += 1
        
        if self.action(forKey: "spawningEmies") != nil{
            self.removeAction(forKey: "spawningEmies")
        }
        
        var levelDuration = TimeInterval()
        switch levels {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEmies")
    }
    
    
    
    
 // construindo o tiro
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1 )
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound ,moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    // construindo o inimigo
    func spawEnemy(){
        let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        // pequenas movimentações que o inimigo consegue fazer na tela
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //tela de start
        if currentGameState == gameState.preGame {
            startGame()
        }
        // jogo
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
        
        
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch : AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            
            
           
            
        }
    }
    
}



    
