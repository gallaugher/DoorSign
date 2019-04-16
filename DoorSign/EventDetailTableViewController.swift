//
//  EventDetailTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class EventDetailTableViewController: UITableViewController {
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabelView: UITextView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    let dateTimeCellHeight: CGFloat = 37
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
        updateDateViews()
    }
    
    func updateDateViews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        startTimeLabel.text = dateFormatter.string(from:
            startTimePicker.date)
        endTimeLabel.text = dateFormatter.string(from:
            endTimePicker.date)
        
        startTimePicker.minimumDate = Date()
        endTimePicker.minimumDate =
            startTimePicker.date.addingTimeInterval(3600)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
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
