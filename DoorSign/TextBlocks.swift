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
    
    func loadData(element: Element, completed: @escaping () -> ())  {
        guard element.documentID != "" else {
            return
        }
        db.collection("textblocks").whereField("parentID", isEqualTo: element.documentID).addSnapshotListener { (querySnapshot, error) in
        //db.collection("elements").document(element.documentID).collection("textblocks").addSnapshotListener { (querySnapshot, error) in
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
        
        //        let elementToQuery = element.documentID
        //        db.collection("textblocks").whereField("parentID", isEqualTo: elementToQuery)  { (querySnapshot, error) in
        //            guard error == nil else {
        //                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
        //                return completed()
        //            }
        //            self.textBlocksArray = []
        //            // there are querySnapshot!.documents.count documents in the spots snapshot
        //            for document in querySnapshot!.documents {
        //                let textBlock = TextBlock(dictionary: document.data())
        //                textBlock.documentID = document.documentID
        //                self.textBlocksArray.append(textBlock)
        //            }
        //            completed()
        //        }
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "events" below.
    func saveData(element: Element, completed: @escaping (Bool) -> ()) {
        var allSaved = true
        for textBlock in self.textBlocksArray {
            textBlock.parentID = element.documentID
            textBlock.saveData(element: element) { (success) in
                if !success {
                    allSaved = false
                }
            }
        }
        completed(allSaved)
    }
}
