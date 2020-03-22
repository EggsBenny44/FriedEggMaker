//
//  GameScene.swift
//  fried-egg-maker
//
//  Created by yoyo on 2020-03-15.
//  Copyright © 2020 egga-benny.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let pos = 30.0
    let eggMaxCount = 10
    var lastPos = 0.0
    var floor: SKSpriteNode?
    var chef: SKSpriteNode?
    var center : CGFloat?
    var lives: [SKSpriteNode] = []
    var eggs: [SKSpriteNode] = []
    let textureLeft = SKTexture(imageNamed: "chef-left")
    let textureRight = SKTexture(imageNamed: "chef-right")
    let chefCategory: UInt32 = 0b0001
    let eggCategory: UInt32 = 0b0100
    let floorCategory: UInt32 = 0b1000
    
    private var repeatBirdAction : SKAction!
    private var rectBird : SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var timer: Timer?
    var eggsTimer: Timer?
    var eggsDuration: TimeInterval = 6.0 {
        didSet {
            if eggsDuration < 2.0 {
                eggsTimer?.invalidate()
            }
        }
    }

    
    override func didMove(to view: SKView) {
        
//        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        self.floor = SKSpriteNode(imageNamed: "floor")
//        self.floor!.xScale = 1.5
        self.floor!.yScale = 1.5
        self.floor!.position = CGPoint(x: 0, y: -frame.height / 2 + floor!.frame.height)
print (floor!.position)
        self.floor!.zPosition = -1.0
        self.floor!.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 100))
        self.floor!.physicsBody?.categoryBitMask = floorCategory
        self.floor!.physicsBody?.contactTestBitMask = eggCategory
        self.floor!.physicsBody?.collisionBitMask = 0
        self.floor!.physicsBody?.affectedByGravity = false
        addChild(self.floor!)
        

        self.chef = SKSpriteNode(imageNamed: "chef-left")
        self.chef!.scale(to: CGSize(width: frame.width / 5, height: frame.width / 4))
        self.chef!.position = CGPoint(x: 0, y: self.floor!.frame.maxY + 50)
        self.chef!.physicsBody = SKPhysicsBody(circleOfRadius: self.chef!.frame.width * 0.1)
        self.floor!.zPosition=100
        self.chef!.physicsBody?.categoryBitMask = chefCategory
        self.chef!.physicsBody?.contactTestBitMask = eggCategory
        self.chef!.physicsBody?.collisionBitMask = 0
        self.chef!.physicsBody?.affectedByGravity = false
        addChild(self.chef!)
        
        for i in 1...5 {
            let life = SKSpriteNode(imageNamed: "life")
            life.position = CGPoint(x: -frame.width / 2 + life.frame.height * CGFloat(i) + 100, y: frame.height / 2 - life.frame.height - 50)
            addChild(life)
            lives.append(life)
        }
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Papyrus"
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: -frame.width / 2 + scoreLabel.frame.width / 2 + 120, y: frame.height / 2 - scoreLabel.frame.height * 5)
        addChild(scoreLabel)
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        let bestScoreLabel = SKLabelNode(text: "Best Score: \(bestScore)")
        bestScoreLabel.fontName = "Papyrus"
        bestScoreLabel.fontSize = 30
        bestScoreLabel.position = scoreLabel.position.applying(CGAffineTransform(translationX: 0, y: -bestScoreLabel.frame.height * 1.5))
        addChild(bestScoreLabel)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.addEggs()
        })
//        eggsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
//            self.eggsDuration -= 0.5
//        })
        setRepeatBirdAction()

    }
    

    
    func setRepeatBirdAction() {
        let leftMoveAction = SKAction.move(to: CGPoint(x: self.frame.maxX + 50, y: 600), duration: 5.0)
        let rightMoveAction = SKAction.move(to: CGPoint(x: self.frame.minX - 50, y: 600), duration: 5.0)
        let textureLeft = SKTexture(imageNamed: "bird")
        let textureRight = SKTexture(imageNamed: "bird2")
        let setLeftTextureAction = SKAction.setTexture(textureLeft, resize: false)
        let setRightTextureAction = SKAction.setTexture(textureRight, resize: false)
        //        let delay = SKAction.wait(forDuration: TimeInterval(0.5))
        let sequenceAction = SKAction.sequence([setRightTextureAction, leftMoveAction, setLeftTextureAction, rightMoveAction])
        
        repeatBirdAction = SKAction.repeatForever(sequenceAction)
        rectBird = childNode(withName: "bird") as? SKSpriteNode
        rectBird.position = CGPoint(x: self.frame.maxX, y: 600)
        rectBird.run(repeatBirdAction)
    }
    func addEggs() {
        let egg = SKSpriteNode(imageNamed: "egg")
        egg.position = CGPoint(x: CGFloat((rectBird?.position.x)!), y: 450)
        addChild(egg)
        egg.physicsBody?.affectedByGravity = true
        egg.physicsBody = SKPhysicsBody(circleOfRadius: egg.frame.width)
        egg.physicsBody?.collisionBitMask = 0
        let beginingAction = SKAction.setTexture(SKTexture(imageNamed: "egg02"), resize: false)
        let breakAction = SKAction.setTexture(SKTexture(imageNamed: "egg03"), resize: false)
        let showAction = SKAction.setTexture(SKTexture(imageNamed: "egg04"), resize: false)
        let fallSingleAction = SKAction.setTexture(SKTexture(imageNamed: "egg06"), resize: false)
        let random = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        let delay = SKAction.wait(forDuration: TimeInterval(random))
        let delay2 = SKAction.wait(forDuration: TimeInterval(0.2))

        let sequenceAction = SKAction.sequence([beginingAction, delay, breakAction,delay2, showAction,delay2, fallSingleAction])
        egg.run(sequenceAction)
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches
//        {
//            let toucLocation = touch.location(in: self)
//            if toucLocation.x > center! {
//                chefLeft?.position.x = toucLocation.x
//                chefLeft?.isHidden = false
//                chefRight?.isHidden = true
//            }else{
//                chefRight?.position.x = toucLocation.x
//                chefRight?.isHidden = false
//                chefLeft?.isHidden = true
//            }
//        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    func createBackground() {
        
//        let backgroundTexture = SKTexture(imageNamed: "background")
//
//        for i in 0 ... 1 {
//
//            let background = SKSpriteNode(texture: backgroundTexture)
//
//            background.zPosition = -30
//
//            background.anchorPoint = CGPoint.zero
//
//            background.position = CGPoint(x: 0, y: (backgroundTexture.size().height * CGFloat(i)) - CGFloat(1 * i))
//
//            addChild(background)
        
//            let moveDown = SKAction.moveBy(x: 0, y: -backgroundTexture.size().height, duration: 20)
//            
//            let moveReset = SKAction.moveBy(x: 0, y: backgroundTexture.size().height, duration: 0)
//            
//            let moveLoop = SKAction.sequence([moveDown, moveReset])
//            
//            let moveForever = SKAction.repeatForever(moveLoop)
//            
//            background.run(moveForever)
//       　}
    }
}
