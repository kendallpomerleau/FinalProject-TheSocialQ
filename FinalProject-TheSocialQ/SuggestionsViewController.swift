//
//  SuggestionsViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/17/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseDatabase

class SuggestionsViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    //var suggestions:[Song] = []
    var imageCache:[UIImage] = []
    var currentQueue:Queue?
    
    
    let baseURL:String = "https://api.spotify.com/v1/"
    
    // THIS SHOULD BE GIVEN TO YOU SOMEHOW WHEN YOU LOGIN BECAUSE OF THE QUEUE YOU ARE LOGGING INTO
    let spotifyToken:String = "BQCyV2FnYvw1FCiZw-RYYCSfaPXKgBY8mqLimksHZpgCYWTGNuxwkPGRTAMPrmX-bhYZVXYkoj4F00oMUHvpSNWBpAueffW-gTAC_8q1RD0vkBeg39wtbRMIu58vWrAMclF4TWStWFvCiuD2-9431uvqPRRKYTKt3bSJi2A"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.rowHeight = 90

        currentQueue?.loadSuggestions()
        cacheImages()
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cacheImages()
        tableView.reloadData()
    }
    
    func cacheImages() {
        imageCache = []
         for song in currentQueue!.suggestions {
               
            let url = URL(string: song.coverPath!)
            let data = try? Data(contentsOf: url!)
            if (data != nil){
                let image = UIImage(data:data!)
                imageCache.append(image!)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentQueue!.suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        print("loading cell")
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor(displayP3Red: 25/255, green: 20/255, blue: 20/255, alpha: 0.9)
        
        if (indexPath.row < imageCache.count && indexPath.row < currentQueue!.suggestions.count) {
            
            
            let cellImg = UIImageView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 90, height: 90))
            cellImg.image = imageCache[indexPath.row]
            cellImg.layer.cornerRadius=10
            cellImg.clipsToBounds = true
            
            cell.backgroundColor = .darkGray
            
            let cellTitle = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10, y: cell.frame.origin.y + 10, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
            cellTitle.font = UIFont(name: "Avenir Next", size: 18)
            cellTitle.textColor = UIColor(displayP3Red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
            
            let cellDescription = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10 , y: cell.frame.origin.y + cellTitle.frame.height, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
            cellDescription.font = UIFont(name: "Avenir Next", size: 13)
            cellDescription.textColor = .white
            
            cellTitle.text = currentQueue!.suggestions[indexPath.row+1].name

            let artists = currentQueue!.suggestions[indexPath.row+1].artist
            
            cellDescription.text = artists
            
            
            let plusBtn = UIButton(frame: CGRect(x: cell.frame.maxX-20, y: cell.frame.origin.y+tableView.rowHeight/2.0-10, width: 20, height: 20))
            plusBtn.tag = indexPath.row
            plusBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            
            
            plusBtn.setBackgroundImage(UIImage(named: "plus"), for: .normal)
            
            cell.addSubview(cellImg)
            cell.addSubview(cellTitle)
            cell.addSubview(cellDescription)
            cell.addSubview(plusBtn)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = backgroundView
            
            
            cell.layer.borderColor = UIColor(red: 25/255, green: 20/255, blue: 20/255, alpha: 1).cgColor
            cell.layer.borderWidth = 5
        }
        return cell
    }
    
    @objc func buttonClicked(sender : UIButton){
         let alert = UIAlertController(title: "Added to Queue", message: "You have added the song to the queue.", preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
         
        self.present(alert, animated: true, completion: nil)

         alert.addAction(cancelAction)
         currentQueue?.addToQueue(song: currentQueue!.suggestions[sender.tag+1], isHost: true, canDirectAdd: true)
        
         // somehow need to get the song that the button was attached to
         let firstTab = self.tabBarController?.viewControllers![0] as! HostQueueViewController
         firstTab.currentQueue = currentQueue!
         firstTab.cacheImages()
         firstTab.tableView.reloadData()
        
        // remove suggestion from firebase and from queue
        currentQueue!.removeSuggestion(song: currentQueue!.suggestions[sender.tag+1])
        cacheImages()
        tableView.reloadData()
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
