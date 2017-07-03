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

internal class BadgesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var badgeImageView: UIImageView!
    
    // MARK: - Create badges
    
    class func createBadges() -> [UIImage] {
        
        var arrayToReturn: [UIImage] = []
        let imageNames = [
            Constants.ImageNames.artsBadge,
            Constants.ImageNames.activityBadge,
            Constants.ImageNames.musicBadge,
            Constants.ImageNames.photosBadge,
            Constants.ImageNames.socialBadge,
            Constants.ImageNames.scienceBadge]
        
        for i in 0...5 {
            
            arrayToReturn.append(UIImage(named: imageNames[i])!)
        }
        
        return arrayToReturn
    }
    
    // MARK: - Set up cell
    
    class func setUpCell(badgeImage: UIImage, cell: BadgesCollectionViewCell) -> BadgesCollectionViewCell {
        
        cell.badgeImageView.image = badgeImage
        
        return cell
    }
}
