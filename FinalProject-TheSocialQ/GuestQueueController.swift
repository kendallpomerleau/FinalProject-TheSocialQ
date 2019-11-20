//
//  GuestQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GuestQueueController: UIViewController, UITableViewDataSource {
    
    var currentQueue:Queue = Queue(title: "", key: "", add: false, playlistID: "")
    var imageCache:[UIImage] = []
    
    
    @IBOutlet weak var queueTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let secondTab = self.tabBarController?.viewControllers![1] as! SearchSongController
        secondTab.currentQueue = self.currentQueue
        
        addBtn.layer.cornerRadius = 10
        addBtn.clipsToBounds = true
        queueTitle.text = currentQueue.title
        
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        cacheImages()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        //begin connection to firebase queue
        let ref = Database.database().reference()
        ref.child("Queues").observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let passKey = value?["passKey"] as? String ?? ""
            if(passKey == "" || passKey != self.currentQueue.key) {
                return
            }
            else {
//              do {
                    let dictionary = snapshot.value as! NSDictionary
                    //let queue = try JSONDecoder().decode(Queue.self, from: dictionary["\(self.currentQueue.title)"] as! Data)
                    let dict2 = dictionary["\(self.currentQueue.title)"] as! NSDictionary
                    let name = dict2["name"] as? String
                    let key = dict2["passKey"] as? String
                    let directAdd = dict2["directAdd"] as? String
                    var add = false
                    if directAdd! == "True" {
                        add = true
                    }
                    let playlistID = dict2["basePlaylistID"] as? String
                    let queue = Queue(title: name!, key: key!, add: add, playlistID: playlistID!)
                    self.currentQueue = queue
                    self.cacheImages()
                    self.tableView.reloadData()
                    
//                }
//                catch {
//                    return
//                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    func cacheImages() {
        imageCache = []
        for song in currentQueue.songs {
            
                /*let url = URL(string: song.album.images[2].url)
                let data = try? Data(contentsOf: url!)
                if (data != nil){
                    let image = UIImage(data:data!)
                    imageCache.append(image!)
                }*/
            let url = URL(string: song.coverPath!)
            let data = try? Data(contentsOf: url!)
            if (data != nil){
                let image = UIImage(data:data!)
                imageCache.append(image!)
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentQueue.songs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        let cellImg = UIImageView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 90, height: 90))
        cellImg.image = imageCache[indexPath.section]
        cellImg.layer.cornerRadius=10
        cellImg.clipsToBounds = true
        
        cell.backgroundColor = .darkGray
        
        let cellTitle = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10, y: cell.frame.origin.y + 10, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
        cellTitle.font = UIFont(name: "Avenir Next", size: 18)
        cellTitle.textColor = UIColor(displayP3Red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
        
        let cellDescription = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10 , y: cell.frame.origin.y + cellTitle.frame.height, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
        cellDescription.font = UIFont(name: "Avenir Next", size: 13)
        cellDescription.textColor = .white
        
        cellTitle.text = currentQueue.songs[indexPath.section].name
        /*var artists = currentQueue.songs[indexPath.section].artists[0].name
        if(currentQueue.songs[indexPath.section].artists.count > 1) {
            for i in 1...currentQueue.songs[indexPath.section].artists.count-1 {
                artists.append(", \(currentQueue.songs[indexPath.section].artists[i].name)")
            }
            
        }*/
        let artists = currentQueue.songs[indexPath.section].artist
        /*if(currentQueue.songs[indexPath.section].artists.count > 1) {
            for i in 1...currentQueue.songs[indexPath.section].artists.count-1 {
                artists.append(", \(currentQueue.songs[indexPath.section].artists[i].name)")
            }
            
        }*/
        cellDescription.text = artists
        
        
        let dotdotBtn = UIButton(frame: CGRect(x: cell.frame.maxX-20, y: cell.frame.origin.y+tableView.rowHeight/2.0, width: 20, height: 10))
        
        dotdotBtn.setBackgroundImage(UIImage(named: "ellipses"), for: .normal)
        
        dotdotBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        cell.addSubview(cellImg)
        cell.addSubview(cellTitle)
        cell.addSubview(cellDescription)
        cell.addSubview(dotdotBtn)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView
        
        
        cell.layer.borderColor = UIColor(red: 25/255, green: 20/255, blue: 20/255, alpha: 1).cgColor
        cell.layer.borderWidth = 5
        
        return cell
    }
    
    @IBAction func backToSearch(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "backToSearch", sender: self)
        
    }
    
    @objc func buttonClicked(sender : UIButton){
        let alert = UIAlertController(title: "Clicked", message: "You have clicked on the button", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchFromGuest" {
            print("segue")
            let destination = segue.destination as? SearchSongController
            destination?.isHost = false
            destination?.canDirectAdd = false
        }
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
