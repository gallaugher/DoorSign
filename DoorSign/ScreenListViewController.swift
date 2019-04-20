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
    
    var screens: Screens!
    // declaring the authUI variable is step [2]
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        // initializing the authUI var and setting the delegate are step [3]
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        screens = Screens()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        screens.loadData {
            self.tableView.reloadData()
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
            destination.screen = screens.screenArray[selectedIndexPath.row]
        } else {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ScreenLayoutTableViewController
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                destination.screen = screens.screenArray[selectedIndexPath.row]
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    func saveThenSegue(screenName: String){
        let newScreen = Screen(screenName: screenName)
        newScreen.saveData {success in
            if success {
                // I need to search screens.screenArray for newScreen.documentID
                // then send the element at that index over to the destination somehow
                let indexValue = self.screens.screenArray.firstIndex(where: { $0.documentID == newScreen.documentID })
                let newIndexPath = IndexPath(row: indexValue!, section: 0)
                self.tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .none)
                self.performSegue(withIdentifier: "AddScreen", sender: nil)
            } else {
                print("😡 ERROR: Scren named \(screenName) did not save.")
            }}
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
    
    @IBAction func addScreenPressed(_ sender: UIBarButtonItem) {
        showInputDialog(title: nil, subtitle: "Enter a name for this screen.", actionTitle: "Save", cancelTitle: "Cancel", inputPlaceholder: nil, inputKeyboardType: .default, cancelHandler: nil, actionHandler: {(input:String?) in
            guard let screenName = input else {
                return
            }
            self.saveThenSegue(screenName: screenName)
        })
    }
}

extension ScreenListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screens.screenArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = screens.screenArray[indexPath.row].screenName
        return cell
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

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
