//
//  Screens.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Screens {
    var screenArray: [Screen] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("screens").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.screenArray = []
            // there are querySnapshot!.documents.count documents in the events snapshot
            for document in querySnapshot!.documents {
                let screen = Screen(dictionary: document.data())
                screen.documentID = document.documentID
                self.screenArray.append(screen)
            }
            completed()
        }
    }
}
