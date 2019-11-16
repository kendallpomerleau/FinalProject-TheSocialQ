//
//  Song.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import Foundation

struct Song: Decodable, Encodable {
    let id: String!
    let name: String
    let artist: String
    let coverPath: String?
    //other variables?
}

extension Song: Equatable {
    static func == (song1: Song, song2: Song) -> Bool {
        return
            song1.id == song2.id
    }
}
