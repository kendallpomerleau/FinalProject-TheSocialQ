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
    let key:String

    var songs:[Song] = []
    var add:Bool
    
    init(title: String, key: String, add: Bool){
        self.title = title
        self.key = key
        self.add = add
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
