//
//  APIStructs.swift
//  SocialQueue
//
//  Created by Kevin Van Cleave on 11/4/19.
//  Copyright © 2019 Kevin Van Cleave. All rights reserved.
//

import Foundation

struct PlayPutRequest: Codable {
    let uris: [String] //"spotify:track:[trackID]"
}
 

struct TrackSearchResult: Codable {
    let tracks: TracksSearchSubResult
}

struct ArtistSearchResult: Codable {
    let artists: ArtistsSearchSubResult
}

struct AlbumSearchResult: Codable {
    let albums: AlbumsSearchSubResult
}

struct TracksSearchSubResult: Codable {
    let href: String
    let items: [Track]
}

struct ArtistsSearchSubResult: Codable {
    let href: String
    let items: [ArtistSearchItem]
}

struct AlbumsSearchSubResult: Codable {
    let href: String
    let items: [Album]
}

struct Track: Codable {
    let album: Album
    let artists: [Artist]
    let duration_ms: Int
    let explicit: Bool
    let id: String
    let name: String
    let type: String
    let uri: String
}

struct ArtistSearchItem: Codable { //when you search for artists in search query
    let genres: [String]
    let id: String
    let images: [Image]
    let name: String
    let type: String
    let uri: String
}


struct Album: Codable {
    let artists: [Artist]
    let id: String
    let images: [Image]
    let name: String
    let release_date: String
    let release_date_precision: String
    let total_tracks: Int
    let type: String
    let uri: String
}

struct Image: Codable {
    let height: Int
    let url: String
    let width: Int
}

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let uri: String
}

struct PlaylistGetResult: Codable {
    let items: [UserPlaylist]
    let next: String?
    let total: Int
}

struct UserPlaylist: Codable {
    let collaborative: Bool
    let id: String
    let images: [Image]
    let name: String
    let owner: PlaylistOwner
    let type: String
    let uri: String
}

struct PlaylistOwner: Codable {
    let display_name: String?
    let id: String
    let type: String
    let uri: String
}

struct PlaylistTracksGetResult: Codable {
    let items: [PlaylistTrack]
    let next: String?
    let total: Int
}

struct PlaylistTrack: Codable {
    let is_local: Bool
    let track: Track
}

struct CurrentPlayback: Codable {
    let timestamp: Int64
    let progress_ms: Int
    let item: Track
    let is_playing: Bool
}

struct FeaturedPlaylists: Codable {
    let message: String?
    let playlists: PlaylistGetResult
}
