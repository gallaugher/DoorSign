//
//  ScreenListViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/16/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn  // used to be called FirebaseGoogleAuthUI

class ScreenListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var newElements: [Element] = []
    var elements: Elements!
    let indentBase = 26 // previously 41

    // declaring the authUI variable is step
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        
        // initializing the authUI var and setting the delegate are step [3]
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        elements = Elements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        elements.loadData {
            
            if self.elements.elementArray.isEmpty {
                let homeElement = Element(elementName: "Home", elementType: "Home", parentID: "", hierarchyLevel: 0, childrenIDs: [String](), backgroundImageUUID: "", documentID: "")
                
                homeElement.saveData(completed: { (success) in
                    if !success { // if failed
                        print("😡 ERROR: could not save a Home element.")
                        return
                    }
                    self.performSegue(withIdentifier: "AddScreen", sender: nil)
                })
            } else {
                self.elements.loadData {
                    self.newElements = []
                    guard let home = self.elements.elementArray.first(where: {$0.elementType == "Home"}) else {
                        print("ERROR: There was a problem finding the 'Home' element")
                        return
                    }
                    self.sortElements(element: home)
                    self.elements.elementArray = self.newElements
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func sortElements(element: Element) {
        
        print("In sortElements. element.elementName = \(element.elementName), elements.elementArray.count = \(elements.elementArray.count) newElements.count = \(newElements.count)")
        
        newElements.append(element)
        
        if !element.childrenIDs.isEmpty { // if there is at least one child for this element
            for childID in element.childrenIDs { // loop through all children
                if let child = elements.elementArray.first(where: {$0.documentID == childID}) {
                    sortElements(element: child ) // and sort its children, if any
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    // Nothing should change unless you add different kinds of authentication.
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowScreen" {
            let destination = segue.destination as! ScreenLayoutTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.element = elements.elementArray[selectedIndexPath.row]
            destination.elements = elements
        } else { // pass the last element - we'll sort them when they're back. No need to worry about deselecting
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ScreenLayoutTableViewController
            destination.element = elements.elementArray.last
            destination.elements = elements
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
}

extension ScreenListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.elementArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements.elementArray[indexPath.row].elementType {
        case "Home":
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            //cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            return cell
        case "Button":
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonTableViewCell
            cell.delegate = self
            cell.indexPath = indexPath
            var newRect = cell.indentView.frame
            // now change x value & reassign to indentview
            let indentAmount = CGFloat(elements.elementArray[indexPath.row].hierarchyLevel*indentBase)
            newRect = CGRect(x: indentAmount, y: newRect.origin.y, width: newRect.width, height: newRect.height)
            UIView.animate(withDuration: 0.5, animations: {cell.indentView.frame = newRect})
            print("*** Button \(elements.elementArray[indexPath.row].elementName) has a hierarchy level \(elements.elementArray[indexPath.row].hierarchyLevel)")
            print(">>> indenting button view \(indentAmount)")
            cell.button.setTitle(elements.elementArray[indexPath.row].elementName, for: .normal)
            // cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            return cell
        case "Page":
            let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell", for: indexPath) as! PageTableViewCell
            // cell.pageName.text = elements[indexPath.row].name
            cell.delegate = self
            cell.indexPath = indexPath
            var newRect = cell.indentView.frame
            // now change x value & reassign to indentview
            let indentAmount = CGFloat(elements.elementArray[indexPath.row].hierarchyLevel*indentBase)
            newRect = CGRect(x: indentAmount, y: newRect.origin.y, width: newRect.width, height: newRect.height)
            UIView.animate(withDuration: 0.5, animations: {cell.indentView.frame = newRect})
            print("PPP Page \(elements.elementArray[indexPath.row].elementName) has a hierarchy level \(elements.elementArray[indexPath.row].hierarchyLevel)")
            print(">>> indenting page view \(indentAmount)")
            // cell.childrenLabel.text = "\(elements[indexPath.row].chidrenIDs)"
            // if parent has multiple children then <> icons, else return icon
            let parentIndex = elements.elementArray.firstIndex(where: {$0.documentID == elements.elementArray[indexPath.row].parentID})
            if let parentIndex = parentIndex {
                if elements.elementArray[parentIndex].childrenIDs.count > 1 {
                    cell.pageIcon.image = UIImage(named:  "pageGroup")
                } else {
                    cell.pageIcon.image = UIImage(named:  "singlePage")
                }
            }
            return cell
        default:
            print("*** ERROR: cellForRowAt had incorrect case.")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(">> Selected row at indexPath.row: \(indexPath.row), with hierarchy \(elements.elementArray[indexPath.row].hierarchyLevel) <<")
    }
}

// Name of the extension is likely the only thing that needs to change in new projects
extension ScreenListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        
        // Create a frame for a UIImageView to hold our logo
        let marginInsets: CGFloat = 16 // logo will be 16 points from L and R margins
        let imageHeight: CGFloat = 225 // the height of our logo
        let imageY = self.view.center.y - imageHeight // places bottom of UIImageView in the center of the login screen
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}

extension ScreenListViewController: PlusAndDisclosureDelegate {
    func addAButtonAndPage(buttonName: String, indexPath: IndexPath) {
        
        let newButtonID = UUID().uuidString
        let newPageID = UUID().uuidString
        let newButton = Element(elementName: buttonName, elementType: "Button", parentID: elements.elementArray[indexPath.row].documentID, hierarchyLevel: elements.elementArray[indexPath.row].hierarchyLevel+1, childrenIDs: [newPageID], backgroundImageUUID: "", documentID: newButtonID)
        let newPage = Element(elementName: buttonName, elementType: "Page", parentID: newButtonID, hierarchyLevel: elements.elementArray[indexPath.row].hierarchyLevel+2, childrenIDs: [String](), backgroundImageUUID: "", documentID: newPageID)
        let parent = elements.elementArray[indexPath.row]
        parent.childrenIDs.append(newButtonID)
        parent.saveData { (success) in
            newButton.saveData { (success) in
                guard success else {
                    print("😡 ERROR: saving a newButton named \(buttonName)")
                    return
                }
                newPage.saveData { (success) in
                    self.elements.elementArray[indexPath.row].childrenIDs.append(newButtonID)
                    self.elements.elementArray.append(newButton)
                    self.elements.elementArray.append(newPage)
                    let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                    self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
                    self.performSegue(withIdentifier: "AddScreen", sender: nil)
                }
            }
        }
    }
    
    func addPage(indexPath: IndexPath) {
        let newPageID = UUID().uuidString
        let newPage = Element(elementName: elements.elementArray[indexPath.row].elementName, elementType: "Page", parentID: elements.elementArray[indexPath.row].documentID, hierarchyLevel: elements.elementArray[indexPath.row].hierarchyLevel+1, childrenIDs: [String](), backgroundImageUUID: "", documentID: newPageID)
        
        let parent = elements.elementArray[indexPath.row]
        parent.childrenIDs.append(newPageID)
        parent.saveData { (success) in
            
            newPage.saveData { (success) in
                self.elements.elementArray[indexPath.row].childrenIDs.append(newPageID)
                self.elements.elementArray.append(newPage)
                
                let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
                self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
                self.performSegue(withIdentifier: "AddScreen", sender: nil)
            }
        }
    }
    
    
    func didTapPlusButton(at indexPath: IndexPath) {
        switch elements.elementArray[indexPath.row].elementType {
        case "Page", "Home":
            showInputDialog(title: nil,
                            message: "Open new page with a button named:",
                            actionTitle: "Create Button",
                            cancelTitle: "Cancel",
                            inputPlaceholder: nil,
                            inputKeyboardType: .default,
                            actionHandler: {(input:String?) in
                                guard let screenName = input else {
                                    return
                                }
                                self.addAButtonAndPage(buttonName: screenName, indexPath: indexPath)},
                            cancelHandler: nil)
        case "Button":
            showTwoButtonAlert(title: nil,
                               message: "Create a new page from button \(elements.elementArray[indexPath.row].elementName):",
                actionTitle: "Create Page",
                cancelTitle: "Cancel",
                actionHandler: {_ in self.addPage(indexPath: indexPath)},
                cancelHandler: nil)
        default:
            print("ERROR in default case of didTapPlusButton")
        }
    }
    
    func didTapDisclosure(at indexPath: IndexPath) {
        print("*** You Tapped the Disclosure Button at \(indexPath.row)")
        let selectedIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
        self.performSegue(withIdentifier: "ShowScreen", sender: nil)
    }
}
