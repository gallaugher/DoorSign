//
//  screen.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Screen {
    var screenName: String
    var textBlockArray: [TextBlock] = []
    var documentID: String
    var db: Firestore!
    
    var dictionary: [String: Any] {
        return ["screenName": screenName]
    }
    
    init(screenName: String, documentID: String) {
        self.screenName = screenName
        self.documentID = documentID
        db = Firestore.firestore()
    }
    
    convenience init() {
        self.init(screenName: "", documentID: "")
    }
    
    convenience init(screenName: String) {
        self.init(screenName: screenName, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let screenName = dictionary["screenName"] as! String? ?? ""
        self.init(screenName: screenName, documentID: "")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "screens" below.
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("screens").document(self.documentID)
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
            ref = db.collection("screens").addDocument(data: dataToSave) { error in
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
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("textBlocks").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.textBlockArray = []
            // there are querySnapshot!.documents.count documents in the screens snapshot
            for document in querySnapshot!.documents {
                let textBlock = TextBlock(dictionary: document.data())
                textBlock.documentID = document.documentID
                self.textBlockArray.append(textBlock)
            }
            completed()
        }
    }
}
