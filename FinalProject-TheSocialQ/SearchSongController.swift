//
//  SearchSongController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class SearchSongController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    
    var songResults:[Song] = []
    var imageCache:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cell.textLabel!.text = songResults[indexPath.row].title
        cell.detailTextLabel?.text = songResults[indexPath.row].artist
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
