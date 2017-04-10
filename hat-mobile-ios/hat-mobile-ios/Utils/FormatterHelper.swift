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

import Foundation

// MARK: Struct

/// A struct for everything that formats something
struct FormatterHelper {
    
    // MARK: - Date to string formaters
    
    /**
     Formats a date to ISO 8601 format
     
     - parameter date: The date to format
     - returns: String
     */
    static func formatDateToISO(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return dateFormatter.string(from: date as Date)
    }
    
    /**
     Formats a date to ISO 8601 format
     
     - parameter date: The date to format
     - returns: String
     */
    static func formatDateToEpoch(date: Date) -> String {
        
        // get the unix time stamp
        let elapse = date.timeIntervalSince1970
        
        let temp = String(elapse)
        
        let array = temp.components(separatedBy: ".")
        
        if array.count > 0 {
            
            return array[0]
        }
        
        return ""
    }
    
    /**
     Formats a date to the user's defined date as a string
     
     - parameter date: The date to localize
     - parameter dateStyle: The date style to return
     - parameter timeStyle: The time style to return
     - returns: A String representing the formatted date
     */
    static func formatDateStringToUsersDefinedDate(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        
        return DateFormatter.localizedString(from: date, dateStyle: dateStyle, timeStyle: timeStyle).replacingOccurrences(of: ",", with: " -")
    }
    
    /**
     Returns a string from UTC formatted date in with full date and medium time styles
     
     - parameter datetime: The date to convert to string
     - returns: A String representing the date passed as a parameter
     */
    static func getDateString(_ datetime : Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.full
        formatter.timeStyle = DateFormatter.Style.medium
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter.string(from: datetime)
    }
    
    /**
     Returns a string from a UTC formatted date with the specified date format
     
     - parameter datetime: The date to convert to string
     - parameter format: The format of the date
     - returns: A String representing the date passed as a parameter
     */
    static func getDateString(_ datetime : Date, format: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter.string(from: datetime)
    }
    
    // MARK: - String to Date formaters
    
    /**
     Formats a string into a Date
     
     - parameter string: The string to format to a Date
     - returns: Date
     */
    static func formatStringToDate(string: String) -> Date? {
        
        // check if the string to format is empty
        if string == "" {
            
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date = dateFormatter.date(from: string)
        
        // if date is nil try a different format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: string)
        }
        
        // if date is nil try a different format, for twitter format and reformat
        if date == nil {
            
            dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
            date = dateFormatter.date(from: string)
        }
        
        return date
    }
    
    /**
     Returns a Date string from a string representing a UTC date
     
     - parameter dateString: The string to convert into date
     - returns: The date that the string was representing
     */
    static func getDateFromString(_ dateString : String) -> Date! {
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormats.UTC
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter.date(from: dateString)
    }

}
