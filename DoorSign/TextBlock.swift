//
//  TextBlock.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TextBlock {
    var blockText: String
    var blockFontColor: String
    var blockFontSize: CGFloat
    var alignment: Int
    var numberOfLines: Int
    var orderPosition: Int
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["blockText": blockText, "blockFontColor": blockFontColor, "blockFontSize": blockFontSize, "alignment": alignment, "numberOfLines": numberOfLines, "orderPosition": orderPosition]
    }
    
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
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "events" below.
    func saveData(screen: Screen, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("screens").document(screen.documentID).collection("textblocks").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create the new documentID
             ref = db.collection("screens").document(screen.documentID).collection("textblocks").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("*** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ new document created with ref ID \(ref?.documentID ?? "unknown")")
                    self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }
}
