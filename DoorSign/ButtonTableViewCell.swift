//
//  ButtonTableViewCell.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var indentView: UIView!
    
    weak var delegate: PlusAndDisclosureDelegate?
    var indexPath: IndexPath!
    
    @IBAction func plusPressed(_ sender: UIButton) {
        delegate?.didTapPlusButton(at: indexPath)
    }
}
