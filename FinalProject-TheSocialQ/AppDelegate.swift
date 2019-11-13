//
//  AppDelegate.swift
//  FinalProject-TheSocialQ
//
//  Created by Kendall Pomerleau on 11/4/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var rootViewController = HostConnectionController()
    
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
        // Override point for customization after application launch.
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = rootViewController
//        window?.makeKeyAndVisible()
        return true
    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        rootViewController.sessionManager.application(app, open: url, options: options)
//        return true
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if (rootViewController.appRemote.isConnected) {
            rootViewController.appRemote.disconnect()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let token = rootViewController.appRemote.connectionParameters.accessToken {
            rootViewController.appRemote.connect()
            print(token)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            print("going")
        let parameters = rootViewController.appRemote.authorizationParameters(from: url);
        
//        var request = NSMutableURLRequest(URL: NSURL(string: "https://accounts.spotify.com/api/token/"))
//        var session = NSURLSession.sharedSession()
//        request.HTTPMethod = "POST"
//
//        var params = ["username":"jameson", "password":"password"] as Dictionary<String, String>
//
//        var err: NSError?
//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postParams = "grant_type=authorization_code&code="+String((parameters?["code"])!)+"&redirect_uri=\(rootViewController.SpotifyRedirectURI)&client_id=\(rootViewController.SpotifyClientID)&client_secret=\(rootViewController.SpotifyClientSecret)"
//        let postParams: [String: Any] = [
//            "grant_type": "authorization_code",
//            "code": String((parameters?["code"])!),
//            "redirect_uri": "\(rootViewController.SpotifyRedirectURI)",
//            "client_id":rootViewController.SpotifyClientID,
//            "client_secret":rootViewController.SpotifyClientSecret
//        ]
        
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

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            let swiftyJsonVar = JSON(data)
            self.rootViewController.accessToken = "\(swiftyJsonVar["token"])"
        }

        task.resume()
            if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                rootViewController.appRemote.connectionParameters.accessToken = access_token
                rootViewController.accessToken = access_token
                print(rootViewController.accessToken)
            } else if (parameters?[SPTAppRemoteErrorDescriptionKey]) != nil {
                print("error")
            }
            return true
        }
    
  


}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
