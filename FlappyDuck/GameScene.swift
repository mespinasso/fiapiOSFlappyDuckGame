//
//  GameScene.swift
//  FlappyDuck
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 fiap. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameArea: CGFloat = 410.0
    var floor: SKSpriteNode!
    var velocity: Double = 100.0
    var flyForce: CGFloat = 30.0
    var intro: SKSpriteNode!
    var player: SKSpriteNode!
    var gameStarted: Bool = false
    var gameFinished: Bool = false
    var restart: Bool = false
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var timer: Timer!
    
    let playerCategory: UInt32 = 1
    let pipeCategory: UInt32 = 2
    let scoreCategory: UInt32 = 4
    
    let scoreSound = SKAction.playSoundFileNamed("pontuou.mp3", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("bateu.mp3", waitForCompletion: false)
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        addBackground()
        addFloor()
        moveFloor()
        addIntro()
        addPlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted {
            let yVelocity = player.physicsBody!.velocity.dy * 0.001 as CGFloat
            player.zRotation = yVelocity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameFinished {
            
            if !gameStarted {
                //Começar o jogo
                intro.removeFromParent()
                addScore()
                player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2 - 10)
                player.physicsBody?.isDynamic = true
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
                player.physicsBody?.categoryBitMask = playerCategory
                player.physicsBody?.contactTestBitMask = scoreCategory
                player.physicsBody?.collisionBitMask = pipeCategory
                
                gameStarted = true
                
                timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true, block: { (timer) in
                    
                    let initialPosition = CGFloat(arc4random_uniform(132) + 74)
                    let pipesDistance = self.player.size.height * 3
                    
                    let upperPipe = SKSpriteNode(imageNamed: "CanoCima")
                    upperPipe.position = CGPoint(x: self.size.width + upperPipe.size.width/2, y: self.size.height - initialPosition + upperPipe.size.height/2)
                    upperPipe.zPosition = 1
                    upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
                    upperPipe.physicsBody?.isDynamic = false
                    upperPipe.physicsBody?.categoryBitMask = self.pipeCategory
                    upperPipe.physicsBody?.contactTestBitMask = self.playerCategory
                    
                    let bottomPipe = SKSpriteNode(imageNamed: "CanoBaixo")
                    bottomPipe.position = CGPoint(x: self.size.width + bottomPipe.size.width/2, y: upperPipe.position.y - upperPipe.size.height - pipesDistance)
                    bottomPipe.zPosition = 1
                    bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
                    bottomPipe.physicsBody?.isDynamic = false
                    bottomPipe.physicsBody?.categoryBitMask = self.pipeCategory
                    bottomPipe.physicsBody?.contactTestBitMask = self.playerCategory
                    
                    let laser = SKNode()
                    laser.position = CGPoint(x: upperPipe.position.x + upperPipe.size.width/2, y: upperPipe.position.y - upperPipe.size.height/2 - pipesDistance/2)
                    laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipesDistance))
                    laser.physicsBody?.isDynamic = false
                    laser.physicsBody?.categoryBitMask = self.scoreCategory
                    
                    let distance = self.size.width + upperPipe.size.width
                    let duration = Double(distance) / self.velocity
                    let pipeMoveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
                    let removeAction = SKAction.removeFromParent()
                    let sequenceAction = SKAction.sequence([pipeMoveAction, removeAction])
                    
                    upperPipe.run(sequenceAction)
                    bottomPipe.run(sequenceAction)
                    laser.run(sequenceAction)
                    
                    self.addChild(upperPipe)
                    self.addChild(bottomPipe)
                    self.addChild(laser)
                })
                
            } else {
                //Fazer o patinho voar
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: flyForce))
            }
            
        } else {
            if restart {
                restart = false
                
                let scene = GameScene(size: CGSize(width: gameWidth, height: gameHeight))
                scene.scaleMode = .aspectFill
                view!.presentScene(scene, transition: .doorway(withDuration: 1))
            }
        }
    }
    
    func addScore() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 94
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        scoreLabel.alpha = 0.8
        scoreLabel.zPosition = 5
        
        addChild(scoreLabel)
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "Fundo")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height - background.size.height/2)
        background.zPosition = 0
        
        addChild(background)
    }
    
    func addFloor() {
        floor = SKSpriteNode(imageNamed: "Chao")
        floor.position = CGPoint(x: floor.size.width/2, y: size.height - gameArea - floor.size.height/2)
        floor.zPosition = 2
        
        addChild(floor)
        
        let invisibleFloor = SKNode()
        invisibleFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleFloor.physicsBody?.isDynamic = false
        invisibleFloor.physicsBody?.categoryBitMask = pipeCategory
        invisibleFloor.physicsBody?.contactTestBitMask = playerCategory
        invisibleFloor.position = CGPoint(x: size.width/2, y: size.height - gameArea)
        invisibleFloor.zPosition = 2
        
        addChild(invisibleFloor)
        
        let invisibleRoof = SKNode()
        invisibleRoof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        invisibleRoof.physicsBody?.isDynamic = false
        invisibleRoof.position = CGPoint(x: size.width/2, y: size.height)
        invisibleRoof.zPosition = 2
        
        addChild(invisibleRoof)
    }
    
    func moveFloor() {
        let duration = Double(floor.size.width/2)/velocity
        let moveFloorAction = SKAction.moveBy(x: -floor.size.width/2, y: 0, duration: duration)
        let resetXAction = SKAction.moveBy(x: floor.size.width/2, y: 0, duration: 0)
        let sequenceAction = SKAction.sequence([moveFloorAction, resetXAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        
        floor.run(repeatAction)
    }
    
    func addIntro() {
        intro = SKSpriteNode(imageNamed: "Intro")
        intro.position = CGPoint(x: size.width/2, y: size.height - 210)
        intro.zPosition = 3
        
        addChild(intro)
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Pato1")
        player.position = CGPoint(x: 60, y: size.height - gameArea/2)
        player.zPosition = 4
        
        var playerTextures = [SKTexture]()
        for i in 1..<4 {
            playerTextures.append(SKTexture(imageNamed: "Pato\(i)"))
        }
        
        let animationAction = SKAction.animate(with: playerTextures, timePerFrame: 0.09)
        let repeatAction = SKAction.repeatForever(animationAction)
        player.run(repeatAction)
        
        addChild(player)
    }
    
    func gameOver() {
        timer.invalidate()
        player.zRotation = 0
        player.texture = SKTexture(imageNamed: "PatoBateu")
        
        for node in self.children {
            node.removeAllActions()
        }
        
        player.physicsBody?.isDynamic = false
        gameFinished = true
        gameStarted = false
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
            gameOverLabel.fontColor = .red
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over"
            gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            gameOverLabel.zPosition = 5
            
            self.addChild(gameOverLabel)
            self.restart = true
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameStarted {
            if contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory {
                score += 1
                scoreLabel.text = "\(score)"
                run(scoreSound)
            } else if contact.bodyA.categoryBitMask == pipeCategory || contact.bodyB.categoryBitMask == pipeCategory {
                gameOver()
                run(gameOverSound)
            }
        }
    }
}
