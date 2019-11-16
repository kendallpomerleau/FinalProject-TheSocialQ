//
//  APIFunctions.swift
//  SocialQueue
//
//  Created by Kevin Van Cleave on 11/5/19.
//  Copyright © 2019 Kevin Van Cleave. All rights reserved.
//

import Foundation


let authTokenExample = "BQBSDSz0KSJRU-cFnGH5-V-GHznoiSAgXpbL61qrYwWMJHvQNqx6ryPvlFalcsrU-m2EJrPLKnTOJELKu_5BM4YZSoTgLu5gssrxH0SUIBtiQAFkvRU3QC1WUFJsAZD5yq13_On141Px815gN_pB5xfe-zc5NLmcs0wC42qIr3qbPFZa3Dqy0_5IZ38HdtwgYGibJPO6VsZ0osBG6fH7Lmx1C2ay5MArZHhZQuy5C6gK8y9xt9aVDcmQmuzUcJSp8cUW6wvPPr_jKgA"

let trackIdExample = "4lJAkP4hBiqwW78EuXwFqr"

let playURL = "https://api.spotify.com/v1/me/player/play"
let searchURL = "https://api.spotify.com/v1/search"
let skipURL = "https://api.spotify.com/v1/me/player/next"
let prevURL = "https://api.spotify.com/v1/me/player/previous"
let pauseURL = "https://api.spotify.com/v1/me/player/pause"
let seekURL = "https://api.spotify.com/v1/me/player/seek"
let playbackURL = "https://api.spotify.com/v1/me/player"
let userPlaylistURL = "https://api.spotify.com/v1/me/playlists"
let playlistTracksURL = "https://api.spotify.com/v1/playlists/"
let featuredPlaylistURL = "https://api.spotify.com/v1/browse/featured-playlists"
let userTopTracksURL = "https://api.spotify.com/v1/me/top/"
let newReleasesURL = "https://api.spotify.com/v1/browse/new-releases?country=US"

func searchSpotify(authToken: String, query: String, queryLimit: Int = 10) -> [Song]{ //authToken for search requires no scopes
    let searchFullURL = "\(searchURL)?q=\(query)&type=track&market=US&limit=\(queryLimit)"
    let url = URL(string: searchFullURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [Song] = []
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            
            return
        }
        do {
            let searchJson = try JSONDecoder().decode(TrackSearchResult.self, from: data)
            print("data = \(searchJson)")
            returnItemArray = searchJson.tracks.items
        } catch {
            print("Search JSON decode error")
            return
        }
    }
    task.resume()
    return returnItemArray
    
}


func playSong(authToken: String, trackId: String = trackIdExample) { //authToken requires user-modify-playback-state scope
    let url = URL(string: playURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    let encoder = JSONEncoder()
    do {
        let dataPut = PlayPutRequest(uris: ["spotify:track:\(trackId)"])
        let jsonData = try encoder.encode(dataPut)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString ?? "unknownResponseString")")
                return
            }
        }
        task.resume()
    } catch {
        print("error")
    }
    
}


func skipSong(authToken: String, areYouSureYouWantToUseThisMethod: Bool = false) { //requires user-modify-playback-state scope
    if(areYouSureYouWantToUseThisMethod){
        let url = URL(string: skipURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString ?? "unknownResponseString")")
                return
            }
        }
        task.resume()
    }
}

func previousSong(authToken: String, areYouSureYouWantToUseThisMethod: Bool = false) { //requires user-modify-playback-state scope
    if(areYouSureYouWantToUseThisMethod){
        let url = URL(string: prevURL)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString ?? "unknownResponseString")")
                return
            }
        }
        task.resume()
    }
}

func goToPositionInSong(authToken: String, position_ms: Int = 0) { //user-modify-playback-state
    let fullSeekURL = "\(seekURL)?position_ms=\(position_ms)"
    let url = URL(string: fullSeekURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString ?? "unknownResponseString")")
            return
        }
    }
    task.resume()
}

