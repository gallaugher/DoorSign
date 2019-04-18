//
//  EventDetailTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class EventDetailTableViewController: UITableViewController, UITextViewDelegate {
    
    enum TitleLabelHeight: CGFloat {
        case one = 50
        case two = 104
        case full = 232
        // start of body is TitleHeight + 1
    }
    
    enum NumberOfLines: Int {
        case one = 0
        case two = 1
        case fullScreen = 2
    }
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textBodyLabelView: UITextView!
    
    @IBOutlet weak var numberOfLinesSegment: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!

    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!

    var event: Event!
    var firstLine = ""
    var secondLine = ""
    let dateFormatter = DateFormatter()
    
    let dateTimeCellHeight: CGFloat = 37
    var timeLabelHeight: CGFloat!
    var originalLocationY: CGFloat!
    let startTimePickerCellIndexPath = IndexPath(row: 2, section:
        2)
    let endTimePickerCellIndexPath = IndexPath(row: 4, section:
        2)
    
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

        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if event == nil { // We are adding a new record
            event = Event()
            event.numOfLines = NumberOfLines.fullScreen.rawValue
            event.fontSize = 2
        }
        numberOfLinesSegment.selectedSegmentIndex = event.numOfLines
        handleNumberOfLinesChange()
        startTimePicker.minimumDate = Date()
        
        numberOfLinesSegment.selectedSegmentIndex = event.numOfLines
        updateUserInterface()
        updateDateViews()
    }
    
    func updateUserInterface() {
        numberOfLinesSegment.selectedSegmentIndex = event.numOfLines
        titleTextField.text = event.title
        textBodyLabelView.text = event.body
        fontSizeSegmentedControl.selectedSegmentIndex = event.fontSize
        updateFontSize(selection: event.fontSize)
        // TODO create an updateBody / updateTitleTextFieldSize function
        titleLabel.text = event.title
        startTimePicker.date = event.startTime
        endTimePicker.date = event.endTime
        locationTextField.text = event.eventLocation
        descriptionTextView.text = event.eventDescription
        
        // TODO I need to keep track of a date & time string so I can add properly formatted string to descriptionTextVIew.text & event.body
    }
    
    func updateFontSize(selection: Int) {
        switch selection {
        case 0:
            titleLabel.font = titleLabel.font.withSize(18)
            titleTextField.font = titleTextField.font?.withSize(18)
        case 1:
            titleLabel.font = titleLabel.font.withSize(28)
            titleTextField.font = titleTextField.font?.withSize(28)
        default:
            titleLabel.font = titleLabel.font.withSize(38)
            titleTextField.font = titleTextField.font?.withSize(38)
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
        if event.allDay {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMMM d")
            if startDate == endDate {
                firstLine = dateFormatter.string(from: startTimePicker.date) + "\n"
            } else {
                firstLine = "\(dateFormatter.string(from: startTimePicker.date)) - \(dateFormatter.string(from: endTimePicker.date))" + "\n"
            }
            
            dateFormatter.dateStyle = .none
            secondLine = ""
            dateFormatter.dateStyle = .medium
        } else if startDate == endDate {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMMM d")
            firstLine = dateFormatter.string(from: startTimePicker.date) + "\n" // slash n adds a new line
            dateFormatter.dateStyle = .none
            secondLine = dateFormatter.string(from: startTimePicker.date) + " - " + dateFormatter.string(from: endTimePicker.date) + "\n"
            dateFormatter.dateStyle = .medium
        } else {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMMM d")
            dateFormatter.timeStyle = .short
            firstLine = "\(dateFormatter.string(from: startTimePicker.date)) - " + "\n"
            secondLine = "\(dateFormatter.string(from: endTimePicker.date))" + "\n"
        }
        startTimeLabel.text = dateFormatter.string(from:
            startTimePicker.date)
        endTimeLabel.text = dateFormatter.string(from:
            endTimePicker.date)
        textBodyLabelView.text = "\(firstLine)\(secondLine)\(event.eventLocation)\n\(event.eventDescription)"
    }
    
    func handleAllDayChange(){
        event.allDay = allDaySwitch.isOn
        if allDaySwitch.isOn {
            dateFormatter.timeStyle = .none
            startTimePicker.datePickerMode = .date
            endTimePicker.datePickerMode = .date
            updateDateFields()
        } else {
            dateFormatter.timeStyle = .short
            startTimePicker.datePickerMode = .dateAndTime
            endTimePicker.datePickerMode = .dateAndTime
            updateDateFields()
        }
    }
    
    func handleNumberOfLinesChange() {
        event.numOfLines = numberOfLinesSegment.selectedSegmentIndex
        // var titleFrameRect = titleLabel.frame // rect doesn't matter, we'll change it. This is an easy var init
        let bodyFrameRect = textBodyLabelView.frame
        switch event.numOfLines {
        case NumberOfLines.one.rawValue:
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.frame.width, height: TitleLabelHeight.one.rawValue)
        case NumberOfLines.two.rawValue:
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.frame.width, height: TitleLabelHeight.two.rawValue)
        case NumberOfLines.fullScreen.rawValue:
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.frame.width, height: TitleLabelHeight.full.rawValue)
        default:
            print("😡 ERROR: Case choice should not have occurred!")
        }
        textBodyLabelView.frame = CGRect(x: bodyFrameRect.origin.x, y: titleLabel.frame.origin.y+titleLabel.frame.height+1, width: bodyFrameRect.width, height: 240-titleLabel.frame.origin.y+titleLabel.frame.height+1)
        titleLabel.text = event.title
        textBodyLabelView.text = "\(firstLine)\(secondLine)\(locationTextField.text!)\n\(descriptionTextView.text!)"
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        event.eventDescription = descriptionTextView.text!
        textBodyLabelView.text = descriptionTextView.text!
        textBodyLabelView.text = "\(firstLine)\(secondLine)\(locationTextField.text!)\n\(descriptionTextView.text!)"
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        event.title = titleTextField.text!
        titleLabel.text = titleTextField.text
        event.eventLocation = locationTextField.text!
        textBodyLabelView.text = "\(firstLine)\(secondLine)\(locationTextField.text!)\n\(descriptionTextView.text!)"
    }
    
    @IBAction func titleLineSegmentPressed(_ sender: UISegmentedControl) {
        handleNumberOfLinesChange()
    }
    
    @IBAction func fontSizeSegmentPressed(_ sender: UISegmentedControl) {
        updateFontSize(selection: sender.selectedSegmentIndex)
    }
    
    @IBAction func allDaySwitchPressed(_ sender: UISwitch) {
        handleAllDayChange()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        event.title =  titleTextField.text!
        event.startTime = startTimePicker.date
        event.endTime = endTimePicker.date
        event.body = textBodyLabelView.text!
        event.eventLocation = locationTextField.text!
        event.eventDescription = descriptionTextView.text!
        event.allDay = allDaySwitch.isOn
        event.numOfLines = numberOfLinesSegment.selectedSegmentIndex
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
            return 138
        case (3, 0):
            return 37
        case (4, 0):
            return 74
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("😀😀😀 indexPath.section = \(indexPath.section) indexPath.row = \(indexPath.row)")
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
