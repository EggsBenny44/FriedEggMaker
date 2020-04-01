//
//  BonusScene.swift
//  fried-egg-maker
//
//  Created by yoyo on 2020-03-26.
//  Copyright © 2020 egga-benny.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class BonusScene: SKScene, SKPhysicsContactDelegate {
    let pos = 30.0
    var lastPos = 0.0
    var floor: SKSpriteNode?
    var chef: SKSpriteNode?
    var lives: [SKSpriteNode] = []
    let textureLeft = SKTexture(imageNamed: "chef-left")
    let textureRight = SKTexture(imageNamed: "chef-right")
    let textureLeftCatch = SKTexture(imageNamed: "chef-left-catch")
    let textureRightCatch = SKTexture(imageNamed: "chef-right-catch")
    let textureFailedEgg = SKTexture(imageNamed: "egg08")
    
    let chefCategory: UInt32 =  0b0010
    let eggCategory: UInt32 =   0b0001
    let floorCategory: UInt32 = 0b1000
    let chickCategory: UInt32 = 0b0100
    let doubleEggCategory: UInt32 = 0b0011
    
    let getDoubleSound = SKAction.playSoundFileNamed("getdouble.mp3", waitForCompletion: false)
        
    private var repeatBirdAction1 : SKAction!
    private var repeatBirdAction2 : SKAction!
    private var rectBird1 : SKSpriteNode?
    private var rectBird2 : SKSpriteNode?
    
    var scoreLabel: SKLabelNode!
    var timer: Timer?
    var sceneTimer: Timer?

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(global_score)"
        }
    }
    var backgroundMusic = SKAudioNode()
    let musicURL = Bundle.main.url(forResource: "bgmbonus", withExtension: "mp3")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        self.size = view.bounds.size
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        self.floor = SKSpriteNode(imageNamed: "floor")
        self.floor!.yScale = 2
        self.floor!.position = CGPoint(x: 0, y: -frame.height / 2 + floor!.frame.height - 120)
        print (floor!.position)
        self.floor!.zPosition = -1.0
        self.floor!.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: floor!.frame.height))
        self.floor!.physicsBody?.categoryBitMask = floorCategory
        self.floor!.physicsBody?.contactTestBitMask = eggCategory + chickCategory
        self.floor!.physicsBody?.collisionBitMask = 0
        self.floor!.physicsBody?.affectedByGravity = false
        self.floor!.physicsBody?.allowsRotation = false
        self.floor!.physicsBody?.pinned = true
        
        addChild(self.floor!)
        
        self.chef = SKSpriteNode(imageNamed: "chef-left")
        self.chef!.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        self.chef!.position = CGPoint(x: 0, y: self.floor!.frame.maxY + self.chef!.frame.height / 2)
        self.chef!.physicsBody = SKPhysicsBody(circleOfRadius: self.chef!.frame.width * 0.1)
        
        self.chef!.physicsBody?.categoryBitMask = chefCategory
        self.chef!.physicsBody?.contactTestBitMask = eggCategory + chickCategory
        self.chef!.physicsBody?.collisionBitMask = 0
        self.chef!.physicsBody?.affectedByGravity = false
        self.chef!.physicsBody?.allowsRotation = false
        addChild(self.chef!)
        for i in 1...global_lives {
            let life = SKSpriteNode(imageNamed: "life")
            life.scale(to: CGSize(width: frame.width / 10, height: frame.width / 10))
            
            life.position = CGPoint(x: -frame.width / 2 + (life.frame.width * CGFloat(i)), y: frame.height / 2 - life.frame.height - 30)
            addChild(life)
            lives.append(life)
        }
        scoreLabel = SKLabelNode(text: "Score: \(global_score)")
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: -frame.width / 2 + scoreLabel.frame.width / 2 + 20, y: lives[0].frame.minY - scoreLabel.frame.height - 10)
        addChild(scoreLabel)
        
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        let bestScoreLabel = SKLabelNode(text: "Best Score: \(bestScore)")
        bestScoreLabel.fontName = "Chalkduster"
        bestScoreLabel.fontSize = 20
        bestScoreLabel.position = scoreLabel.position.applying(CGAffineTransform(translationX: 0, y: -bestScoreLabel.frame.height * 1.5))
        addChild(bestScoreLabel)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            self.addRandomEggs()
        })
        setRepeatBird1Action()
        setRepeatBird2Action()
        addChick()
        backgroundMusic = SKAudioNode(url: musicURL!)
        addChild(backgroundMusic)
        sceneTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(backToGameScene), userInfo: nil, repeats: false)
    }
    
    @objc private func backToGameScene() {
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let gameScene = SKScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view!.presentScene(gameScene!, transition: transition)
    }
    
    func setRepeatBird1Action() {
        self.rectBird1 = SKSpriteNode(imageNamed: "bird")
        self.rectBird1!.scale(to: CGSize(width: frame.width / 8, height: frame.width / 8))
        self.rectBird1!.position = CGPoint(x: self.frame.maxX + 5, y: scoreLabel.frame.minY - rectBird1!.frame.height - 50)
        
        self.rectBird1!.zPosition = 101
        addChild(self.rectBird1!)
        
        print("width:\(frame.width)")
        print("height:\(frame.height)")
        print("bird:\(self.rectBird1!.position)")
        
        let rightMoveAction = SKAction.move(to: CGPoint(x: self.frame.maxX - 5, y: rectBird1!.frame.minY), duration: 2.0)
        let leftMoveAction = SKAction.move(to: CGPoint(x: self.frame.minX + 5, y: rectBird1!.frame.minY), duration: 2.0)
        let textureLeft = SKTexture(imageNamed: "bird")
        let textureRight = SKTexture(imageNamed: "bird2")
        let setLeftTextureAction = SKAction.setTexture(textureLeft, resize: false)
        let setRightTextureAction = SKAction.setTexture(textureRight, resize: false)
        let sequenceAction = SKAction.sequence([ setLeftTextureAction , leftMoveAction, setRightTextureAction, rightMoveAction])
        
        repeatBirdAction1 = SKAction.repeatForever(sequenceAction)
        
        rectBird1!.run(repeatBirdAction1)
    }
    
    func setRepeatBird2Action() {
        self.rectBird2 = SKSpriteNode(imageNamed: "bird2")
        self.rectBird2!.scale(to: CGSize(width: frame.width / 8, height: frame.width / 8))
        self.rectBird2!.position = CGPoint(x: self.frame.minX - 5, y: scoreLabel.frame.minY - rectBird2!.frame.height - 100)
        
        self.rectBird2!.zPosition = 101
        addChild(self.rectBird2!)
        
        print("width:\(frame.width)")
        print("height:\(frame.height)")
        print("bird:\(self.rectBird2!.position)")
        
        let rightMoveAction = SKAction.move(to: CGPoint(x: self.frame.maxX - 5, y: rectBird2!.frame.minY), duration: 1.0)
        let leftMoveAction = SKAction.move(to: CGPoint(x: self.frame.minX + 5, y: rectBird2!.frame.minY), duration: 1.0)
        let textureLeft = SKTexture(imageNamed: "bird")
        let textureRight = SKTexture(imageNamed: "bird2")
        let setLeftTextureAction = SKAction.setTexture(textureLeft, resize: false)
        let setRightTextureAction = SKAction.setTexture(textureRight, resize: false)
        let sequenceAction = SKAction.sequence([setRightTextureAction, rightMoveAction, setLeftTextureAction, leftMoveAction])
        
        repeatBirdAction2 = SKAction.repeatForever(sequenceAction)
        
        rectBird2!.run(repeatBirdAction2)
    }
    
    func addRandomEggs() {
        addDoubleEgg(posX: (rectBird1?.position.x)!, posY: (rectBird1?.frame.minY)!)
        addDoubleEgg(posX: (rectBird2?.position.x)!, posY: (rectBird2?.frame.minY)!)
    }
    
    func addChick() {
        for i in 1...25 {
            let chick = SKSpriteNode(imageNamed: "chick")
            chick.scale(to: CGSize(width: frame.width / 15, height: frame.width / 15))
            chick.position = CGPoint(x: frame.maxX + 10, y: frame.height / 2 - 300 - chick.frame.height - CGFloat(i * 10))
            addChild(chick)
            let rnd = Double.random(in: 0.2..<0.9)
            let move = SKAction.moveTo(x: frame.minX - 10, duration: 1.0 + rnd*2)
            let remove = SKAction.removeFromParent()
            let sequenceAction = SKAction.sequence([move, remove])
            chick.run(sequenceAction)
        }
    }
    
    func addDoubleEgg(posX: CGFloat, posY: CGFloat) {
        let egg = SKSpriteNode(imageNamed: "egg")
        egg.position = CGPoint(x: posX, y: posY - egg.frame.height / 2)
        egg.scale(to: CGSize(width: frame.width / 18, height: frame.width / 18))
        egg.physicsBody = SKPhysicsBody(circleOfRadius: egg.frame.width)
        egg.physicsBody?.categoryBitMask = doubleEggCategory
        egg.physicsBody?.contactTestBitMask = floorCategory + chefCategory
        egg.physicsBody?.collisionBitMask = 0
        addChild(egg)
        
        let beginingAction = SKAction.setTexture(SKTexture(imageNamed: "egg02"), resize: false)
        let breakAction = SKAction.setTexture(SKTexture(imageNamed: "egg03"), resize: false)
        var sequenceAction: SKAction
        let rndMove = Int.random(in: 2..<5)
        let delay = SKAction.moveTo(y: egg.frame.minY - egg.frame.height * CGFloat(rndMove), duration: 0.1)
        
        let showAction = SKAction.setTexture(SKTexture(imageNamed: "egg05"), resize: false)
        let fallSingleAction = SKAction.setTexture(SKTexture(imageNamed: "egg07"), resize: false)
        let rndFall = Double.random(in: 1.0 ..< 2.0)
        let move = SKAction.moveTo(y: -frame.height / 2 - egg.frame.height, duration: rndFall)
        let remove = SKAction.removeFromParent()
        sequenceAction = SKAction.sequence([beginingAction, SKAction.wait(forDuration: 0.1), breakAction, delay, showAction, SKAction.wait(forDuration: 0.2), fallSingleAction, move, remove])
        
        egg.run(sequenceAction)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var first: SKPhysicsBody
        var second: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == eggCategory || contact.bodyA.categoryBitMask == chickCategory {
            first = contact.bodyA
            second = contact.bodyB
        } else {
            first = contact.bodyB
            second = contact.bodyA
        }
        
        guard let firstNode = first.node else { return }
        guard let secondNode = second.node else { return }
        
        if second.categoryBitMask == chefCategory {
            if first.categoryBitMask == doubleEggCategory {
                
                var updateTextureAction: SKAction
                var undoTextureAction: SKAction
                if self.chef?.texture == textureLeft {
                    updateTextureAction = SKAction.setTexture(textureLeftCatch, resize: false)
                    undoTextureAction = SKAction.setTexture(textureLeft, resize: false)
                } else {
                    updateTextureAction = SKAction.setTexture(textureRightCatch, resize: false)
                    undoTextureAction = SKAction.setTexture(textureRight, resize: false)
                }
                let delay = SKAction.wait(forDuration: TimeInterval(1.0))
                let sequenceAction = SKAction.sequence([updateTextureAction, delay, undoTextureAction])
                secondNode.run(sequenceAction)
                
                firstNode.removeFromParent()
                if first.categoryBitMask == doubleEggCategory {
                    guard let success = SKEmitterNode(fileNamed: "success") else { return }
                    success.position = firstNode.position
                    addChild(success)
                    secondNode.run(getDoubleSound)
                    self.run(SKAction.wait(forDuration: 1.0)) {
                        success.removeFromParent()
                    }
                }
                global_score += 30
                score = global_score
            }
        } else if second.categoryBitMask == floorCategory {
            firstNode.removeFromParent()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let toucLocation = touch.location(in: self)
            if toucLocation.x <= CGFloat(lastPos) {
                lastPos -= pos
                chef?.texture = textureLeft
            }else{
                lastPos += pos
                chef?.texture = textureRight
            }
            chef?.position.x = CGFloat(lastPos)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let toucLocation = touch.location(in: self)
            if toucLocation.x <= CGFloat(lastPos) {
                lastPos -= pos
                chef?.texture = textureLeft
            }else{
                lastPos += pos
                chef?.texture = textureRight
            }
            chef?.position.x = CGFloat(lastPos)
        }
    }
    
}
