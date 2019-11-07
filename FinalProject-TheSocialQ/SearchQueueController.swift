//
//  SearchQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation
import UIKit

class SearchQueueController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinBtn: UIButton!
    
    var queueResults:[Queue] = []
    var currentSelection:Queue = Queue(title:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinBtn.layer.cornerRadius = 10
        joinBtn.clipsToBounds = true
        
        // initial queues JUST FOR TESTING
        let q1 = Queue(title: "Kendall's Party")
        let q2 = Queue(title: "Sarah's House")
        
        let circles = Song(id: 1, title: "Circles", artist:"Post Malone", coverPath: "https://i.scdn.co/image/94105e271865c28853bfb7b44b38353a2fea45d6")
        let cyanide = Song(id: 2, title: "Cyanide", artist:"Daniel Caesar", coverPath: "https://i.scdn.co/image/ab67616d0000b2737607aa9ae7904e1b12907c93")
        q1.songs.append(circles)
        q1.songs.append(cyanide)
        
        q2.songs.append(circles)
        q2.songs.append(cyanide)
        
        queueResults.append(q1)
        queueResults.append(q2)
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (queueResults.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let currentQueue = queueResults[indexPath.row]
        myCell.textLabel?.text = currentQueue.title
        myCell.textLabel?.textColor = .white
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        myCell.selectedBackgroundView = backgroundView
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selecting")
        currentSelection = queueResults[indexPath.row]
    }
    
    @IBAction func promptKey(_ sender: UIButton) {
        // 1
        let optionMenu = UIAlertController(title: "What's the Key?", message: nil, preferredStyle: .alert)
        
        optionMenu.view.tintColor = .black
        
        optionMenu.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Type Key from Host"
        })
        
        // set font of title in alert
//        let attributeString = NSMutableAttributedString(string: "What's the Key?")
//        attributeString.addAttributes([NSAttributedString.Key.font : UIFont.fontNames(forFamilyName: "Avenir")],                                          range: NSMakeRange(0, "What's the Key?".utf8.count))

        // ADD HANDLER TO THIS TO DEAL WITH GOING TO NEXT VIEW CONTROLLER
        let accessAction = UIAlertAction(title: "Access Queue", style: .default, handler: {action in self.performSegue(withIdentifier: "viewCurrentQueue", sender: self)})
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(accessAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCurrentQueue" {
            let destination = segue.destination as? UITabBarController
            print("running segue")
            for controller in (destination?.viewControllers)! {
                if (controller.isKind(of: GuestQueueController.self) == true) {
                    (controller as! GuestQueueController).currentQueue = currentSelection
                    (controller as! GuestQueueController).tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
                    break
                }
            }
        }
     }
    
}
