//
//  SearchSongController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class SearchSongController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var songResults:[Song] = []
    var imageCache:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load default songs (popular from API)
        // JUST FOR TESTING
        let circles = Song(id: 1, title: "Circles", artist:"Post Malone", coverPath: "https://i.scdn.co/image/94105e271865c28853bfb7b44b38353a2fea45d6")
        let cyanide = Song(id: 2, title: "Cyanide", artist:"Daniel Caesar", coverPath: "https://i.scdn.co/image/ab67616d0000b2737607aa9ae7904e1b12907c93")
        songResults.append(circles)
        songResults.append(cyanide)
        
        tableView.dataSource = self
        tableView.rowHeight = 90

        // Do any additional setup after loading the view.
        
        cacheImages()
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
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
        
        cellTitle.text = songResults[indexPath.row].title
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
        
        return cell
    }
    
    @objc func buttonClicked(sender : UIButton){
        let alert = UIAlertController(title: "Clicked", message: "You have clicked on the button", preferredStyle: .alert)
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
