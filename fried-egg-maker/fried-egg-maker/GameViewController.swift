//
//  GameViewController.swift
//  fried-egg-maker
//
//  Created by yoyo on 2020-03-15.
//  Copyright © 2020 egga-benny.com. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var global_score = 0
var global_lives = 5
var global_eggInterval = 10.0

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            if let view = self.view as! SKView? {
                global_score = 0
                global_lives = 5
                global_eggInterval = 10.0
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    (scene as! GameScene).gameVC = self
                    // Present the scene
                    view.presentScene(scene)
                }
                
                
                
                view.showsFPS = false
                view.showsNodeCount = false
            }
        }
        
        override var shouldAutorotate: Bool {
            return true
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return .allButUpsideDown
            } else {
                return .all
            }
        }
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
}
