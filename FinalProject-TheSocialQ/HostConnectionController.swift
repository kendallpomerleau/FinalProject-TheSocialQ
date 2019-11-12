//
//  HostConnectionController.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class HostConnectionController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, UIApplicationDelegate {
    
    let SpotifyClientID = "cb2d7b9941a84f4a94f41c450fa08a09"
    let SpotifyRedirectURI = URL(string: "finalproject-thesocialq://")!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    @IBOutlet weak var loginBtn: UIButton!
   
    
    var accessToken = ""
//    var auth = SPTAuth.defaultInstance()!
//    var session:SPTSession!
//    var player: SPTAudioStreamingController?
//    var loginUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        


        // Do any additional setup after loading the view.
        
    }

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    
    func update(playerState: SPTAppRemotePlayerState) {
//        if lastPlayerState?.track.uri != playerState.track.uri {
//            fetchArtwork(for: playerState.track)
//        }
        lastPlayerState = playerState
//        trackLabel.text = playerState.track.name
//        if playerState.isPaused {
//            pauseAndPlayButton.setImage(UIImage(named: "play"), for: .normal)
//        } else {
//            pauseAndPlayButton.setImage(UIImage(named: "pause"), for: .normal)
//        }
    }
    
//    func updateViewBasedOnConnected() {
//        if (appRemote.isConnected) {
//            connectButton.isHidden = true
////            disconnectButton.isHidden = false
////            connectLabel.isHidden = true
////            imageView.isHidden = false
////            trackLabel.isHidden = false
////            pauseAndPlayButton.isHidden = false
//        } else {
////            disconnectButton.isHidden = true
//            connectButton.isHidden = false
////            connectLabel.isHidden = false
////            imageView.isHidden = true
////            trackLabel.isHidden = true
////            pauseAndPlayButton.isHidden = true
//        }
//    }
    
    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }
    
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        update(playerState: playerState)
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }
    
    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }
    
  
    
    
    
    
    //this is what should go here
    //https://developer.spotify.com/documentation/ios/quick-start/
    


   
    @IBAction func tapConnect(_ sender: UIButton) {
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
        
        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
