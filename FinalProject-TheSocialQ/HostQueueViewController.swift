//
//  HostQueueViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HostQueueViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var endBtn: UIButton!
    var currentQueue:Queue = Queue(title: "", key: "", add: false, playlistID: "")
    var imageCache:[UIImage] = []
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    @IBOutlet weak var durationBar: UIProgressView!
    
    @IBOutlet weak var songImage: UIImageView!
        
    var isPlaying:Bool = true
    //    var justDeleted = false
    
    @IBAction func playPause(_ sender: Any) {
        //set image
        if isPlaying {
            currentQueue.pausePlayingSong()
            isPlaying = false
            playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
            //playPauseButton.imageView?.image = UIImage(named: "play")
        }
        else {
            currentQueue.resumePlayingSong()
            isPlaying = true
            //playPauseButton.imageView?.image = UIImage(named: "pause")
            playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    
    @IBAction func prevSong(_ sender: Any) {
        _ = currentQueue.previousSong()
        isPlaying = true
        playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
        
    }
    
    @IBAction func nextSong(_ sender: Any) {
        currentQueue.skipSong()
        isPlaying = true
        DispatchQueue.main.async{
            self.updateSongInfo()
            self.playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
        }
        
    }
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playSongView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check on this
        isPlaying = true
        
        // Do any additional setup after loading the view.
        self.playSongView.layer.cornerRadius = 10
        tableView.dataSource = self
        tableView.rowHeight = 90
    
        disclaimer()
        cacheImages()
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: {_ in
            self.updateSongInfo()
        })
    }
    
    func disclaimer() {
        let alert = UIAlertController(title: "Discliamer", message: "", preferredStyle: .alert)
        
        alert.view.tintColor = .black
        alert.view.backgroundColor = .white
        
        alert.view.layer.cornerRadius = 25
        
        // set font of title in alert
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: "Disclaimer", attributes: [NSAttributedString.Key.font:UIFont(name: "Avenir Next", size: 19.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:10))
        alert.setValue(myMutableString, forKey: "attributedTitle")
        
        var myMutableMsg = NSMutableAttributedString()
        myMutableMsg = NSMutableAttributedString(string: "SocialQ will set up a Spotify environment for you. Do not interact with Spotify while using this app.", attributes: [NSAttributedString.Key.font:UIFont(name: "Avenir Next", size: 12.0)!])
        myMutableMsg.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:100))
        alert.setValue(myMutableMsg, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let thirdTab = self.tabBarController?.viewControllers![2] as! SearchSongController
        thirdTab.canDirectAdd = true
        thirdTab.spotifyToken = currentQueue.token!
        thirdTab.currentQueue = currentQueue
        super.viewWillDisappear(animated)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        DispatchQueue.main.async{
            self.cacheImages()
            self.tableView.reloadData()

        }
        
//        let barButtonItem = UIBarButtonItem(title: "End Queue", style: .plain, target: self, action: #selector(addTapped))
//        barButtonItem.tintColor = .purple
//        self.navigationItem.rightBarButtonItem = barButtonItem
        endBtn.clipsToBounds = true
        endBtn.layer.cornerRadius = 10

    }
    
    @IBAction func endQueue(_ sender: Any) {
        // delete from firebase
        
        let ref = Database.database().reference()
        ref.child("Queues/\(currentQueue.title)").removeValue()
        self.performSegue(withIdentifier: "backToHome", sender: self)
    }
    
    
    func updateSongInfo(){
        if (songTitleLbl.text != currentQueue.currentSong?.name){
            songTitleLbl.text = currentQueue.currentSong?.name
            songArtistLbl.text = currentQueue.currentSong?.artist
            updateAlbumImage()
            self.cacheImages()
            print(currentQueue.songs)
            print(currentQueue.keys)
            self.tableView.reloadData()
            print("reloading")
        }
        // get progress of song
        DispatchQueue.global(qos: .background).async {
            let (songProgress, songFraction) = self.currentQueue.checkSongProgress()
            DispatchQueue.main.async{
                self.durationBar.setProgress(songFraction, animated: true)
                if songProgress < 400 {
                    self.currentQueue.playNextSong()
                    //self.updateSongInfo()
                    self.cacheImages()
                    self.tableView.reloadData()
                }
            }
        }
    }

func updateAlbumImage() {
    //api call to get image
    let imagePath = currentQueue.currentSong?.coverPath
    let url = URL(string: imagePath ?? "https://research.engineering.wustl.edu/~todd/todd_test_3.jpg")
    let data = try? Data(contentsOf: url!)
    if (data != nil){
        let image = UIImage(data:data!)
        songImage.image = image
    }
}

func cacheImages() {
    imageCache = []
    for song in currentQueue.songs {
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
    let url = URL(string: currentQueue.playlistSongs[currentQueue.currentSongPoint+1].coverPath!)
    let data = try? Data(contentsOf: url!)
    if (data != nil){
        let image = UIImage(data:data!)
        imageCache.append(image!)
    }

}

func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentQueue.songs.count /*+ currentQueue.playlistLength - 1*/
}

func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    //remove from base playlist

    if (indexPath.row < currentQueue.songs.count-1) { //remove from queue
        self.currentQueue.removeAtLoc(song: self.currentQueue.songs[indexPath.row+1])
        self.cacheImages()
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    
    cell.layer.cornerRadius = 10
    cell.clipsToBounds = true
    
    let cellImg = UIImageView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 90, height: 90))
    //cellImg.image = imageCache[indexPath.row]
    cellImg.layer.cornerRadius=10
    cellImg.clipsToBounds = true
    
    cell.backgroundColor = .darkGray
    
    let cellTitle = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10, y: cell.frame.origin.y + 10, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
    cellTitle.font = UIFont(name: "Avenir Next", size: 18)
    cellTitle.textColor = UIColor(displayP3Red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
    
    let cellDescription = UILabel(frame: CGRect(x: cell.frame.origin.x + cellImg.frame.width + 10 , y: cell.frame.origin.y + cellTitle.frame.height, width: cell.frame.width - cellImg.frame.width, height: tableView.rowHeight/2.0))
    cellDescription.font = UIFont(name: "Avenir Next", size: 13)
    cellDescription.textColor = .white
    
    if (indexPath.row >= currentQueue.songs.count-1){
        cellTitle.text = currentQueue.playlistSongs[currentQueue.currentSongPoint+1].name
        cellDescription.text = currentQueue.playlistSongs[currentQueue.currentSongPoint+1].artist
        cellImg.image = imageCache[indexPath.row]
    }
    else {
        cell.backgroundColor = UIColor(displayP3Red: 189/255, green: 159/255, blue: 235/255, alpha: 1)
        cellTitle.text = currentQueue.songs[indexPath.row+1].name
        cellDescription.text = currentQueue.songs[indexPath.row+1].artist
        cellImg.image = imageCache[indexPath.row]
        cellTitle.textColor = .black
    }
    
    
    cell.addSubview(cellImg)
    cell.addSubview(cellTitle)
    cell.addSubview(cellDescription)
    //        cell.addSubview(dotdotBtn)
    
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.darkGray
    cell.selectedBackgroundView = backgroundView
    
    
    cell.layer.borderColor = UIColor(red: 25/255, green: 20/255, blue: 20/255, alpha: 1).cgColor
    cell.layer.borderWidth = 5
    
    return cell
}

/*
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 if segue.identifier == "searchFromHost" {
 let destination = segue.destination as? SearchSongController
 destination?.isHost = true
 destination?.canDirectAdd = true
 }
 }
 */
}



