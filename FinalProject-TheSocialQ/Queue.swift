//
//  Queue.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class Queue: Decodable, Encodable{
    
    var title:String
    let key:String
//    let reconnectKey:String
    let basePlaylistID:String
    //var playlistSongs:[Track]=[]
    var playlistSongs:[Song] = []
    
    // when we enable spotify login, comment this out
    var token:String?
    
    /*var songs:[Track] = []*/
    var songs:[Song] = []
    var suggestions:[Song] = []
    var add:String //needs to be a String for firebase reasons
    var users: [String] = []
    var playlistLength : Int = 0
    var currentSong:Song?
    var currentSongPoint:Int = 0
    var isQueued:Bool?
    var topOfQueueKey = "0"
    var keys:[Int] = []
    
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
        self.isQueued = false
//        self.reconnectKey = reconnectKey
        self.currentSongPoint = 0
        self.keys = [0]
        
    }
    
    func setToken(newToken: String) {
        self.token = newToken
    }
    
    func setupPlayer() {
        if( token != nil || token != ""){
            // if queue already exists
            let ref = Database.database().reference()
 
            let playlistTracks : [Track] = getTracks(authToken: token!, playlistID: basePlaylistID)
            
            playlistSongs = []
            for track in playlistTracks {
                let newSong = Song(id: track.id, name: track.name, artist: (track.artists[0].name), coverPath: track.album.images[1].url, duration: "\( track.duration_ms)")
                playlistSongs.append(newSong)
            }
            playlistLength = playlistSongs.count
            //let shuffledPlaylistTracks = playlistTracks.shuffled()
            
            var songName = "", songId = "", songArtist = "", songCoverPath = ""
            
            var songDuration = ""
            var songToAdd:Song?
            
            var songQueue:[NSDictionary] = []
            for track in playlistTracks {
                songName = track.name
                songId = track.id
                songArtist = ""
                for artist in track.artists {
                    songArtist += artist.name
                }
                songCoverPath = track.album.images[1].url
                songDuration = "\(track.duration_ms)"
                songToAdd = Song(id: songId, name: songName, artist: songArtist, coverPath: songCoverPath, duration: "\(songDuration)")
                songQueue.append(songToAdd!.nsDictionary)
                
            }
            ref.child("Queues/\(title)/allPlaylistSongs").setValue(songQueue)

            
            var emptyQueue : [NSDictionary] = []
            let toadSprout = Song(id: "4phGZZrJZRo4ElhRtViYdl", name: "I'm Yours", artist: "Toad Sprout", coverPath: "Hey", duration: "500")
            emptyQueue.append(toadSprout.nsDictionary)
            
            
            songs.append(toadSprout)
            ref.child("Queues/\(title)/queuedSongs").setValue(emptyQueue)
            ref.child("Queues/\(title)/currentSongPointer").setValue(-1)
            ref.child("Queues/\(title)/passKey").setValue(self.key)
            ref.child("Queues/\(title)/directAdd").setValue(self.add)
            ref.child("Queues/\(title)/name").setValue(self.title)
            ref.child("Queues/\(title)/token").setValue(self.token)
//            ref.child("Queues/\(title)/reconnectKey").setValue(self.reconnectKey)
            ref.child("Queues/\(title)/suggestions").setValue(emptyQueue)
            
            ref.child("Queues/\(title)/queuedSongs").observe(.value , with: { (snapshot) in

                let queuedFirebase = snapshot.value as? [Any] ?? []
                
                self.isQueued = true
                
                var numSongsInFirebase = 0
                var newSong:Song?
                if self.songs.isEmpty{
                    for song in queuedFirebase {
                        let swiftyJsonVar = JSON(song)
                        newSong = Song(id: "\(swiftyJsonVar["id"])", name: "\(swiftyJsonVar["name"])", artist: "\(swiftyJsonVar["artist"])", coverPath: "\(swiftyJsonVar["coverPath"])", duration: "\(swiftyJsonVar["duration"]))")
                        self.songs.append(newSong!)
                    }
                }
                else {
                    for song in queuedFirebase {
                        numSongsInFirebase+=1
                        let swiftyJsonVar = JSON(song)
                        newSong = Song(id: "\(swiftyJsonVar["id"])", name: "\(swiftyJsonVar["name"])", artist: "\(swiftyJsonVar["artist"])", coverPath: "\(swiftyJsonVar["coverPath"])", duration: "\(swiftyJsonVar["duration"]))")
                    }
                    if (newSong != nil){
                        if !self.songs.contains(newSong!) {
                            self.songs.append(newSong!)

                        }
                    }
                }
                
                
//                if self.songs.count < numSongsInFirebase-1 {
//                }
                
                var setKey = false
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    if (snap.key > "0" && !setKey){
                        self.topOfQueueKey = snap.key
                        setKey = true
                    }
                }
                
            })
            
            playNextSong()
        }
    }
    
    func addToQueue(song:Song, isHost: Bool, canDirectAdd: Bool){
        if isHost || canDirectAdd{
            
            songs.append(song)
            // also add to database
            
            let ref = Database.database().reference()
            var songName = "", songId = "", songArtist = "", songCoverPath = ""
            var songDuration = ""
            var songToAdd:Song?
            songName = song.name
            songId = song.id
            songArtist = song.artist
            songCoverPath = song.coverPath!
            songDuration = song.duration ?? "0"
            songToAdd = Song(id: songId, name: songName, artist: songArtist, coverPath: songCoverPath, duration: "\(songDuration)")
            isQueued =  true
            let key = keys[keys.count-1]+1
            keys.append(key)
            ref.child("Queues/\(title)/queuedSongs/").child("\(key)").setValue(songToAdd?.nsDictionary)
            
        }
        else {
            // SUGGEST SONGS FUNCTIONALITY HERE
            suggestions.append(song)
            let ref = Database.database().reference()
            var songName = "", songId = "", songArtist = "", songCoverPath = ""
            var songDuration = ""
            var songToAdd:Song?
            songName = song.name
            songId = song.id
            songArtist = song.artist
            songCoverPath = song.coverPath!
            songDuration = song.duration ?? "0"
            songToAdd = Song(id: songId, name: songName, artist: songArtist, coverPath: songCoverPath, duration: "\(songDuration)")

            ref.child("Queues/\(title)/suggestions/").child("\(songId)").setValue(songToAdd?.nsDictionary)
        }
    }
    
    func removeFromQueue(song:Song){
        if songs.contains(song) {
            if let songToRemove = songs.firstIndex(of: song) {
                songs.remove(at: songToRemove)
                
                let key = keys[songToRemove]
                keys.remove(at: songToRemove)
                let ref = Database.database().reference()
                ref.child("Queues/\(title)/queuedSongs/\(key)").removeValue()
            }
        }
        
    }
    
    func removeAtLoc(song:Song){
        if songs.contains(song){
            if let songToRemove = songs.firstIndex(of: song){
                songs.remove(at: songToRemove)
                
                let key = keys[songToRemove]
                keys.remove(at: songToRemove)
                let ref = Database.database().reference()
                ref.child("Queues/\(title)/queuedSongs/\(key)").removeValue()

            }
        }
    }
    
    func removeSuggestion(song:Song){
        if suggestions.contains(song) {
            if let songToRemove = suggestions.firstIndex(of: song) {
                suggestions.remove(at: songToRemove)
                
                let ref = Database.database().reference()
                ref.child("Queues/\(title)/suggestions/\(song.id!)").removeValue()
            }
        }
    }
    
    func checkSongProgress() -> (Int, Float) {
        let playback = getCurrentPlayback(authToken: token ?? "")
        guard playback != nil else {
            return (2, 2)
        }
        let duration = playback?.item.duration_ms
        let progress = playback?.progress_ms
        let timeLeft = duration! - progress!
        return (timeLeft, (Float(progress!)/Float(duration!)))
        
        
    }
    
    func checkSongProgressAsFloat() -> Float{
        let playback = getCurrentPlayback(authToken: token ?? "")
        guard playback != nil else {
            return 2
        }
        let duration = playback?.item.duration_ms
        let progress = playback?.progress_ms
        let timeLeft = (Float(progress!)/Float(duration!))
        return timeLeft
        
        
    }
    
    func checkSongProgressAsTime() -> String {
        let playback = getCurrentPlayback(authToken: token ?? "")
        let progress = playback?.progress_ms
        let progressMinutes = progress!/60000
        let progressSeconds = progress!/1000
        let time = "\(progressMinutes):\(progressSeconds)"
        return time
    }
    
    func playNextSong() {
        if (self.songs.count == 1) {
            isQueued = false
        }
        //assumed progress already checked
        
        //check queued songs from firebase
        let ref = Database.database().reference()
        var nextQueued : Song?
        
        if (!self.isQueued!) {
            
            //if queued songs == empty -> play from playlist, ++currentSongPointer
            var currentPointer = 0
            
            ref.child("Queues/\(title)/currentSongPointer").observeSingleEvent(of: .value, with: {snapshot in
                currentPointer = snapshot.value as! Int
                currentPointer+=1
                var nextSong : Song?
                if currentPointer > self.playlistLength-1{
                    currentPointer = 0
                }
                nextSong = self.playlistSongs[currentPointer]
                ref.child("Queues/\(self.title)/currentSongPointer").setValue(currentPointer)
                if nextSong != nil {
                    playSong(authToken: self.token!, trackId: nextSong!.id)
                    self.currentSong = Song(id: nextSong?.id, name: nextSong!.name, artist: (nextSong?.artist)!, coverPath: nextSong?.coverPath!, duration: "\( nextSong!.duration!)")
                }
                self.currentSongPoint = currentPointer
            })
            
        }
        else {
            //else play top queued song and delete
            playSong(authToken: self.token!, trackId: songs[1].id!)
            nextQueued = songs[1]
            removeFromQueue(song: songs[1])
            if (self.songs.count == 1) {
                self.isQueued = false
            }
            self.currentSong = nextQueued
        }
    }
    
    func skipSong() {
        playNextSong()
    }
    
    func previousSong() -> Bool{ //bool is true if actually went to previous song
        //check progress and see if we go to start of song or actual previous song
        let progress_ms = getCurrentPlayback(authToken: token!)?.progress_ms
        if (progress_ms! <= 5000) { //ms
            //if song has been playing for less than 5 seconds,
            //go to actual previous song from playlist
            let ref = Database.database().reference()
            var currentPointer = 0
            ref.child("Queues/\(title)/currentSongPointer").observeSingleEvent(of: .value, with: {snapshot in
                currentPointer = snapshot.value as! Int
                currentPointer -= 1
                print("currentPointer \(currentPointer)")
                if currentPointer == -1 {
                    currentPointer = self.playlistLength-1
                }
                print("currentPointer after if \(currentPointer)")
                //var previousSong : Track?
                var previousSong: Song?
                previousSong = self.playlistSongs[currentPointer]
                self.currentSong = Song(id: previousSong!.id!, name: previousSong!.name, artist: (previousSong!.artist), coverPath: previousSong?.coverPath!, duration: "\( previousSong!.duration!)")
                ref.child("Queues/\(self.title)/currentSongPointer").setValue(currentPointer)
                if previousSong != nil {
                    
                    playSong(authToken: self.token!, trackId: previousSong!.id)
                }
                self.currentSongPoint = currentPointer
                return
            })
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
    
    func loadSuggestions(){
        let ref = Database.database().reference()
        ref.child("Queues/\(title)/suggestions").observe(.childAdded , with: { (snapshot) in

            let queuedFirebase = snapshot.value as! NSDictionary
//            let key = snapshot.key
            let swiftyJsonVar = JSON(queuedFirebase)
            let songToAdd = Song(id: "\(swiftyJsonVar["id"])", name: "\(swiftyJsonVar["name"])", artist: "\(swiftyJsonVar["artist"])", coverPath: "\(swiftyJsonVar["coverPath"])", duration: "\(swiftyJsonVar["duration"]))")
            if (songToAdd.name != "" && songToAdd.name != "null"){
                if !self.suggestions.contains(songToAdd) {
                    self.suggestions.append(songToAdd)
                }
            }
            
//            let suggestedFirebase = snapshot.value as? [Any] ?? []
//
//            var numSuggestedInFirebase = 0
//            var newSong:Song?
//            for song in suggestedFirebase {
//                numSuggestedInFirebase+=1
//                let swiftyJsonVar = JSON(song)
//                newSong = Song(id: "\(swiftyJsonVar["id"])", name: "\(swiftyJsonVar["name"])", artist: "\(swiftyJsonVar["artist"])", coverPath: "\(swiftyJsonVar["coverPath"])", duration: "\(swiftyJsonVar["duration"]))")
//            }
//                if self.suggestions.count < numSuggestedInFirebase-1 {
//                    self.suggestions.append(newSong!)
//            }
//
        })
        //if the suggestions queue is empty add a label taht says you have no suggested songs yet
    }
    
}

extension Queue: Equatable {
    static func == (queue1: Queue, queue2: Queue) -> Bool {
        return
            queue1.title == queue2.title && queue1.key == queue2.key
    }
}
