//
//  SearchSongController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseDatabase

class SearchSongController: UIViewController, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /*var songResults:[Track] = []*/
    var songResults:[Song] = []
    var suggestions:[Song] = []
    var imageCache:[UIImage] = []
    var currentQueue:Queue?
    
    var isHost = false
    var canDirectAdd = false
    
    let baseURL:String = "https://api.spotify.com/v1/"
    
    // THIS SHOULD BE GIVEN TO YOU SOMEHOW WHEN YOU LOGIN BECAUSE OF THE QUEUE YOU ARE LOGGING INTO
    var spotifyToken:String = "BQCyV2FnYvw1FCiZw-RYYCSfaPXKgBY8mqLimksHZpgCYWTGNuxwkPGRTAMPrmX-bhYZVXYkoj4F00oMUHvpSNWBpAueffW-gTAC_8q1RD0vkBeg39wtbRMIu58vWrAMclF4TWStWFvCiuD2-9431uvqPRRKYTKt3bSJi2A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        searchBar.delegate = self
        
        // load default songs (today's top hits from API)
        grabFirebaseData()
        
    }
    
        
    func grabFirebaseData() {
        
        let ref = Database.database().reference()
     
        // load full list of all queues into table view
        ref.observe(.value, with: {
            snapshot in
            
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                if (child.key == "Queues"){
                    //print("child value is \(child.value!)")
                    
                    let swiftyJsonVar = JSON(child.value!)
                    for queue in swiftyJsonVar {
                        print("queue is \(queue)")
                        let swiftyQueue = JSON(queue.1)
                        if "\(swiftyQueue["name"])" == self.currentQueue?.title{
                            self.spotifyToken = "\(swiftyQueue["token"])"
                        }
                    }
                }
            }
            DispatchQueue.main.async{
                print(self.spotifyToken)
                print("loading songs")
                self.loadDefaultSongs()
                self.tableView.reloadData()
            }
        })
    }
    
    
    func cacheImages() {
        imageCache = []
        for song in songResults {
            
            /*let url = URL(string: song.album.images[0].url)
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
    
    func loadDefaultSongs() {
        
         let url = URL(string: baseURL + "playlists/37i9dQZF1DXcBWIGoYBM5M")
         
         var request = URLRequest(url: url!)
         request.addValue("Bearer \(spotifyToken)", forHTTPHeaderField: "Authorization")
         request.httpMethod = "GET"
         
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
         
         let swiftyJsonVar = JSON(data)
         let tracks = swiftyJsonVar["tracks"]["items"]
         for i in 0..<tracks.count {
            var artist = ""
            if (tracks[i]["track"]["artists"].count > 1){
                artist = "\(tracks[i]["track"]["artists"][0]["name"])"
                for j in 0..<tracks[i]["track"]["artists"].count {
                    artist += ", " + "\(tracks[i]["track"]["artists"][j]["name"])"
                }
            }
            else {
                artist = "\(tracks[i]["track"]["artists"][0]["name"])"
            }
            
            self.songResults.append(Song(id: "\(tracks[i]["track"]["id"])", name: "\(tracks[i]["track"]["name"])", artist: artist, coverPath:"\(tracks[i]["track"]["album"]["images"][1]["url"])", duration: "\(tracks[i]["track"]["duration"])"))
         }
         
         DispatchQueue.main.async {
            print(self.songResults)
            self.cacheImages()
            // remove the spinner view controller
            self.tableView.reloadData()
            }
         }
         task.resume()
         /*
        let todaysHitsID = "37i9dQZF1DXcBWIGoYBM5M"
        let hotTracks = getTracks(authToken: spotifyToken, playlistID: todaysHitsID)
        songResults = hotTracks
        DispatchQueue.main.async {
            print(self.songResults)
            self.cacheImages()
            // remove the spinner view controller
            self.tableView.reloadData()
        }*/
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        // query the spotify api to
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var text = searchBar.text!
        text = text.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        if text != "" {
            self.songResults = []
            // add the spinner view controller
            //            let child = SpinnerViewController()
            //            addChild(child)
            //            child.view.frame = view.frame
            //            view.addSubview(child.view)
            //            child.didMove(toParent: self)
            //            let query = URL(string: baseURL + "search?q=\(text)&type=track&market=US")!
            //            var request = URLRequest(url: query)
            
             let url = URL(string: baseURL + "search?q=\(text)&type=track&market=US")
             
             var request = URLRequest(url: url!)
             request.addValue("Bearer \(spotifyToken)", forHTTPHeaderField: "Authorization")
             request.httpMethod = "GET"
             
             print(request)
             
             DispatchQueue.global(qos: .background) .async {
             let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                let swiftyJsonVar = JSON(data)
                let tracks = swiftyJsonVar["tracks"]["items"]
                for i in 0..<tracks.count {
                    var artist = ""
                    if (tracks[i]["artists"].count > 1){
                        artist = "\(tracks[i]["artists"][0]["name"])"
                        for j in 1..<tracks[i]["artists"].count {
                            artist += ", " + "\(tracks[i]["artists"][j]["name"])"
                        }
                    }
                    else {
                        artist = "\(tracks[i]["artists"][0]["name"])"
                    }
                    print(artist)
                    self.songResults.append(Song(id: "\(tracks[i]["id"])", name: "\(tracks[i]["name"])", artist: artist, coverPath:
                "\(tracks[i]["album"]["images"][1]["url"])", duration: "\(tracks[i]["duration_ms"])"))
                }

                    DispatchQueue.main.async {
                        self.cacheImages()
                        print(self.songResults)
                        // remove the spinner view controller
                        self.tableView.reloadData()
                        //                        child.willMove(toParent: nil)
                        //                        child.view.removeFromSuperview()
                        //                        child.removeFromParent()
                    }
                }
                task.resume()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor(displayP3Red: 25/255, green: 20/255, blue: 20/255, alpha: 0.9)
        
        if (indexPath.row < imageCache.count && indexPath.row < songResults.count) {
            
            
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
            
            cellTitle.text = songResults[indexPath.row].name
            /*var artists = songResults[indexPath.row].artists[0].name
            if songResults[indexPath.row].artists.count != 1{
                for i in 1...songResults[indexPath.row].artists.count-1 {
                    artists.append(", \(songResults[indexPath.row].artists[i].name)")
                }
            }*/
            let artists = songResults[indexPath.row].artist

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
        
        if (currentQueue?.songs.contains(songResults[sender.tag]))!{
            return
        }
        else {
            currentQueue?.addToQueue(song: songResults[sender.tag], isHost: self.isHost, canDirectAdd: self.canDirectAdd)
            // somehow need to get the song that the button was attached to
            let firstTab = self.tabBarController?.viewControllers![0] as! GuestQueueController
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
