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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (UIApplication.shared.delegate as! AppDelegate).rotateScreen(orientation: .portrait)
    }
}

