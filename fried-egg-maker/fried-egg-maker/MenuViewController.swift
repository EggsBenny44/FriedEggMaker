//
//  MenuViewController.swift
//  fried-egg-maker
//
//  Created by yoyo on 2020-03-26.
//  Copyright © 2020 egga-benny.com. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        button.frame = CGRect(x: 140, y: 125, width: 200, height: 70)
        
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        
        button.layer.cornerRadius = 10
        
        button.layer.shadowOffset = CGSize(width: 3, height: 3 )
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 10
        button.layer.shadowColor = UIColor.gray.cgColor
    }
}
