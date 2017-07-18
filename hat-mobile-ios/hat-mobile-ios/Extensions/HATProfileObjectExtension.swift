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

import HatForIOS

internal func associatedObject<ValueType: AnyObject>(
    base: Any,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        
        if let associated = objc_getAssociatedObject(base, key) as? ValueType {
            return associated
        }
        
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
        return associated
}

internal func associateObject<ValueType: AnyObject>(
    base: Any,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}

internal class AddedFields { // Every HATProfileObject can have a AddedFields
    
    var currentCountry: String = ""
    
    init() {
        
        currentCountry = ""
    }
    
    init(country: String) {
        
        currentCountry = country
    }
}

private var addedFieldsKey: UInt8 = 0 // We still need this boilerplate

extension HATProfileObject {
    
    var fields: AddedFields { // AddedFields is *effectively* a stored property
        
        get {
            
            return associatedObject(base: self, key: &addedFieldsKey) {
                
                return AddedFields()
            } // Set the initial value of the var
        }
        
        set {
            
            associateObject(base: self, key: &addedFieldsKey, value: newValue)
        }
    }
    
    mutating func initAddedFields() {
        
        fields = AddedFields()
    }
    
    mutating func initAddedFields(fetcedFields: AddedFields) {
        
        fields = fetcedFields
    }
}
