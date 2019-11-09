//
//  HostConnectionController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class HostConnectionController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        
        facebookBtn.layer.cornerRadius = 10
        facebookBtn.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    
    //this is what should go here
    //https://developer.spotify.com/documentation/ios/quick-start/
    
//    let SpotifyClientID = "cb2d7b9941a84f4a94f41c450fa08a09"
//    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
//    
//    lazy var configuration = SPTConfiguration(
//        clientID: SpotifyClientID,
//        redirectURL: SpotifyRedirectURL
//    )
//    
//    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        let parameters = appRemote.authorizationParameters(from: url);
//        
//        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//            appRemote.connectionParameters.accessToken = access_token
//            self.accessToken = access_token
//        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            // Show the error
//        }
//        return true
//    }
//    
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
//        appRemote.connectionParameters.accessToken = self.accessToken
//        appRemote.delegate = self
//        return appRemote
//    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
