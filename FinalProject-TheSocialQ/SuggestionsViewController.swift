//
//  SuggestionsViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/17/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class SuggestionsViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var suggestions:[Track] = []
    var imageCache:[UIImage] = []
    var currentQueue:Queue?
    
    
    let baseURL:String = "https://api.spotify.com/v1/"
    
    // THIS SHOULD BE GIVEN TO YOU SOMEHOW WHEN YOU LOGIN BECAUSE OF THE QUEUE YOU ARE LOGGING INTO
    let spotifyToken:String = "BQCyV2FnYvw1FCiZw-RYYCSfaPXKgBY8mqLimksHZpgCYWTGNuxwkPGRTAMPrmX-bhYZVXYkoj4F00oMUHvpSNWBpAueffW-gTAC_8q1RD0vkBeg39wtbRMIu58vWrAMclF4TWStWFvCiuD2-9431uvqPRRKYTKt3bSJi2A"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.rowHeight = 90
        // Do any additional setup after loading the view.
        loadSuggestions()
        
    }
    
    func loadSuggestions(){
        //if the suggestions queue is empty add a label taht says you have no suggested songs yet
    }
    
    func cacheImages() {
           imageCache = []
           for song in suggestions {
               
               let url = URL(string: song.album.images[0].url)
               let data = try? Data(contentsOf: url!)
               if (data != nil){
                   let image = UIImage(data:data!)
                   imageCache.append(image!)
               }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor(displayP3Red: 25/255, green: 20/255, blue: 20/255, alpha: 0.9)
        
        if (indexPath.row < imageCache.count && indexPath.row < suggestions.count) {
            
            
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
            
            cellTitle.text = suggestions[indexPath.row].name
            var artists = suggestions[indexPath.row].artists[0].name
            if suggestions[indexPath.row].artists.count != 1{
                for i in 1...suggestions[indexPath.row].artists.count-1 {
                    artists.append(", \(suggestions[indexPath.row].artists[i].name)")
                }
            }
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
         let alert = UIAlertController(title: "Clicked", message: "You have clicked on the add", preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
         
         alert.addAction(cancelAction)
         
         if (currentQueue?.songs.contains(suggestions[sender.tag]))!{
             return
         }
         else {
             currentQueue?.addToQueue(song: suggestions[sender.tag], isHost: true, canDirectAdd: true)
             // somehow need to get the song that the button was attached to
             let firstTab = self.tabBarController?.viewControllers![0] as! HostQueueViewController
             firstTab.currentQueue = currentQueue!
             firstTab.cacheImages()
             firstTab.tableView.reloadData()
             
             self.present(alert, animated: true, completion: nil)
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
