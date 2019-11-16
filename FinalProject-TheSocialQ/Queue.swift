//
//  Queue.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Queue: Decodable, Encodable{
    
    let title:String
    let key:String
    let basePlaylistID:String
    
    // when we enable spotify login, comment this out
    let token:String?

    var songs:[Song] = []
    var add:Bool
    var users: [String] = []
    
    init(title: String, key: String, add: Bool, playlistID: String){
        self.title = title
        self.key = key
        self.add = add
        self.token = nil
        self.basePlaylistID = playlistID
    }
    
    func addToQueue(song:Song){
        songs.append(song)
        
        // also add to database
        
        let ref = Database.database().reference()
        ref.child("\(title)/queuedSongs").setValue(songs)
    }
    
    func removeFromQueue(song:Song){
        if songs.contains(song) {
            if let songToRemove = songs.firstIndex(of: song) {
                songs.remove(at: songToRemove)
                let ref = Database.database().reference()
                ref.child("\(title)/queuedSongs").setValue(songs)
            }
        }
        
        // also remove from database
    }
    
    func userJoin(username: String) {
        users.append(username)
        //add to firebase
        let ref = Database.database().reference()
        ref.child("\(title)/users").setValue(users)
    }
    func userLeave(username: String) {
        if let userToRemoveIndex = users.firstIndex(of: username) {
            users.remove(at: userToRemoveIndex)
            let ref = Database.database().reference()
            ref.child("\(title)/users").setValue(users)
        }
    }
    
}

extension Queue: Equatable {
    static func == (queue1: Queue, queue2: Queue) -> Bool {
        return
            queue1.title == queue2.title && queue1.key == queue2.key
    }
}
