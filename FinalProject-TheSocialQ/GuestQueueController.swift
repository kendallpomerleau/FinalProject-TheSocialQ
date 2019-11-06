//
//  GuestQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class GuestQueueController: UIViewController {

    var currentQueue:Queue = Queue(title: "")

    @IBOutlet weak var queueTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queueTitle.text = currentQueue.title

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
