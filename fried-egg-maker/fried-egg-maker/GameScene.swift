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
    var lastPos = 0.0
    var floor: SKSpriteNode?
    var chef: SKSpriteNode?
    var lives: [SKSpriteNode] = []
    var bonusCount = 0;
    var isBonus = false;
    let textureLeft = SKTexture(imageNamed: "chef-left")
    let textureRight = SKTexture(imageNamed: "chef-right")
    let textureLeftCatch = SKTexture(imageNamed: "chef-left-catch")
    let textureRightCatch = SKTexture(imageNamed: "chef-right-catch")
    let textureBarnedChick = SKTexture(imageNamed: "barned-chick")
    let textureFailedEgg = SKTexture(imageNamed: "egg08")

    let chefCategory: UInt32 =  0b0010
    let eggCategory: UInt32 =   0b0001
    let floorCategory: UInt32 = 0b1000
    let chickCategory: UInt32 = 0b0100
    let doubleEggCategory: UInt32 = 0b0011
    let goldEggCategory: UInt32 = 0b0111

    let bgmSound = SKAction.playSoundFileNamed("bgmgame.mp3", waitForCompletion: false)
    let barnChickSound = SKAction.playSoundFileNamed("barnchick.mp3", waitForCompletion: false)
    let getDoubleSound = SKAction.playSoundFileNamed("getdouble.mp3", waitForCompletion: false)
    let getBonusSound = SKAction.playSoundFileNamed("getbonus.mp3", waitForCompletion: false)
    let failSound = SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: false)

    var gameVC: GameViewController!
    var eggsTimer: Timer?
    var eggsDuration: TimeInterval = global_eggInterval {
        didSet {
            if eggsDuration < 2.0 {
                eggsTimer?.invalidate()
            }
            global_eggInterval = eggsDuration
        }
    }
    private var repeatBirdAction : SKAction!
    private var rectBird : SKSpriteNode?
    var scoreLabel: SKLabelNode!
    var timer: Timer?

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(global_score)"
        }
    }
    var backgroundMusic = SKAudioNode()
    let musicURL = Bundle.main.url(forResource: "bgmgame", withExtension: "mp3")

    override func didMove(to view: SKView) {
        bonusCount = global_score
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        physicsWorld.contactDelegate = self
        self.size = view.bounds.size
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        self.floor = SKSpriteNode(imageNamed: "floor")
        self.floor!.yScale = 2
        self.floor!.position = CGPoint(x: 0, y: -frame.height / 2 + floor!.frame.height - 120)
        self.floor!.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: floor!.frame.width, height: floor!.frame.height - 10))
        self.floor!.physicsBody?.categoryBitMask = floorCategory
        self.floor!.physicsBody?.contactTestBitMask = eggCategory + chickCategory
        self.floor!.physicsBody?.collisionBitMask = 0
        self.floor!.physicsBody?.affectedByGravity = false
        self.floor!.physicsBody?.allowsRotation = false
        self.floor!.physicsBody?.pinned = true
        self.floor!.zPosition = -100

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
        bestScoreLabel.position = scoreLabel.position.applying(CGAffineTransform(translationX: 5, y: -bestScoreLabel.frame.height * 1.5))
        addChild(bestScoreLabel)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.addRandomEggs()
        })
        eggsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
            self.eggsDuration -= 0.5
        })
        setRepeatBirdAction()
        backgroundMusic = SKAudioNode(url: musicURL!)
        addChild(backgroundMusic)
    }
    
    func setRepeatBirdAction() {
        self.rectBird = SKSpriteNode(imageNamed: "bird")
        self.rectBird!.scale(to: CGSize(width: frame.width / 8, height: frame.width / 8))
        self.rectBird!.position = CGPoint(x: self.frame.maxX + 5, y: scoreLabel.frame.minY - rectBird!.frame.height - 50)

        self.rectBird!.zPosition = 101
        addChild(self.rectBird!)

        let rightMoveAction = SKAction.move(to: CGPoint(x: self.frame.maxX - 5, y: rectBird!.frame.minY), duration: 5.0)
        let leftMoveAction = SKAction.move(to: CGPoint(x: self.frame.minX + 5, y: rectBird!.frame.minY), duration: 5.0)
        let textureLeft = SKTexture(imageNamed: "bird")
        let textureRight = SKTexture(imageNamed: "bird2")
        let setLeftTextureAction = SKAction.setTexture(textureLeft, resize: false)
        let setRightTextureAction = SKAction.setTexture(textureRight, resize: false)
        let sequenceAction = SKAction.sequence([ setLeftTextureAction , leftMoveAction, setRightTextureAction, rightMoveAction])

        repeatBirdAction = SKAction.repeatForever(sequenceAction)

        rectBird!.run(repeatBirdAction)
    }
    
    func addRandomEggs() {
        if isBonus {
            addGoldEgg()
            isBonus = false;
        } else {
            let rnd = Int.random(in: 0..<30)
            if rnd % 10 == 0 {
                addChick()
            } else if rnd % 13 == 0 {
                addDoubleEgg()
            } else {
                addSingleEgg()
            }
        }
        if global_score - bonusCount > 20 {
            bonusCount = global_score
            isBonus = true
        }
    }

    func addChick() {
        let chick = SKSpriteNode(imageNamed: "egg")
        chick.position = CGPoint(x: CGFloat((rectBird?.position.x)!), y: (rectBird?.frame.minY)! - chick.frame.height / 2)
        chick.scale(to: CGSize(width: frame.width / 15, height: frame.width / 15))
        chick.physicsBody = SKPhysicsBody(circleOfRadius: chick.frame.width)
        chick.physicsBody?.categoryBitMask = chickCategory
        chick.physicsBody?.contactTestBitMask = floorCategory + chefCategory
        chick.physicsBody?.collisionBitMask = 0
        chick.zPosition = 10
        addChild(chick)
        
        let beginingAction = SKAction.setTexture(SKTexture(imageNamed: "egg02"), resize: false)
        let breakAction = SKAction.setTexture(SKTexture(imageNamed: "egg03"), resize: false)
        var sequenceAction: SKAction
        let rndMove = Int.random(in: 2..<5)
        let delay = SKAction.moveTo(y: chick.frame.minY - chick.frame.height * CGFloat(rndMove), duration: 0.1)
        let fallChickAction = SKAction.setTexture(SKTexture(imageNamed: "chick"), resize: true)
        let resizeWidthAction = SKAction.resize(toWidth: frame.width / 40, duration: 0)
        let resizeHeightAction = SKAction.resize(toWidth: frame.height / 20, duration: 0)
        let move = SKAction.moveTo(y: -frame.height / 2 - chick.frame.height, duration: eggsDuration)
        let remove = SKAction.removeFromParent()
        sequenceAction = SKAction.sequence([SKAction.wait(forDuration: 0.1), beginingAction, delay, breakAction, SKAction.wait(forDuration: 0.2), fallChickAction, resizeWidthAction,resizeHeightAction, move, remove])
        

        
        chick.run(sequenceAction)
    }
    
    func addSingleEgg() {
        let egg = SKSpriteNode(imageNamed: "egg")
        egg.position = CGPoint(x: CGFloat((rectBird?.position.x)!), y: (rectBird?.frame.minY)! - egg.frame.height / 2)
        egg.scale(to: CGSize(width: frame.width / 18, height: frame.width / 18))
        egg.physicsBody = SKPhysicsBody(circleOfRadius: egg.frame.width)
        egg.physicsBody?.categoryBitMask = eggCategory
        egg.physicsBody?.contactTestBitMask = floorCategory + chefCategory
        egg.physicsBody?.collisionBitMask = 0
        egg.zPosition = 11
        addChild(egg)

        let beginingAction = SKAction.setTexture(SKTexture(imageNamed: "egg02"), resize: false)
        let breakAction = SKAction.setTexture(SKTexture(imageNamed: "egg03"), resize: false)
        var sequenceAction: SKAction
        let rndMove = Int.random(in: 2..<5)
        let delay = SKAction.moveTo(y: egg.frame.minY - egg.frame.height * CGFloat(rndMove), duration: 0.1)

        let showAction = SKAction.setTexture(SKTexture(imageNamed: "egg04"), resize: false)
        let fallSingleAction = SKAction.setTexture(SKTexture(imageNamed: "egg06"), resize: false)
        let move = SKAction.moveTo(y: -frame.height / 2 - egg.frame.height, duration: eggsDuration)
        let remove = SKAction.removeFromParent()
        sequenceAction = SKAction.sequence([beginingAction, SKAction.wait(forDuration: 0.1), breakAction, delay, showAction, SKAction.wait(forDuration: 0.2), fallSingleAction, move, remove])

        egg.run(sequenceAction)
    }
    func addDoubleEgg() {
        let egg = SKSpriteNode(imageNamed: "egg")
        egg.position = CGPoint(x: CGFloat((rectBird?.position.x)!), y: (rectBird?.frame.minY)! - egg.frame.height / 2)
        egg.scale(to: CGSize(width: frame.width / 18, height: frame.width / 18))
        egg.physicsBody = SKPhysicsBody(circleOfRadius: egg.frame.width)
        egg.physicsBody?.categoryBitMask = doubleEggCategory
        egg.physicsBody?.contactTestBitMask = floorCategory + chefCategory
        egg.physicsBody?.collisionBitMask = 0
        egg.zPosition = 12
        addChild(egg)
        
        let beginingAction = SKAction.setTexture(SKTexture(imageNamed: "egg02"), resize: false)
        let breakAction = SKAction.setTexture(SKTexture(imageNamed: "egg03"), resize: false)
        var sequenceAction: SKAction
        let rndMove = Int.random(in: 2..<5)
        let delay = SKAction.moveTo(y: egg.frame.minY - egg.frame.height * CGFloat(rndMove), duration: 0.1)
        
        let showAction = SKAction.setTexture(SKTexture(imageNamed: "egg05"), resize: false)
        let fallSingleAction = SKAction.setTexture(SKTexture(imageNamed: "egg07"), resize: false)
        let move = SKAction.moveTo(y: -frame.height / 2 - egg.frame.height, duration: eggsDuration)
        let remove = SKAction.removeFromParent()
        sequenceAction = SKAction.sequence([beginingAction, SKAction.wait(forDuration: 0.1), breakAction, delay, showAction, SKAction.wait(forDuration: 0.2), fallSingleAction, move, remove])
        
        egg.run(sequenceAction)
    }

    func addGoldEgg() {
        let egg = SKSpriteNode(imageNamed: "egg10")
        egg.position = CGPoint(x: CGFloat((rectBird?.position.x)!), y: (rectBird?.frame.minY)! - egg.frame.height / 2)
        egg.scale(to: CGSize(width: frame.width / 18, height: frame.width / 18))
        egg.physicsBody = SKPhysicsBody(circleOfRadius: egg.frame.width)        
        egg.physicsBody?.categoryBitMask = goldEggCategory
        egg.physicsBody?.contactTestBitMask = floorCategory + chefCategory
        egg.physicsBody?.collisionBitMask = 0
        egg.zPosition = 13
        addChild(egg)
        
        let move = SKAction.moveTo(y: -frame.height / 2 - egg.frame.height, duration: eggsDuration)
        let remove = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([move, remove])
        egg.run(sequenceAction)
    }
    
    func changeScene(isGameover: Bool) {
        var scene: SKScene
        if isGameover {
            isPaused = true
            timer?.invalidate()
            timer = nil
            eggsTimer = nil
            scene = SKScene(fileNamed: "GameOverScene")! 
        } else {
            scene = SKScene(fileNamed: "BonusScene")!
        }
        scene.scaleMode = .aspectFill
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
        view?.presentScene(scene, transition: transition)
    }
    
    func addBonusEffect(pos: CGPoint) {
        guard let bonus = SKEmitterNode(fileNamed: "bonus") else { return }
        bonus.position = pos
        self.addChild(bonus)
        self.run(SKAction.wait(forDuration: 1.0)) {
            bonus.removeFromParent()
        }
    }
    
    func addFailEffect(pos: CGPoint) {
        guard let fail = SKEmitterNode(fileNamed: "fail") else { return }
        fail.position = pos
        self.addChild(fail)
        self.run(SKAction.wait(forDuration: 1.0)) {
            fail.removeFromParent()
        }
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
            if first.categoryBitMask == eggCategory || first.categoryBitMask == doubleEggCategory {
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
                global_score += 5
                score = global_score
                if first.categoryBitMask == doubleEggCategory {
                    guard let success = SKEmitterNode(fileNamed: "success") else { return }
                    success.position = firstNode.position
                    addChild(success)
                    secondNode.run(getDoubleSound)
                    self.run(SKAction.wait(forDuration: 1.0)) {
                        success.removeFromParent()
                    }
                    global_score += 5
                    score = global_score
                }
            } else if first.categoryBitMask == goldEggCategory {
                firstNode.isHidden = true
                firstNode.run(getBonusSound)
                let bonusEffectAction = SKAction.run {
                    self.addBonusEffect(pos: firstNode.position)
                }
                let removeAction = SKAction.removeFromParent()

                let changeSceneAction = SKAction.run {
                    self.changeScene(isGameover: false)
                }

                let sequenceAction = SKAction.sequence([bonusEffectAction, removeAction, SKAction.wait(forDuration: 0.5), changeSceneAction])
                self.run(sequenceAction)

            } else if first.categoryBitMask == chickCategory {
                
                global_lives = global_lives - 1
                firstNode.run(barnChickSound)
                var updateTextureAction: SKAction
                updateTextureAction = SKAction.setTexture(textureBarnedChick, resize: false)
                
                firstNode.run(updateTextureAction)
                self.addFailEffect(pos: firstNode.position)
                guard let life = lives.last else { return }
                life.removeFromParent()
                lives.removeLast()
                
                self.run(SKAction.wait(forDuration: 0.5)) {
                    firstNode.removeFromParent()
                    if self.lives.isEmpty {
                        let changeSceneAction = SKAction.run {
                            self.changeScene(isGameover: true)
                        }
                        self.run(changeSceneAction)
                    }
                }

            }
        } else if second.categoryBitMask == floorCategory {
            if first.categoryBitMask == eggCategory || first.categoryBitMask == doubleEggCategory || first.categoryBitMask == goldEggCategory {
                firstNode.run(failSound)
                let updateTextureAction = SKAction.setTexture(textureFailedEgg, resize: false)
                let removeAction = SKAction.removeFromParent()
                let sequenceAction = SKAction.sequence([updateTextureAction, removeAction])
                firstNode.run(sequenceAction)
            } else {
                let fallAction = SKAction.moveTo(y: firstNode.frame.minY - 5, duration: 0.5)
                let moveAction = SKAction.moveTo(x: -frame.width / 2, duration: 0.5)
                let sequenceAction = SKAction.sequence([fallAction, moveAction])
                firstNode.run(sequenceAction) {
                    firstNode.removeFromParent()
                }
            }
        }
    }

    func gameOver() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        eggsTimer = nil
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        if score > bestScore {
            UserDefaults.standard.set(score, forKey: "bestScore")
        }
        let changeSceneAction = SKAction.run {
            self.changeScene(isGameover: true)
        }
        let waitToChangeScene = SKAction.wait(forDuration: 2.5)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        
        run(changeSceneSequence)
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
