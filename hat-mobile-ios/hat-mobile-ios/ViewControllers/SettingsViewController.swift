/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Class

/// The settings view controller
class SettingsViewController: UIViewController {
    
    // MARK: - Variables
    
    /// An UpdateLocations instance to resume location services if the switch changes position
    let locationUpdate = UpdateLocations.shared
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the location UISwitch
    @IBOutlet weak var locationSwitchOutlet: UISwitch!
    
    /// An IBOutlet for handling the location tracking UILabel
    @IBOutlet weak var locationTrackingLabel: UILabel!
    
    //MARK: - IBActions 
    
    /**
     This method is called with the switch changes state
     
     - parameter sender: The object that called this method
     */
    @IBAction func locationSwitch(_ sender: Any) {
        
        if self.locationSwitchOutlet.isOn {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
            self.locationTrackingLabel.text = "Location upload to HAT enabled"
        } else {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "false")
            self.locationTrackingLabel.text = "Location upload to HAT disabled"
        }
        
//        locationUpdate.setUpLocationObject(locationUpdate, delegate: UpdateLocations.shared)
        locationUpdate.resumeLocationServices()
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // change view controller title
        self.title = NSLocalizedString("settings_label", comment: "settings title")
        
        if let result = KeychainHelper.GetKeychainValue(key: "trackDevice") {
            
            if result == "true" {
                
                self.locationSwitchOutlet.isOn = true
                self.locationTrackingLabel.text = "location upload to HAT enabled"
            } else {
                
                self.locationSwitchOutlet.isOn = false
                self.locationTrackingLabel.text = "location upload to HAT disabled"
            }
        } else {
            
            _ = KeychainHelper.SetKeychainValue(key: "trackDevice", value: "true")
            self.locationSwitchOutlet.isOn = true
            self.locationTrackingLabel.text = "location upload to HAT enabled"
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
}
