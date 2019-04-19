//
//  TextBlocks.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/19/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class TextBlocks {
    var textBlocksArray: [TextBlock] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(screen: Screen, completed: @escaping () -> ())  {
        guard screen.documentID != "" else {
            return
        }
        db.collection("screens").document(screen.documentID).collection("textblocks").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.textBlocksArray = []
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let textBlock = TextBlock(dictionary: document.data())
                textBlock.documentID = document.documentID
                self.textBlocksArray.append(textBlock)
            }
            completed()
        }
    }
}
