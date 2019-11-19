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
    
    let title:String
    let key:String
    let basePlaylistID:String
    var playlistSongs:[Track]=[]
    
    // when we enable spotify login, comment this out
    var token:String?
    
    /*var songs:[Track] = []*/
    var songs:[Song] = []
    var add:String //needs to be a String for firebase reasons
    var users: [String] = []
    var playlistLength : Int = 0
    var currentSong:Song?
    
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
                playlistSongs = playlistTracks
                playlistLength = playlistTracks.count
                //let shuffledPlaylistTracks = playlistTracks.shuffled()
                
                var songName = "", songId = "", songArtist = "", songCoverPath = ""
                
                var songDuration = ""
                var songToAdd:Song?
                
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
                    ref.child("Queues/\(title)/allPlaylistSongs/\(songId)/").setValue(songToAdd?.nsDictionary)
                    
                }
                
                var emptyQueue : [NSDictionary] = []
                emptyQueue.append(Song(id: "4phGZZrJZRo4ElhRtViYdl", name: "I'm Yours", artist: "Toad Sprout", coverPath: "Hey", duration: "500").nsDictionary)
                ref.child("Queues/\(title)/queuedSongs").setValue(emptyQueue)
                ref.child("Queues/\(title)/currentSongPointer").setValue(-1)
                ref.child("Queues/\(title)/passKey").setValue(self.key)
                ref.child("Queues/\(title)/directAdd").setValue(self.add)
                ref.child("Queues/\(title)/name").setValue(self.title)
                ref.child("Queues/\(title)/token").setValue(self.token)
                
                playNextSong()
                
                /*let encodedPlaylistTracks = try JSONEncoder().encode(shuffledPlaylistTracks)
                 print(encodedPlaylistTracks.count)
                 // we are shuffling no matter what -- maybe set as an option
                 ref.child("Queues/\(title)/allPlaylistSongs").setValue(encodedPlaylistTracks)
                 let emptyQueue : [Track] = []
                 ref.child("Queues/\(title)/queuedSongs").setValue(emptyQueue)
                 ref.child("Queues/\(title)/currentSongPointer").setValue(0)*/
                //ADD SUGGESTEDSONGS ARRAY TO FIREBASE SETUP HERE
            }
            catch {
                return
            }
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
            for song in songs {
                songName = song.name
                songId = song.id
                songArtist = song.artist
                songCoverPath = song.coverPath!
                songDuration = song.duration!
                songToAdd = Song(id: songId, name: songName, artist: songArtist, coverPath: songCoverPath, duration: "\(songDuration)")
                ref.child("Queues/\(title)/queuedSongs/\(songId)/").setValue(songToAdd?.nsDictionary)
            }
            
            
            /*ref.child("Queues/\(title)/queuedSongs").setValue(songs)*/
        }
        else {
            // SUGGEST SONGS FUNCTIONALITY HERE
        }
    }
    
    func removeFromQueue(song:Song){
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
        //assumed progress already checked
        
        //check queued songs from firebase
        let ref = Database.database().reference()
        var areQueued = false
        var nextQueued : Song?
        var newQueuedList : [Song] = []
        ref.child("Queues/\(title)/queuedSongs").observeSingleEvent(of: .value, with: {snapshot in
            //let queuedSongs = snapshot.value as? [Track]
            do {
                let queuedSongs = JSON(snapshot.value!)
                var counter = 0
                for song in queuedSongs {
                    let swiftySong = JSON(song.1)
                    let tempSong = Song(id: "\(swiftySong["id"])", name: "\(swiftySong["name"])", artist: "\(swiftySong["artist"])", coverPath: "\(swiftySong["coverPath"])", duration: "\(swiftySong["duration"])")
                    if(counter == 1){
                        nextQueued = tempSong
                        areQueued = true
                    }else if(counter != 0){
                        newQueuedList.append(tempSong)
                    }
                    print("song is \(song)")
                    print("swiftysong \(swiftySong)")
                    
                    counter += 1
                }
            } catch {
                return
            }
            
        })
        if (!areQueued) {
            print("no queued")
            //if queued songs == empty -> play from playlist, ++currentSongPointer
            
            var currentPointer = 0
            
            ref.child("Queues/\(title)/currentSongPointer").observeSingleEvent(of: .value, with: {snapshot in
                currentPointer = snapshot.value as! Int
                currentPointer+=1
                var nextSong : Track?
                if currentPointer > self.playlistLength-1{
                    currentPointer = 0
                }
                nextSong=self.playlistSongs[currentPointer]
                ref.child("Queues/\(self.title)/currentSongPointer").setValue(currentPointer)
                if nextSong != nil {
                    playSong(authToken: self.token!, trackId: nextSong!.id)
                    self.currentSong = Song(id: nextSong?.id, name: nextSong!.name, artist: (nextSong?.artists[0].name)!, coverPath: nextSong?.album.images[1].url, duration: "\( nextSong!.duration_ms)")
                    print("current song is \(self.currentSong)")
                }
                //should never enter
                else {
                    //else play top queued song and delete
                    playSong(authToken: self.token!, trackId: nextQueued!.id)
                    ref.child("Queues/\(self.title)/queuedSongs").setValue(newQueuedList)
                    self.currentSong = nextQueued
                }
            })
            //print("current pointer \(currentPointer)")
            /*let singleSongRef = ref.child("Queues/\(title)/allPlaylistSongs").queryLimited(toFirst: UInt(currentPointer+1)).queryLimited(toLast: 1)
             singleSongRef.observe(.value, with: {snapshot in
             do {
             print(snapshot.value!)
             let song = JSON(snapshot.value!)
             let swiftySong = JSON(song)
             print(swiftySong)
             nextSong = Song(id: "\(swiftySong["id"])", name: "\(swiftySong["name"])", artist: "\(swiftySong["artist"])", coverPath: "\(swiftySong["coverPath"])", duration: "\(swiftySong["duration"])")
             
             } catch {
             return
             }
             })
             */
            
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
                var previousSong : Track?

                previousSong=self.playlistSongs[currentPointer]
                self.currentSong = Song(id: previousSong?.id, name: previousSong!.name, artist: (previousSong?.artists[0].name)!, coverPath: previousSong?.album.images[1].url, duration: "\( previousSong!.duration_ms)")
                ref.child("Queues/\(self.title)/currentSongPointer").setValue(currentPointer)
                if previousSong != nil {
                    playSong(authToken: self.token!, trackId: previousSong!.id)
                }
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
    
}

extension Queue: Equatable {
    static func == (queue1: Queue, queue2: Queue) -> Bool {
        return
            queue1.title == queue2.title && queue1.key == queue2.key
    }
}