func pauseSong(authToken: String) { //requires user-modify-playback-state scope
    let url = URL(string: pauseURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString ?? "unknownResponseString")")
            return
        }
    }
    task.resume()
    
}

func getUserPlaylists(authToken: String) -> [UserPlaylist]{ //playlist-read-private scope
    let limit = 50
    var offset = 0
    let playlistFullURL = "\(userPlaylistURL)?limit=\(limit)&offset=\(offset)"
    let url = URL(string: playlistFullURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [UserPlaylist] = []
    var done = false
    while(!done){
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                
                return
            }
            do {
                let searchJson = try JSONDecoder().decode(PlaylistGetResult.self, from: data)
                print("data = \(searchJson)")
                if(searchJson.next == nil){
                    done = true
                } else{
                    offset += 50
                }
                returnItemArray.append(contentsOf: searchJson.items)
            } catch {
                print("Search JSON decode error")
                return
            }
        }
        task.resume()
    }
    return returnItemArray
    
}

func getTracks(authToken: String, playlistID: String) -> [Song]{ // no scope needed
    let limit = 100
    var offset = 0
    let fullURL = "\(playlistTracksURL)\(playlistID)/tracks?limit=\(limit)&offset=\(offset)"
    let url = URL(string: fullURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [Song] = []
    var done = false
    while(!done){
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                
                return
            }
            do {
                let searchJson = try JSONDecoder().decode(PlaylistTracksGetResult.self, from: data)
                print("data = \(searchJson)")
                if(searchJson.next == nil){
                    done = true
                } else{
                    offset += limit
                }
                for item in searchJson.items {
                    if (!item.is_local) {
                        returnItemArray.append(item.track)
                    }
                }
                
            } catch {
                print("Search JSON decode error")
                return
            }
        }
        task.resume()
    }
    return returnItemArray
}


func getCurrentPlayback(authToken: String) -> CurrentPlayback?{ //user-read-playback-state
    let url = URL(string: playbackURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItem : CurrentPlayback?
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            
            return
        }
        do {
            let searchJson = try JSONDecoder().decode(CurrentPlayback.self, from: data)
            print("data = \(searchJson)")
            returnItem = searchJson
        } catch {
            print("Search JSON decode error")
            return
        }
    }
    task.resume()
    return returnItem
}

func getFeaturedPlaylists(authToken: String) -> [UserPlaylist] {
    let url = URL(string: featuredPlaylistURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [UserPlaylist] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            
            return
        }
        do {
            let searchJson = try JSONDecoder().decode(FeaturedPlaylists.self, from: data)
            print("data = \(searchJson)")
            
            returnItemArray = searchJson.playlists.items
        } catch {
            print("Search JSON decode error")
            return
        }
    }
    task.resume()
    
    return returnItemArray
}

func getTopTracks(authToken: String) -> [Song] {
    let url = URL(string: "\(userTopTracksURL)tracks")
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [Song] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            
            return
        }
        do {
            let searchJson = try JSONDecoder().decode(TracksSearchSubResult.self, from: data)
            print("data = \(searchJson)")
            
            returnItemArray = searchJson.items
        } catch {
            print("Search JSON decode error")
            return
        }
    }
    task.resume()
    
    return returnItemArray
}


func getNewReleases(authToken: String) -> [Album]{
    let url = URL(string: newReleasesURL)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
    var returnItemArray : [Album] = []
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {
                print("error", error ?? "Unknown error")
                return
        }
        
        guard (200 ... 299) ~= response.statusCode else {
            print("statusCode should be 2xx, but is \(response.statusCode)")
            
            return
        }
        do {
            let searchJson = try JSONDecoder().decode(AlbumSearchResult.self, from: data)
            print("data = \(searchJson)")
            
            returnItemArray = searchJson.albums.items
        } catch {
            print("Search JSON decode error")
            return
        }
    }
    task.resume()
    
    return returnItemArray
}
