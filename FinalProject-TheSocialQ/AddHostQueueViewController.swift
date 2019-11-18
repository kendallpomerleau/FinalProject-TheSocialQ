//
//  AddHostQueueViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class AddHostQueueViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    @IBOutlet weak var queueKey: UITextField!
    @IBOutlet weak var queueTitle: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var Access: UISegmentedControl!
    @IBOutlet weak var Picker: UIPickerView!

    var pickerData: [String] = [String]()
    var accessToken:String?
    var pickerPlaylists : [UserPlaylist] = [UserPlaylist]()

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        queueTitle.resignFirstResponder()
        queueKey.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        addBtn.layer.cornerRadius = 10
        addBtn.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        //let font = UIFont.systemFont(ofSize: 20)
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 17.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        Access.setTitleTextAttributes(attr as? [NSAttributedString.Key : Any] , for: .normal)
        
        //picker
        self.Picker.delegate = self
        self.Picker.dataSource = self
        pickerData = []
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //update userPlaylists
        if(accessToken != nil || accessToken != ""){
            print("token is \(self.accessToken)")
            let playlists = getUserPlaylists(authToken: self.accessToken!)
            self.pickerPlaylists = playlists
            self.pickerData = []
            for playlist in playlists {
                self.pickerData.append(playlist.name)
            }
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    @IBAction func addClicked(_ sender: UIButton) {
        if (queueKey.text != "" && queueTitle.text != "") {
            self.performSegue(withIdentifier: "addQueue", sender: self)
            
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(Access.selectedSegmentIndex == 1){
            print("segment index = 1")
            self.hidesBottomBarWhenPushed = true
        }
        else if(Access.selectedSegmentIndex == 0){
            print("segment index = 0")
            self.hidesBottomBarWhenPushed = false
        }
        if segue.identifier == "addQueue" {
            print("entered segue")
            let destination = segue.destination as? HostQueueViewController
            let segment = Access.selectedSegmentIndex
            var add = false
            if segment == 1 {
                add = true
            }
            let playlistID = pickerPlaylists[Picker.selectedRow(inComponent: 0)].id
            let newQueue = Queue(title: queueTitle.text!, key: queueKey.text!, add: add, playlistID: playlistID)
            print("about to do queue stuff")
            newQueue.setToken(newToken: accessToken ?? "")
            print("set token")
            newQueue.setupPlayer()

            print("set up player")
            destination?.currentQueue = newQueue
            print("going to destination")
        }
    }

}
