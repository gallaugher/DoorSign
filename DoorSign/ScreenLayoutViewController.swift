//
//  ScreenLayoutViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ScreenLayoutViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editBlockOrderButton: UIBarButtonItem!
    
    var screen: Screen!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        hideDoneButtonIfNeeded()
    }
    
    func hideDoneButtonIfNeeded(){
        // Hide done button by setting title to an empty string if
        // you are not adding a newn record.
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if !isPresentingInAddMode {
            doneButton.title = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTextBlock" {
            let destination = segue.destination as! TextBoxDetailTableViewController
            destination.screen = screen
            let selectedIndex = tableView.indexPathForSelectedRow!
            destination.textBlockIndex = selectedIndex.row
        } else {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! TextBoxDetailTableViewController
            destination.screen = screen
            if let selectedIndex = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editBlockOrderPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addBlockTextPressed(_ sender: UIBarButtonItem) {
    }
}

extension ScreenLayoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen.textBlockArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = screen.textBlockArray[indexPath.row].blockText
        return cell
    }
}
