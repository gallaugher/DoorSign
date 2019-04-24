//
//  Elements.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/23/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Elements {
    var elementArray: [Element] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("elements").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.elementArray = []
            // there are querySnapshot!.documents.count documents in the events snapshot
            for document in querySnapshot!.documents {
                var element = Element(dictionary: document.data())
                element.documentID = document.documentID
                self.elementArray.append(element)
            }
            completed()
        }
    }
}
