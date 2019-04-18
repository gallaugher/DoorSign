//
//  Event.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Event {
    var title: String
    var body: String
    var startTime: Date
    var endTime: Date
    var eventLocation: String
    var eventDescription: String
    var allDay: Bool // No times if all day
    var numOfLines: Int // 0=1, 1=2, 2=full screen
    var fontSize: Int // 0=small, 1=medium, 2=large
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "body": body, "startTime": Timestamp(date: startTime), "endTime": Timestamp(date: endTime), "eventLocation": eventLocation, "eventDescription": eventDescription, "allDay": allDay, "numOfLines": numOfLines, "fontSize": fontSize]
    }
    
    init(title: String, body: String, startTime: Date, endTime: Date, eventLocation: String, eventDescription: String, allDay: Bool, numOfLines: Int, fontSize: Int, documentID: String) {
        self.title = title
        self.body = body
        self.startTime = startTime
        self.endTime = endTime
        self.eventLocation = eventLocation
        self.eventDescription = eventDescription
        self.allDay = allDay
        self.numOfLines = numOfLines
        self.fontSize = fontSize
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(title: "", body: "", startTime: Date(), endTime: Date(), eventLocation: "", eventDescription: "", allDay: false, numOfLines: 1, fontSize: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let body = dictionary["body"] as! String? ?? ""
        let startTimeStamp = dictionary["startTime"] as! Timestamp? ?? Timestamp(date: Date())
        let startTime = startTimeStamp.dateValue()
        let endTimeStamp = dictionary["endTime"] as! Timestamp? ?? Timestamp(date: Date())
        let endTime = endTimeStamp.dateValue()
        let eventLocation = dictionary["eventLocation"] as! String? ?? ""
        let eventDescription = dictionary["eventDescription"] as! String? ?? ""
        let allDay = dictionary["allDay"] as! Bool? ?? false
        let numOfLines = dictionary["numOfLines"] as! Int? ?? 0
        let fontSize = dictionary["fontSize"] as! Int? ?? 0
        self.init(title: title, body: body, startTime: startTime, endTime: endTime, eventLocation: eventLocation, eventDescription: eventDescription, allDay: allDay, numOfLines: numOfLines, fontSize: fontSize, documentID: "")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "events" below.
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("events").document(self.documentID)
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
            ref = db.collection("events").addDocument(data: dataToSave) { error in
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
