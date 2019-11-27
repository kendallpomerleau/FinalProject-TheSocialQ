//
//  AppDelegate.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //lazy var rootViewController = HostConnectionController()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    lazy var rootViewController = storyboard.instantiateViewController(withIdentifier: "MyHostConnectionController") as! HostConnectionController

    private var orientation: UIInterfaceOrientationMask = .portrait
    
    func rotateScreen(orientation: UIInterfaceOrientationMask) {
        self.orientation = orientation
        var value = 0;
        if orientation == .landscapeRight {
            value = UIInterfaceOrientation.landscapeRight.rawValue
        }else {
            value = UIInterfaceOrientation.portrait.rawValue
        }
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientation
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if (rootViewController.appRemote.isConnected) {
            rootViewController.appRemote.disconnect()
        }
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let _ = rootViewController.appRemote.connectionParameters.accessToken {
            rootViewController.appRemote.connect()
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let parameters = rootViewController.appRemote.authorizationParameters(from: url);
        
        if (parameters?["error"] != nil) {
            return false
        }
        rootViewController.loginBtn.isHidden = true
        rootViewController.continueBtn.isHidden = false
        rootViewController.existingBtn.isHidden = true
        
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let postParams = "grant_type=authorization_code&code="+String((parameters?["code"])!)+"&redirect_uri=\(rootViewController.SpotifyRedirectURI)&client_id=\(rootViewController.SpotifyClientID)&client_secret=\(rootViewController.SpotifyClientSecret)"

        
        let postData = NSMutableData(data: postParams.data(using: String.Encoding.utf8)!)
        request.httpBody = postData as Data
        
        //request.httpBody = postParams.percentEscaped().data(using: .utf8)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let swiftyJsonVar = JSON(data)
            
            DispatchQueue.main.async {
                self.rootViewController.accessToken = "\(swiftyJsonVar["access_token"])"
                print(swiftyJsonVar["access_token"])
            }

        }

        task.resume()
        return true
    }

}
