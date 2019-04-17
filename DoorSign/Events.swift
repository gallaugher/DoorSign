//
//  Events.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Events {
    var eventArray = [Event]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("events").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.eventArray = []
            // there are querySnapshot!.documents.count documents in the events snapshot
            for document in querySnapshot!.documents {
                let event = Event(dictionary: document.data())
                event.documentID = document.documentID
                self.eventArray.append(event)
            }
            completed()
        }
    }
}
