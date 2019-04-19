//
//  UIColor+colorWithHexString.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import UIKit

// Takes a String as a hex value and converts it to a UIColor.
// Usage Example: let myColor = UIColor().colorWithHexString(hexString: "3478F6")
// the line above will return a medium blue color, like the default tint for iOS apps
extension UIColor {
    func colorWithHexString(hexString: String, alpha:CGFloat = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

