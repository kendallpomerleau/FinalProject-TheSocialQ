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
    var token:String?
    
    var songs:[Track] = []
    var add:String //needs to be a String for firebase reasons
    var users: [String] = []
    var playlistLength : Int = 0
    
    init(title: String, key: String, add: Bool, playlistID: String){
        self.title = title
        self.key = key
        if add {
            self.add = "True"
        }
        else {
            self.add = "False"
        }
        self.token = nil
        self.basePlaylistID = playlistID
        
    }
    
    func setToken(newToken: String) {
        self.token = newToken
    }
    
    func setupPlayer() {
        if( token != nil || token != ""){
            do {
                let ref = Database.database().reference()
                let playlistTracks : [Track] = getTracks(authToken: token!, playlistID: basePlaylistID)
                playlistLength = playlistTracks.count
                let encodedPlaylistTracks = try JSONEncoder().encode(playlistTracks)
                // we are shuffling no matter what -- maybe set as an option
                let shuffledPlaylistTracks = encodedPlaylistTracks.shuffled()
                ref.child("Queues/\(title)/allPlaylistSongs").setValue(shuffledPlaylistTracks)
                let emptyQueue : [Track] = []
                ref.child("Queues/\(title)/queuedSongs").setValue(emptyQueue)
                ref.child("Queues/\(title)/currentSongPointer").setValue(0)
                //ADD SUGGESTEDSONGS ARRAY TO FIREBASE SETUP HERE
            }
            catch {
                return
            }
        }
    }
    
    func addToQueue(song:Track, isHost: Bool, canDirectAdd: Bool){
        if isHost || canDirectAdd{
        
        songs.append(song)
        
        // also add to database
        
        let ref = Database.database().reference()
        ref.child("Queues/\(title)/queuedSongs").setValue(songs)
        }
        else {
            // SUGGEST SONGS FUNCTIONALITY HERE
        }
    }
    
    func removeFromQueue(song:Track){
        if songs.contains(song) {
            if let songToRemove = songs.firstIndex(of: song) {
                songs.remove(at: songToRemove)
                let ref = Database.database().reference()
                ref.child("Queues/\(title)/queuedSongs").setValue(songs)
            }
        }
        
        // also remove from database
    }
    
    func checkSongProgress() -> Int{
        let playback = getCurrentPlayback(authToken: token ?? "")
        guard playback != nil else {
            return 2
        }
        let duration = playback?.item.duration_ms
        let progress = playback?.progress_ms
        let timeLeft = duration! - progress!
        return timeLeft
        
        
    }
    
    func playNextSong() {
        //assumed progress already checked
        
        //check queued songs from firebase
        let ref = Database.database().reference()
        var areQueued = false
        var nextQueued : Track?
        var newQueuedList : [Track] = []
        ref.child("Queues/\(title)/queuedSongs").observeSingleEvent(of: .value, with: {snapshot in
            //let queuedSongs = snapshot.value as? [Track]
            do {
            let queuedSongs = try JSONDecoder().decode([Track].self, from: snapshot.value as! Data)
            if queuedSongs.count != 0{
                areQueued = true
                nextQueued = queuedSongs[0]
                for i in 1 ... queuedSongs.count-1 {
                    newQueuedList.append(queuedSongs[i])
                }
            }
            } catch {
                return
            }
            
        })
        if (!areQueued) {
            //if queued songs == empty -> play from playlist, ++currentSongPointer
            
            var currentPointer = 0
            ref.child("Queues/\(title)/currentSongPointer").observeSingleEvent(of: .value, with: {snapshot in
                currentPointer = snapshot.value as! Int
            })
                var nextSong : Track?
            let singleSongRef = ref.child("Queues/\(title)/allPlaylistSongs").queryEqual(toValue: currentPointer)
                singleSongRef.observe(.value, with: {snapshot in
                    do {
                        nextSong = try JSONDecoder().decode(Track.self, from: snapshot.value as! Data)
                    } catch {
                        return
                    }
                })
            if currentPointer >= playlistLength-1{
                currentPointer = -1
            }
            ref.child("Queues/\(title)/currentSongPointer").setValue(currentPointer+1)
            if nextSong != nil {
                playSong(authToken: token!, trackId: nextSong!.id)
            }
            
        }
        else {
            //else play top queued song and delete
            playSong(authToken: token!, trackId: nextQueued!.id)
            ref.child("Queues/\(title)/queuedSongs").setValue(newQueuedList)
        }
        
        
        
     
    }
    
    func skipSong() {
        playNextSong()
    }
    
    func previousSong() -> Bool{ //bool is true if actually went to previous song
        //check progress and see if we go to start of song or actual previous song
        let progress_ms = getCurrentPlayback(authToken: token!)?.progress_ms
        if (progress_ms! <= 10000) { //ms
            //if song has been playing for less than 10 seconds,
            //go to actual previous song from playlist
            let ref = Database.database().reference()
            var currentPointer = 0
            ref.child("Queues/\(title)/currentSongPointer").observeSingleEvent(of: .value, with: {snapshot in
                currentPointer = snapshot.value as! Int
            })
            if currentPointer == 0{
                currentPointer = playlistLength
            }
            var previousSong : Track?
            let singleSongRef = ref.child("Queues/\(title)/allPlaylistSongs").queryEqual(toValue: currentPointer-1)
                singleSongRef.observe(.value, with: {snapshot in
                    do {
                        previousSong = try JSONDecoder().decode(Track.self, from: snapshot.value as! Data)
                    } catch {
                        return
                    }
                })
            ref.child("Queues/\(title)/currentSongPointer").setValue(currentPointer-1)
            if previousSong != nil {
                playSong(authToken: token!, trackId: previousSong!.id)
            }
            return true
        } else {
            goToPositionInSong(authToken: token!, position_ms: 0)
            return false
        }
    }
    
    func resumePlayingSong() {
        resumeSong(authToken: token!)
    }
    
    func pausePlayingSong() {
        pauseSong(authToken: token!)
    }
    
    func userJoin(username: String) {
        users.append(username)
        //add to firebase
        let ref = Database.database().reference()
        ref.child("Queues/\(title)/users").setValue(users)
    }
    func userLeave(username: String) {
        if let userToRemoveIndex = users.firstIndex(of: username) {
            users.remove(at: userToRemoveIndex)
            let ref = Database.database().reference()
            ref.child("Queues/\(title)/users").setValue(users)
        }
    }
    
}

extension Queue: Equatable {
    static func == (queue1: Queue, queue2: Queue) -> Bool {
        return
            queue1.title == queue2.title && queue1.key == queue2.key
    }
}
