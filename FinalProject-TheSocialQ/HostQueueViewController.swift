//
//  HostQueueViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class HostQueueViewController: UIViewController, UITableViewDataSource {
    
    var currentQueue:Queue = Queue(title: "", key: "", add: false)
    var imageCache:[UIImage] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var AddBtn: UIButton!
    @IBOutlet weak var playSongView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.playSongView.layer.cornerRadius = 10
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        AddBtn.layer.cornerRadius = 10
        AddBtn.clipsToBounds = true
        
        cacheImages()
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func cacheImages() {
        print("caching in guestqueuecontroller")
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
            print("showing cell")
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
            cellDescription.text = currentQueue.songs[indexPath.section].artist
            
            
            let dotdotBtn = UIButton(frame: CGRect(x: cell.frame.maxX, y: cell.frame.origin.y+tableView.rowHeight/2.0, width: 20, height: 10))
            
            dotdotBtn.setBackgroundImage(UIImage(named: "ellipses"), for: .normal)
            
//            dotdotBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            
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
}

