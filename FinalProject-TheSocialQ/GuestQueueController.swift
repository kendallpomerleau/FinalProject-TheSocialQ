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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQueue.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        cell.textLabel!.text = currentQueue.songs[indexPath.row].title
        cell.detailTextLabel?.text = currentQueue.songs[indexPath.row].artist
        cell.imageView?.image = imageCache[indexPath.row]
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
