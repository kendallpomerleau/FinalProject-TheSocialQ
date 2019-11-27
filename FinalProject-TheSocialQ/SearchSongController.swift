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
    
    var spinner:UIActivityIndicatorView?
    let baseURL:String = "https://api.spotify.com/v1/"
    
    // THIS SHOULD BE GIVEN TO YOU SOMEHOW WHEN YOU LOGIN BECAUSE OF THE QUEUE YOU ARE LOGGING INTO
    var spotifyToken:String = "BQCyV2FnYvw1FCiZw-RYYCSfaPXKgBY8mqLimksHZpgCYWTGNuxwkPGRTAMPrmX-bhYZVXYkoj4F00oMUHvpSNWBpAueffW-gTAC_8q1RD0vkBeg39wtbRMIu58vWrAMclF4TWStWFvCiuD2-9431uvqPRRKYTKt3bSJi2A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        searchBar.delegate = self
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner!.center = view.center
        spinner!.startAnimating()
        view.addSubview(spinner!)
        spinner?.hidesWhenStopped = true
        grabFirebaseData()

        DispatchQueue.main.async{
            print(self.spotifyToken)
            self.loadDefaultSongs()
            self.tableView.reloadData()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    
    func grabFirebaseData() {
        
        let ref = Database.database().reference()
        
        // load full list of all queues into table view
        if (currentQueue != nil ){
            ref.child("Queues/\(currentQueue!.title)").observe(.value, with: {
                snapshot in
                let swiftyJsonVar = JSON(snapshot.value!)
                self.spotifyToken = "\(swiftyJsonVar["token"])"
            })
        }
    }
    
    
    func cacheImages() {
        imageCache = []
        for song in songResults {
            let url = URL(string: song.coverPath!)
            let data = try? Data(contentsOf: url!)
            if (data != nil){
                let image = UIImage(data:data!)
                imageCache.append(image!)
            }
            
        }
    }
    
    func loadDefaultSongs() {
        let url = URL(string: baseURL + "playlists/37i9dQZF1DXcBWIGoYBM5M?orderby=popularity")
        
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
                    for j in 1..<tracks[i]["track"]["artists"].count {
                        artist += ", " + "\(tracks[i]["track"]["artists"][j]["name"])"
                    }
                }
                else {
                    artist = "\(tracks[i]["track"]["artists"][0]["name"])"
                }
                
                self.songResults.append(Song(id: "\(tracks[i]["track"]["id"])", name: "\(tracks[i]["track"]["name"])", artist: artist, coverPath:"\(tracks[i]["track"]["album"]["images"][1]["url"])", duration: "\(tracks[i]["track"]["duration"])"))
            }
            
            DispatchQueue.main.async {
                self.cacheImages()
                // remove the spinner view controller
                self.tableView.reloadData()
                self.spinner?.stopAnimating()
            }
        }
        task.resume()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var text = searchBar.text!
        text = text.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        if text != "" {
            self.songResults = []
            // add the spinner view controller
            spinner!.startAnimating()
            
            let url = URL(string: baseURL + "search?q=\(text)&type=track&market=US")
            
            var request = URLRequest(url: url!)
            request.addValue("Bearer \(spotifyToken)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            
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
                        self.songResults.append(Song(id: "\(tracks[i]["id"])", name: "\(tracks[i]["name"])", artist: artist, coverPath:
                            "\(tracks[i]["album"]["images"][1]["url"])", duration: "\(tracks[i]["duration_ms"])"))
                    }
                    DispatchQueue.main.async{
                        self.cacheImages()
                        self.tableView.reloadData()
                        self.spinner?.stopAnimating()
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
        let index = sender.tag
        DispatchQueue.global(qos: .background).async {
            self.currentQueue?.addToQueue(song: self.songResults[index], isHost: self.isHost, canDirectAdd: self.canDirectAdd)

            DispatchQueue.main.async {
               
                if (self.canDirectAdd){
                    let firstTab = self.tabBarController?.viewControllers![0] as! HostQueueViewController
                    firstTab.currentQueue = self.currentQueue!
                    
                    let addAlert = UIAlertController(title: "Added", message: "", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
//                    addAlert.addAction(cancelAction)
                    
                    self.present(addAlert, animated: true, completion: nil)
                    
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                      addAlert.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    let firstTab = self.tabBarController?.viewControllers![0] as! GuestQueueController
                    firstTab.currentQueue = self.currentQueue!
                    
                    let suggestAlert = UIAlertController(title: "Suggested", message: "", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
//                    suggestAlert.addAction(cancelAction)
                    self.present(suggestAlert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                      suggestAlert.dismiss(animated: true, completion: nil)
                    }
                }
            }
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
