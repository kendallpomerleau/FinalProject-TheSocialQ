//
//  SearchQueueController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation
import UIKit

class SearchQueueController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinBtn: UIButton!
    
    
    var songResults:[Song] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinBtn.layer.cornerRadius = 10
        joinBtn.clipsToBounds = true
        
        // initial songs JUST FOR TESTING
        let circles = Song(id: 1, title: "Circles")
        let cyanide = Song(id: 2, title: "Cyanide")
        songResults.append(circles)
        songResults.append(cyanide)
        
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (songResults.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let currentSong = songResults[indexPath.row]
        myCell.textLabel?.text = currentSong.title
        myCell.textLabel?.textColor = .white
        
        return myCell
    }
    
}
