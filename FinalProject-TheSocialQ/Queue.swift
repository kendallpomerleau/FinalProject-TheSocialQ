//
//  Queue.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation

class Queue{
    
    let title:String
    var songs:[Song] = []
    
    init(title: String){
        self.title = title
    }
    
    func addToQueue(song:Song){
        songs.append(song)
    }
    
    func removeFromQueue(song:Song){
        while songs.contains(song) {
            if let songToRemove = songs.firstIndex(of: song) {
                songs.remove(at: songToRemove)
            }
        }
    }
    
}
