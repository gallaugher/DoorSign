//
//  EventDetailTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class EventDetailTableViewController: UITableViewController, UITextViewDelegate {
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabelView: UITextView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    
    var event: Event!
    
    
    let dateFormatter = DateFormatter()
    
    let dateTimeCellHeight: CGFloat = 37
    var timeLabelHeight: CGFloat!
    var originalLocationY: CGFloat!
    let startTimePickerCellIndexPath = IndexPath(row: 1, section:
        2)
    let endTimePickerCellIndexPath = IndexPath(row: 1, section:
        3)
    
    var isStartTimePickerShown: Bool = false {
        didSet {
            startTimePicker.isHidden = !isStartTimePickerShown
        }
    }
    
    var isEndTimePickerShown: Bool = false {
        didSet {
            endTimePicker.isHidden = !isEndTimePickerShown
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        timeLabelHeight = timeLabel.frame.height
        originalLocationY = locationLabel.frame.origin.y
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if event == nil { // We are adding a new record, fields should be editable
            event = Event()
            event.fontSize = 2
        }
        
        startTimePicker.minimumDate = Date()
        
        updateUserInterface()
        updateDateViews()
    }
    
    func updateUserInterface() {
        fontSizeSegmentedControl.selectedSegmentIndex = event.fontSize
        updateFontSize(selection: event.fontSize)
        nameTextField.text = event.eventName
        nameLabel.text = event.eventName
        timeLabel.text = event.timeString
        dateLabel.text = event.dateString
        locationTextField.text = event.eventLocation
        locationLabel.text = event.eventLocation
        descriptionTextView.text = event.eventDescription
    }
    
    func updateFontSize(selection: Int) {
        switch selection {
        case 0:
            nameLabel.font = nameLabel.font.withSize(18)
            nameTextField.font = nameTextField.font?.withSize(18)
        case 1:
            nameLabel.font = nameLabel.font.withSize(28)
            nameTextField.font = nameTextField.font?.withSize(28)
        default:
            nameLabel.font = nameLabel.font.withSize(38)
            nameTextField.font = nameTextField.font?.withSize(38)
        }
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func updateDateViews() {
        print("\n UPDATE DATE VIEWS")
        print("dateFormatter.string(from: startTimePicker.date) = \(dateFormatter.string(from: startTimePicker.date))")
        print("dateFormatter.string(from: endTimePicker.date) = \(dateFormatter.string(from: endTimePicker.date))")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if startTimePicker.date > endTimePicker.date {
            endTimePicker.date = startTimePicker.date
        }
        
        startTimeLabel.text = dateFormatter.string(from:
            startTimePicker.date)
        endTimeLabel.text = dateFormatter.string(from:
            endTimePicker.date)
        
        updateDateFields()
        
        endTimePicker.minimumDate =
            startTimePicker.date
    }
    
    func updateDateFields() {
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMMM d")
        let startDate = dateFormatter.string(from: startTimePicker.date)
        let endDate = dateFormatter.string(from: endTimePicker.date)
        
        if startDate == endDate {
            UIView.animate(withDuration: 0.25, animations: {self.locationLabel.frame.origin.y = self.originalLocationY; self.descriptionLabelView.frame.origin.y = self.originalLocationY + self.timeLabelHeight}) {_ in
                self.timeLabel.isHidden = false
            }
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMMM d")
            dateLabel.text = dateFormatter.string(from: startTimePicker.date)
            dateFormatter.dateStyle = .none
            timeLabel.text = dateFormatter.string(from: startTimePicker.date) + " - " + dateFormatter.string(from: endTimePicker.date)
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
        } else {
            timeLabel.isHidden = true
            dateFormatter.dateStyle = .none
            dateLabel.text = "\(startDate) - \(endDate)"
            timeLabel.text = ""
            UIView.animate(withDuration: 0.25, animations: {self.locationLabel.frame.origin.y = self.timeLabel.frame.origin.y;
                self.descriptionLabelView.frame.origin.y = self.originalLocationY})
//            dateLabel.text = "\(startDate) \(dateFormatter.string(from: startTimePicker.date)) through "
//            timeLabel.text = "\(endDate) \(dateFormatter.string(from: endTimePicker.date))"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        descriptionLabelView.text = descriptionTextView.text
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        nameLabel.text = nameTextField.text
        locationLabel.text = locationTextField.text
        descriptionLabelView.text = descriptionTextView.text
    }
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        updateFontSize(selection: sender.selectedSegmentIndex)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        event.eventName =  nameTextField.text!
        event.dateString = dateLabel.text!
        event.timeString = timeLabel.text!
        event.eventLocation = locationTextField.text!
        event.eventDescription = descriptionTextView.text!
        event.fontSize = fontSizeSegmentedControl.selectedSegmentIndex

        event.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func dateDidChange(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
    }
}

extension EventDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (startTimePickerCellIndexPath.section,
              startTimePickerCellIndexPath.row):
            if isStartTimePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (endTimePickerCellIndexPath.section,
              endTimePickerCellIndexPath.row):
            if isEndTimePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (0, 0):
            return 240
        case (1, 0):
            return 99
        case (4, 0):
            return 37
        case (5, 0):
            return 74
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (startTimePickerCellIndexPath.section,
              startTimePickerCellIndexPath.row - 1):
            
            if isStartTimePickerShown {
                isStartTimePickerShown = false
            } else if isEndTimePickerShown {
                isEndTimePickerShown = false
                isStartTimePickerShown = true
            } else {
                isStartTimePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case (endTimePickerCellIndexPath.section,
              endTimePickerCellIndexPath.row - 1):
            if isEndTimePickerShown {
                isEndTimePickerShown = false
            } else if isStartTimePickerShown {
                isStartTimePickerShown = false
                isEndTimePickerShown = true
            } else {
                isEndTimePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        default:
            break
        }
    }
}
