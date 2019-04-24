//
//  Element.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Element {
    var elementName: String
    var elementType: String
    var parentID: String
    var hierarchyLevel: Int // level indented, 0 for home, 1 for first buttons + pages, etc...
    var childrenIDs: [String]
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["elementName": elementName, "elementType": elementType, "parentID": parentID, "hierarchyLevel": hierarchyLevel, "childrenIDs": childrenIDs]
    }
    
    init(elementName: String, elementType: String, parentID: String, hierarchyLevel: Int, childrenIDs: [String], documentID: String) {
        self.elementName = elementName
        self.elementType = elementType
        self.parentID = parentID
        self.hierarchyLevel = hierarchyLevel
        self.childrenIDs = childrenIDs
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(elementName: "", elementType: "", parentID: "", hierarchyLevel: 0, childrenIDs: [String](), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let elementName = dictionary["elementName"] as! String? ?? ""
        let elementType = dictionary["elementType"] as! String? ?? ""
        let parentID = dictionary["parentID"] as! String? ?? ""
        let hierarchyLevel = dictionary["hierarchyLevel"] as! Int? ?? 0
        let childrenIDs = dictionary["childrenIDs"] as! [String]? ?? [String]()
        self.init(elementName: elementName, elementType: elementType, parentID: parentID, hierarchyLevel: hierarchyLevel, childrenIDs: childrenIDs, documentID: "")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "elements" below.
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("elements").document(self.documentID)
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
            ref = db.collection("elements").addDocument(data: dataToSave) { error in
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
