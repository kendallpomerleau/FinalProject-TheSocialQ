//
//  SearchSongController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchSongController: UIViewController, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var songResults:[Song] = []
    var imageCache:[UIImage] = []

    let baseURL:String = "https://api.spotify.com/v1/"
    
    // THIS SHOULD BE GIVEN TO YOU SOMEHOW WHEN YOU LOGIN BECAUSE OF THE QUEUE YOU ARE LOGGING INTO
    let spotifyToken:String = "BQDBPa0elLhn0EOkPSCTtJA13LJFCpUzmafYILBfwjFHPFiCggCZTG99DZLpYFVmjQr0JWzeGR2rEzjosABrBTFQEQfkeUmbEM_A4-1iLxoJeaB5j-UuXs3lOy7xaoLxZjGyb89wXFC_iezCDB7nLuhaJFq_nDogvdOh2pUmYg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load default songs (popular from API)
        // JUST FOR TESTING
//        let circles = Song(id: "1", name: "Circles", artist:"Post Malone", coverPath: "https://i.scdn.co/image/94105e271865c28853bfb7b44b38353a2fea45d6")
//        let cyanide = Song(id: "2", name: "Cyanide", artist:"Daniel Caesar", coverPath: "https://i.scdn.co/image/ab67616d0000b2737607aa9ae7904e1b12907c93")
//        songResults.append(circles)
//        songResults.append(cyanide)
        
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        searchBar.delegate = self

        // Do any additional setup after loading the view.
        loadDefaultSongs()
    }
    
   
    
    func cacheImages() {
        imageCache = []
        for song in songResults {
            if song.coverPath != nil {
                let url = URL(string: song.coverPath!)
                let data = try? Data(contentsOf: url!)
                if (data != nil){
                    let image = UIImage(data:data!)
                    imageCache.append(image!)
                }
            }
            else {
                // append empty image
                imageCache.append(UIImage())
            }
        }
    }
    
    func loadDefaultSongs() {
        let url = URL(string: baseURL + "playlists/37i9dQZF1DXcBWIGoYBM5M")
        
        var request = URLRequest(url: url!)
        request.addValue("Bearer \(spotifyToken)", forHTTPHeaderField: "Authorization")

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
                self.songResults.append(Song(id: "\(tracks[i]["track"]["id"])", name: "\(tracks[i]["track"]["name"])", artist: "\(tracks[i]["track"]["artists"][0]["name"])", coverPath:
                    "\(tracks[i]["track"]["album"]["images"][1]["url"])"))
            }

            DispatchQueue.main.async {
                print(self.songResults)
                self.cacheImages()
                // remove the spinner view controller
                self.tableView.reloadData()
            }
        }
        task.resume()
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor(displayP3Red: 25/255, green: 20/255, blue: 20/255, alpha: 0.9)
        
        if (indexPath.row <= imageCache.count - 1) {

            
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
            cellDescription.text = songResults[indexPath.row].artist
            
            
            let plusBtn = UIButton(frame: CGRect(x: cell.frame.maxX, y: cell.frame.origin.y+tableView.rowHeight/2.0-10, width: 20, height: 20))
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
        
        self.present(alert, animated: true, completion: nil)
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
