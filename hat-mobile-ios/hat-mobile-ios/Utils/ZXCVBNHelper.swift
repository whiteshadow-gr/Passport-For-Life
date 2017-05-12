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

import zxcvbn_ios

// MARK: Class

class ZXCVBNHelper: NSObject {
    
    // MARK: - Show strength meter
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     - returns: <#Returns#>
     */
    class func showPasswordMeterOn(textField: UITextField) -> Int {
        
        let zxcvbn = DBPasswordStrengthMeterView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
        zxcvbn.setLightColor(.rumpelDarkGray, darkColor: .teal)
        zxcvbn.scorePassword(textField.text)
        
        textField.rightViewMode = .always
        textField.rightView = zxcvbn
        
        let tempZxcvbnResult = DBZxcvbn()
        return Int(tempZxcvbnResult.passwordStrength(textField.text).score)
    }

}
