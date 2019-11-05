//
//  AddHostQueueViewController.swift
//  FinalProject-TheSocialQ
//
//  Created by Sarah Chitty on 11/5/19.
//  Copyright © 2019 Kendall Pomerleau. All rights reserved.
//

import UIKit

class AddHostQueueViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    @IBOutlet weak var Access: UISegmentedControl!
    @IBOutlet weak var Picker: UIPickerView!
    var pickerData: [String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
