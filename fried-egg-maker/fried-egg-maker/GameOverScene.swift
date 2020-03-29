//
//  GameOverScene.swift
//  fried-egg-maker
//
//  Created by yoyo on 2020-03-28.
//  Copyright © 2020 egga-benny.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    var restartSquare = SKShapeNode()
    
    override func didMove(to view: SKView) {
//        let background = SKSpriteNode(imageNamed: "background")
//        background.position = CGPoint(x: -frame.size.width / 2, y: frame.size.height / 2)
//        background.zPosition = 0
//        addChild(background)
        
        print ("width: \(frame.size.width)")
        print ("height: \(frame.size.height)")
        
        let gameeOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameeOverLabel.text = "GAME OVER"
        gameeOverLabel.fontSize = 60
        gameeOverLabel.fontColor = SKColor.white
        gameeOverLabel.position = CGPoint(x: -self.frame.midX, y: self.frame.midY + 300)
        print ("label width: \(self.frame.size.width)")

        gameeOverLabel.zPosition = 1
        addChild(gameeOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "SCORE: \(global_score)"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: -self.frame.midX, y: self.frame.midY)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        var bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        
        if bestScore < global_score {
            bestScore = global_score
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
        
        let bestScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        bestScoreLabel.fontSize = 30
        bestScoreLabel.fontColor = SKColor.white
        bestScoreLabel.zPosition = 1
        bestScoreLabel.position = CGPoint(x: -self.frame.midX, y: self.frame.midY - 100)
        addChild(bestScoreLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Gill Sans")
        restartLabel.text = "TRY AGAIN?"
        restartLabel.fontSize = 30
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: -self.frame.midX, y: self.frame.midY - 300)
        
        restartSquare = SKShapeNode(rect: CGRect(x: restartLabel.frame.minX-60, y: restartLabel.frame.maxY - 55, width: restartLabel.frame.size.width + 120, height: restartLabel.frame.size.height + 60), cornerRadius: 10.0)

        restartSquare.lineWidth = 4.0
        restartSquare.strokeColor = UIColor.white
        
        addChild(restartSquare)
        addChild(restartLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in :self)
            if restartSquare.contains(pointOfTouch) {
                global_score = 0
                global_lives = 1
                global_eggInterval = 10.0
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(backToGameScene), userInfo: nil, repeats: false)
            }
            
        }
    }
    
    @objc private func backToGameScene() {
        let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let gameScene = SKScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view!.presentScene(gameScene!, transition: transition)
    }
}
