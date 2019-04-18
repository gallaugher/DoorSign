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
    var eventName: String
    // CAM CODE
//    var startInterval: TimeInterval // same as a Double
//    var endInterval: TimeInterval // the TimeIntervals can be conerted to Date()
    var startTime: Date
    var endTime: Date
    var dateString: String
    var timeString: String
    var eventLocation: String
    var eventDescription: String
    var fontSize: Int // 0=small, 1=medium, 2=large
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["eventName": eventName, "startTime": Timestamp(date: startTime), "endTime": Timestamp(date: endTime), "dateString": dateString, "timeString": timeString, "eventLocation": eventLocation, "eventDescription": eventDescription, "fontSize": fontSize]
    }
    
    init(eventName: String, startTime: Date, endTime: Date, dateString: String, timeString: String, eventLocation: String, eventDescription: String, fontSize: Int, documentID: String) {
        self.eventName = eventName
        self.startTime = startTime
        self.endTime = endTime
        self.dateString = dateString
        self.timeString = timeString
        self.eventLocation = eventLocation
        self.eventDescription = eventDescription
        self.fontSize = fontSize
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(eventName: "", startTime: Date(), endTime: Date(), dateString: "", timeString: "", eventLocation: "", eventDescription: "", fontSize: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let eventName = dictionary["eventName"] as! String? ?? ""
        // let startTime = dictionary["startTime"] as! Date? ?? Date()
        // let endTime = dictionary["endTime"] as! Date? ?? Date()
        let startTimeStamp = dictionary["startTime"] as! Timestamp? ?? Timestamp(date: Date())
        let startTime = startTimeStamp.dateValue()
        let endTimeStamp = dictionary["endTime"] as! Timestamp? ?? Timestamp(date: Date())
        let endTime = endTimeStamp.dateValue()
        let dateString = dictionary["dateString"] as! String? ?? ""
        let timeString = dictionary["timeString"] as! String? ?? ""
        let eventLocation = dictionary["eventLocation"] as! String? ?? ""
        let eventDescription = dictionary["eventDescription"] as! String? ?? ""
        let fontSize = dictionary["fontSize"] as! Int? ?? 0
        self.init(eventName: eventName, startTime: startTime, endTime: endTime, dateString: dateString, timeString: timeString, eventLocation: eventLocation, eventDescription: eventDescription, fontSize: fontSize, documentID: "")
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
