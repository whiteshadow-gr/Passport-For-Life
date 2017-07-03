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

internal class DataStoreTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var titleOfDataStoreLabel: UILabel!
    @IBOutlet private weak var subtitleOfDataStoreLabel: UILabel!
    
    // MARK: - Auto generated methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Set up cell
    
    class func setUpCell(cell: DataStoreTableViewCell, indexPath: IndexPath) -> DataStoreTableViewCell {
        
        cell.titleOfDataStoreLabel.text = "Name of Section"
        cell.subtitleOfDataStoreLabel.text = "Post & Share your thoughts accross multiple channels"
        
        if indexPath.row % 2 == 0 {
            
            cell.backgroundColor = .groupTableViewBackground
        }
        
        return cell
    }

}
