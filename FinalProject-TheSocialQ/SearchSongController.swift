//
//  SearchSongController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class SearchSongController: UIViewController {
    
    var songResults:[Song] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // INITIAL SONGS JUST FOR TESTING
        let circles = Song(id: 1, title: "Circles")
        let cyanide = Song(id: 2, title: "Cyanide")
        
        songResults.append(circles)
        songResults.append(cyanide)
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
