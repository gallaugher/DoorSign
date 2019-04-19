//
//  TextBlock.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import UIKit

class TextBlock {
    var blockText: String
    var blockFontColor: String
    var blockFontSize: CGFloat
    var alignment: Int
    var numberOfLines: Int
    var orderPosition: Int
    var documentID: String
    
    init(blockText: String, blockFontColor: String, blockFontSize: CGFloat, alignment: Int, numberOfLines: Int, orderPosition: Int, documentID: String) {
        self.blockText = blockText
        self.blockFontColor = blockFontColor
        self.blockFontSize = blockFontSize
        self.alignment = alignment
        self.numberOfLines = numberOfLines
        self.orderPosition = orderPosition
        self.documentID = ""
    }
    
    convenience init() {
        self.init(blockText: "", blockFontColor: "000000", blockFontSize: Constants.largeFontSize, alignment: Constants.leftAlignment, numberOfLines: 1, orderPosition: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let blockText = dictionary["blockText"] as! String? ?? ""
        let blockFontColor = dictionary["blockFontColor"] as! String? ?? "FFFFFF"
        let blockFontSize = dictionary["blockFontSize"] as! CGFloat? ?? Constants.largeFontLineHeight
        let alignment = dictionary["alignment"] as! Int? ?? Constants.leftAlignment
        let numberOfLines = dictionary["numberOfLines"] as! Int? ?? 1
        let orderPosition = dictionary["orderPosition"] as! Int? ?? 0
        self.init(blockText: blockText, blockFontColor: blockFontColor, blockFontSize: blockFontSize, alignment: alignment, numberOfLines: numberOfLines, orderPosition: orderPosition, documentID: "")
    }
}
