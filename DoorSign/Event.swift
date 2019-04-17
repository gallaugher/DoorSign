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
    var startInterval: TimeInterval // same as a Double
    var endInterval: TimeInterval // the TimeIntervals can be conerted to Date()
    var dateString: String
    var timeString: String
    var eventLocation: String
    var eventDescription: String
    var fontSize: Int // 0=small, 1=medium, 2=large
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["eventName": eventName, "startInterval": startInterval, "endInterval": endInterval, "dateString": dateString, "timeString": timeString, "eventLocation": eventLocation, "eventDescription": eventDescription, "fontSize": fontSize]
    }
    
    init(eventName: String, startInterval: TimeInterval, endInterval: TimeInterval, dateString: String, timeString: String, eventLocation: String, eventDescription: String, fontSize: Int, documentID: String) {
        self.eventName = eventName
        self.startInterval = startInterval
        self.endInterval = endInterval
        self.dateString = dateString
        self.timeString = timeString
        self.eventLocation = eventLocation
        self.eventDescription = eventDescription
        self.fontSize = fontSize
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(eventName: "", startInterval: 0.0, endInterval: 0.0, dateString: "", timeString: "", eventLocation: "", eventDescription: "", fontSize: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let eventName = dictionary["eventName"] as! String? ?? ""
        let startInterval = dictionary["startInterval"] as! TimeInterval? ?? 0.0
        let endInterval = dictionary["endInterval"] as! TimeInterval? ?? 0.0
        let dateString = dictionary["dateString"] as! String? ?? ""
        let timeString = dictionary["timeString"] as! String? ?? ""
        let eventLocation = dictionary["eventLocation"] as! String? ?? ""
        let eventDescription = dictionary["eventDescription"] as! String? ?? ""
        let fontSize = dictionary["fontSize"] as! Int? ?? 0
        self.init(eventName: eventName, startInterval: startInterval, endInterval: endInterval, dateString: dateString, timeString: timeString, eventLocation: eventLocation, eventDescription: eventDescription, fontSize: fontSize, documentID: "")
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
