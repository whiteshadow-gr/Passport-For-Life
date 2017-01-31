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

// MARK: Extension

extension Date {

    // MARK: - Time ago
    
    /**
     Takes a NSDate and returns a string of time ago
     
     - parameter date: NSDate object
     
     - returns: a formatted string of time-ago
     */
    func TimeAgoSinceDate() -> String {
        
        // get calendar and now date
        let calendar = Calendar.current
        let now = Date()
        
        // calculate the earliest
        let earliest = (now as NSDate).earlierDate(self)
        // calculate the latest
        let latest = (earliest == now) ? self : now
        
        // set up the componenets
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        // check the components and return the correct string
        if (components.year! >= 2) {
            
            return NSLocalizedString("Last year", comment: "")
        } else if (components.month! >= 2) {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d months ago", comment: ""), components.month!)
        } else if (components.weekOfYear! >= 1) {
            
            return NSLocalizedString("A week ago", comment: "")
        } else if (components.day! >= 2) {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d days ago", comment: ""), components.day!)
        } else if (components.day! >= 1) {
            
            return NSLocalizedString("A day ago", comment: "")
        } else if (components.hour! >= 2) {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d hours ago", comment: ""), components.hour!)
        } else if (components.hour! >= 1) {
            
            return NSLocalizedString("An hour ago", comment: "")
        } else if (components.minute! >= 2) {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes ago", comment: ""), components.minute!)
        } else if (components.minute! >= 1) {
            
            return NSLocalizedString("A minute ago", comment: "")
        } else if (components.second! >= 3) {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d seconds ago", comment: ""), components.second!)
        } else {
            
            return NSLocalizedString("Just now", comment: "")
        }
    }
}