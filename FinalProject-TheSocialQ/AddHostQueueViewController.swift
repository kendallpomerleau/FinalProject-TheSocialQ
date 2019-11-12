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
        pickerData = ["Playlist 1", "Playlist 2", "Playlist 3", "Playlist 4", "Playlist 5", "Playlist 6"]
        
        
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
        if segue.identifier == "addQueue" {
            let destination = segue.destination as? HostQueueViewController
            let segment = Access.selectedSegmentIndex
            var add = false
            if segment == 1 {
                add = true
            }
            let newQueue = Queue(title: queueTitle.text!, key: queueKey.text!, add: add)
            destination?.currentQueue = newQueue
        }
    }

}
