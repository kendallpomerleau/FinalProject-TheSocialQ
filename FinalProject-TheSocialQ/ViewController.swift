//
//  ViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hostQueueBtn: UIButton!
    @IBOutlet weak var joinQueueBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostQueueBtn.layer.cornerRadius = 10
        hostQueueBtn.clipsToBounds = true
        
        joinQueueBtn.layer.cornerRadius = 10
        joinQueueBtn.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }


}

