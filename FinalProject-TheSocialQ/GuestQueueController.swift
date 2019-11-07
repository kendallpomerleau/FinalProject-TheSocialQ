//
//  GuestQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class GuestQueueController: UIViewController, UITableViewDataSource {

    var currentQueue:Queue = Queue(title: "")
    var imageCache:[UIImage] = []


    @IBOutlet weak var queueTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtn.layer.cornerRadius = 10
        addBtn.clipsToBounds = true
        queueTitle.text = currentQueue.title

        tableView.dataSource = self
        
        cacheImages()
        // Do any additional setup after loading the view.
    }
    
    func cacheImages() {
        print("caching")
        imageCache = []
        for song in currentQueue.songs {
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
                print("empty image")
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
        
        cell.textLabel!.text = currentQueue.songs[indexPath.section].title
        cell.detailTextLabel?.text = currentQueue.songs[indexPath.section].artist
        cell.imageView?.image = UIImage()
        
        var cellImg : UIImageView = UIImageView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: 60, height: 60))
        cellImg.image = imageCache[indexPath.section]
        cellImg.layer.cornerRadius=10
        cellImg.clipsToBounds = true
        cell.addSubview(cellImg)

        cell.backgroundColor = .darkGray
        cell.textLabel?.textColor = UIColor(displayP3Red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 18)
        
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.font = UIFont(name: "Avenir Next", size: 13)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = backgroundView

        
        cell.layer.borderColor = UIColor(red: 25/255, green: 20/255, blue: 20/255, alpha: 1).cgColor
        cell.layer.borderWidth = 5
        
        return cell
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
