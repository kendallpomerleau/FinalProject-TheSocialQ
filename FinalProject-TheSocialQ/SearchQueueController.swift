//
//  SearchQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import SwiftyJSON

class SearchQueueController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var queueResults:[Queue] = []
    var shownQueues:[Queue] = []
    var currentSelection:Queue = Queue(title:"", key: "", add: false, playlistID: "")
    var searchActive : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinBtn.layer.cornerRadius = 10
        joinBtn.clipsToBounds = true
        
        // initial queues JUST FOR TESTING
        /*
        let q1 = Queue(title: "Kendall's Party", key: "12345", add: true, playlistID: "")
        let q2 = Queue(title: "Sarah's House", key: "12345", add: true, playlistID: "")
        
        let circles = Song(id: "1", name: "Circles", artist:"Post Malone", coverPath: "https://i.scdn.co/image/94105e271865c28853bfb7b44b38353a2fea45d6")
        let cyanide = Song(id: "2", name: "Cyanide", artist:"Daniel Caesar", coverPath: "https://i.scdn.co/image/ab67616d0000b2737607aa9ae7904e1b12907c93")
        q1.songs.append(circles)
        q1.songs.append(cyanide)
        
        q2.songs.append(circles)
        q2.songs.append(cyanide)
        
        queueResults.append(q1)
        queueResults.append(q2)
        */
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        
        grabFirebaseData()
        // Do any additional setup after loading the view.
    }
    
    func grabFirebaseData() {
        let ref = Database.database().reference()
 
        // load full list of all queues into table view
        ref.observe(.value, with: {
            snapshot in
//            do {
                let dictionary = snapshot.value as! NSDictionary
                //let queues = try JSONDecoder().decode([Queue].self, from: dictionary?["Queues"] as! Data) //wants as! NSDictionary
            let dict2 = dictionary["Queues"] as? NSDictionary
            var queues : [Queue] = []
            for (_,value) in dict2! {
                let furtherDict = value as! NSDictionary
                let name = furtherDict["name"] as? String
                let key = furtherDict["passKey"] as? String
                let directAdd = furtherDict["directAdd"] as? String
                var add = false
                if directAdd! == "True" {
                    add = true
                }
                let playlistID = furtherDict["basePlaylistID"] as? String
                let newQueue = Queue(title: name!, key: key!, add: add, playlistID: playlistID!)
                queues.append(newQueue)
            }
                
                for queue in queues {
                    if !self.queueResults.contains(queue){
                        self.queueResults.append(queue)
                    }
                }
//        }
//            catch {
//              return
//            }
            
//            for child in snapshot.children.allObjects as! [DataSnapshot]{
//                print(child.key)
//
//                let swiftyJsonVar = JSON(child.value!)
//                var directAdd = false
//                if swiftyJsonVar["directAdd"] == "True" {
//                    directAdd = true
//                }
//                let queueFromJson = Queue(title: "\(swiftyJsonVar["name"])", key: "\(swiftyJsonVar["passKey"])", add: directAdd, playlistID: "\(swiftyJsonVar["basePlaylistID"])")
//
//                if !self.queueResults.contains(queueFromJson){
//                    self.queueResults.append(queueFromJson)
//                }
//            }
            DispatchQueue.main.async{
                if self.searchBar.text! == "" {
                    self.shownQueues = self.queueResults
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        shownQueues = []
        
        // if nothing written in search bar, load defaults (stored in queueResults)
        if self.searchBar.text! == "" {
            self.shownQueues = self.queueResults
        }
        else {
            for queue in queueResults {
                if (queue.title.contains(searchBar.text!)){
                    shownQueues.append(queue)
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchBar.showsCancelButton = false
        searchBar.endEditing(true)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (shownQueues.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let currentQueue = shownQueues[indexPath.row]
        myCell.textLabel?.text = currentQueue.title
        myCell.textLabel?.textColor = .white
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        myCell.selectedBackgroundView = backgroundView
        
        return myCell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selecting")
        currentSelection = shownQueues[indexPath.row]
    }
    
    @IBAction func promptKey(_ sender: UIButton) {
        // 1
        let optionMenu = UIAlertController(title: "What's the Key?", message: nil, preferredStyle: .alert)
        
        optionMenu.view.tintColor = .black
        optionMenu.view.backgroundColor = .white
        
        optionMenu.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Type Key from Host"
        })
        optionMenu.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Create Username"
        })
        
        optionMenu.view.layer.cornerRadius = 25
        
        // set font of title in alert
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: "What's the Key?", attributes: [NSAttributedString.Key.font:UIFont(name: "Avenir Next", size: 19.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:15))
        optionMenu.setValue(myMutableString, forKey: "attributedTitle")

        // ADD HANDLER TO THIS TO DEAL WITH GOING TO NEXT VIEW CONTROLLER
        if currentSelection.title != "" {
            let accessAction = UIAlertAction(title: "Join", style: .default, handler: {action in
                
                let textField = optionMenu.textFields![0] // Force unwrapping because we know it exists.
                
                let userText = optionMenu.textFields![1]
                
                // add to database

                if textField.text == self.currentSelection.key {
                    if(userText.text != ""){
                        self.currentSelection.userJoin(username: userText.text!)
                    }
                    self.performSegue(withIdentifier: "viewCurrentQueue", sender: self)
                }
                else {
                    let failMenu = UIAlertController(title: "Incorrect Key", message: "Enter the correct key to join the queue", preferredStyle: .alert)
                    failMenu.view.backgroundColor = .white
                    failMenu.view.layer.cornerRadius = 25

                    var failMutable = NSMutableAttributedString()
                    failMutable = NSMutableAttributedString(string: "Incorrect Key", attributes: [NSAttributedString.Key.font:UIFont(name: "Avenir Next", size: 19.0)!])
                    failMutable.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:13))
                    failMenu.setValue(failMutable, forKey: "attributedTitle")
                    
                    var failMutableMsg = NSMutableAttributedString()
                    failMutableMsg = NSMutableAttributedString(string: "\nEnter the correct key to join the queue.", attributes: [NSAttributedString.Key.font:UIFont(name: "Avenir Next", size: 14.0)!])
                    failMutableMsg.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:40))
                    failMenu.setValue(failMutableMsg, forKey: "attributedMessage")
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                    
                    failMenu.addAction(cancelAction)
                    self.present(failMenu, animated: true, completion: nil)
                }
            })
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(accessAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }
    }

    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCurrentQueue" {
            let destination = segue.destination as? UITabBarController
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

