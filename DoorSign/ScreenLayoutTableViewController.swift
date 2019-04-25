//
//  ScreenLayoutTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/19/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ScreenLayoutTableViewController: UITableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    enum BackgroundImageStatus {
        case unchanged
        case save
        case delete
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var screenView: UIView!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var fontAlignmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textBoxView: UITextView!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var moveUpButton: UIButton!
    @IBOutlet weak var moveDownButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet var textBlockViews: [UITextView]! = []
    @IBOutlet var actionButtons: [UIButton]! = []
    
    var selectedTextBlock: TextBlock!
    var textViewArray: [UITextView] = []
    let reduceBlockSpaceBy: CGFloat = 10
    
    // var screen: Screen!
    var element: Element!
    var elements: Elements!
    var textBlocks = TextBlocks()
    var indexOfSelectedBlock = 0
    let textBoxWidth: CGFloat = 270
    
    let screenCellIndexPath = IndexPath(row: 0, section: 0)
    let alignmentAndColorCellIndexPath = IndexPath(row: 0, section: 1)
    let sizeSegmentCellIndexPath = IndexPath(row: 0, section: 2)
    let textBoxViewCellIndexPath = IndexPath(row: 0, section:
        3)
    let moveDeleteAddCellIndexPath = IndexPath(row: 0, section: 4)
    
    let screenCellHeight: CGFloat = 240
    let alignmentAndColorCellHeight: CGFloat = 36
    let sizeSegmentCellHeight: CGFloat = 35
    let moveDeleteAddSegmentCellHeight: CGFloat = 33
    
    var imagePicker = UIImagePickerController()
    var backgroundImageStatus: BackgroundImageStatus = .unchanged
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage()
        imagePicker.delegate = self
        textBoxView.delegate = self
        textBoxView.becomeFirstResponder()
        
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        createButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If we don't have any textBlocks, then create a new, blank one & add it to the textBlocks array.
        
        // get all the text blocks that make up the selected screen
        textBlocks.loadData(element: element) {
            
            if self.textBlocks.textBlocksArray.count == 0 {
                let textBlock = TextBlock()
                self.textBlocks.textBlocksArray.append(textBlock)
            } else {
                self.textBlocks.textBlocksArray.sort(by: { $0.orderPosition < $1.orderPosition })
                self.indexOfSelectedBlock = self.textBlocks.textBlocksArray.count-1 // select the last block to edit
            }
            self.selectedTextBlock = self.textBlocks.textBlocksArray[self.indexOfSelectedBlock]
            self.configureUserInterface()
        }
        element.loadBackgroundImage {
            self.backgroundImageView.image = self.element.backgroundImage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reloads table view so cells resize properly once data & UITextViews are configured.
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func createButton(buttonName: String) -> UIButton {
        let paddingAroundText: CGFloat = 8.0
        let newButton = UIButton(frame: self.screenView.frame)
        newButton.setTitle(buttonName, for: .normal)
        newButton.titleLabel?.font = .boldSystemFont(ofSize: 13.0)
        newButton.sizeToFit()
        newButton.frame = CGRect(x: newButton.frame.origin.x, y: newButton.frame.origin.y, width: newButton.frame.width + (paddingAroundText*2), height: newButton.frame.height)
        newButton.backgroundColor=UIColor().colorWithHexString(hexString: "923125")
        newButton.addTarget(self, action: #selector(changeButtonTitle), for: .touchUpInside)
        return newButton
    }
    
    @objc func changeButtonTitle(_ sender: UIButton) {
        showInputDialog(title: nil,
                        message: "Change the label on the '\(sender.titleLabel?.text ?? "")' button:",
            actionTitle: "Change",
            cancelTitle: "Cancel",
            inputPlaceholder: nil,
            inputKeyboardType: .default,
            actionHandler: {(input:String?) in
                guard let buttonTitle = input else {
                    return
                }
                sender.setTitle(buttonTitle, for: .normal)
                self.saveButtonTitle(sender: sender)
        },
            cancelHandler: nil)
        
    }
    
    func saveButtonTitle(sender: UIButton) {
        
        guard let clickedButtonIndex = actionButtons.firstIndex(where: {$0 == sender}) else {
            print("😡 couldn't get clickedButtonIndex")
            return
        }
        
        let clickedButtonID = element.childrenIDs[clickedButtonIndex]
        let clickedButtonElement = elements.elementArray.first(where: {$0.documentID == clickedButtonID})
        clickedButtonElement?.elementName = sender.titleLabel?.text ?? "<ERROR CHANGING BUTTON TITLE>"
        
        clickedButtonElement?.saveData() {success in
            if !success { // if not successful
                print("😡 ERROR: couldn't save change to clicked button at documentID = \(clickedButtonElement!.documentID)")
            } else {
                print("-> Yeah, properly updated button title!")
            }
        }
    }
    
    func createButtons() {
        // no buttons to create if there aren't any children
        guard element.childrenIDs.count > 0 else {
            return
        }
        
        var buttonNames = [String]() // clear out button names
        for childID in element.childrenIDs { // loop through all childIDs
            if let buttonElement = elements.elementArray.first(where: {$0.documentID == childID}) { // if you can find an element with that childID
                buttonNames.append(buttonElement.elementName) // add it's name to buttonNames
            }
        }
        
        // create a button (in actionButtons) for each buttonName
        for buttonName in buttonNames {
            actionButtons.append(createButton(buttonName: buttonName))
        }
        
        // position action buttons
        // 12 & 12 from lower right-hand corner
        let indent: CGFloat = 12.0
        // start in lower-left of screenView
        var buttonX: CGFloat = 0.0
        // var buttonX = screenView.frame.origin.x
        let buttonY = screenView.frame.height-indent-actionButtons[0].frame.height
        
        for button in actionButtons {
            var buttonFrame = button.frame
            buttonX = buttonX + indent
            buttonFrame = CGRect(x: buttonX, y: buttonY, width: buttonFrame.width, height: buttonFrame.height)
            button.frame = buttonFrame
            screenView.addSubview(button)
            buttonX = buttonX + button.frame.width // move start portion of next button rect to the end of the current button rect
        }
        if element.elementType == "Home" {
            var widthOfAllButtons = actionButtons.reduce(0.0,{$0 + $1.frame.width})
            widthOfAllButtons = widthOfAllButtons + (CGFloat(actionButtons.count-1)*indent)
            var shiftedX = (screenView.frame.width-widthOfAllButtons)/2
            
            for button in actionButtons {
                button.frame.origin.x = shiftedX
                shiftedX = shiftedX + button.frame.width + indent
            }
        }
    }
    
    func configurePrevNextBackButtons() {
        // Hide the back button if you're looking at the "Home" screen (because there's no way to go back if you're at home, the root of the tree hierarchy.
        if element.elementType == "Home" {
            backButton.isHidden = element.elementType == "Home"
            previousButton.isHidden = true
            nextButton.isHidden = true
        }
        
        // Clear out old UITextView subviews. setting array to empty isn't enough to get rid of residual data structures
        let parentID = element.parentID
        let foundParent = elements.elementArray.first(where: {$0.documentID == parentID})
        guard let parent = foundParent else { // unwrap found parent
            if element.elementType != "Home" {
                print("😡 ERROR: could not get the element's parent")
            }
            return
        }
        if parent.childrenIDs.count > 1 {
            previousButton.isHidden = false
            nextButton.isHidden = false
        } else {
            previousButton.isHidden = true
            nextButton.isHidden = true
        }
    }
    
    func configureUserInterface() {
        backgroundImageView.image = element.backgroundImage
        configurePrevNextBackButtons()
        for subview in screenView.subviews {
            if subview is UITextView {
                subview.removeFromSuperview()
            }
        }
        textBlockViews = []
        // configure screenView and textBoxView
        self.configureScreenView()
        self.textBoxView = self.configureTextView(newTextView: self.textBoxView, textBlock: self.textBlocks.textBlocksArray[self.indexOfSelectedBlock], topOfViewFrame: self.textBoxView.frame.origin.y)
        
        fontAlignmentSegmentedControl.selectedSegmentIndex = selectedTextBlock.alignment
        configureFontSizeControl()
        configureMoveArrows()
    }
    
    func configureMoveArrows() {
        moveUpButton.isEnabled = indexOfSelectedBlock == 0 ? false : true
        moveDownButton.isEnabled = indexOfSelectedBlock == textBlockViews.count-1 ? false : true
    }
    
    func configureScreenView() {
        var topOfViewFrame: CGFloat = 0
        // Go through all textblocks read in from Firestore
        for index in 0..<textBlocks.textBlocksArray.count {
            let textBlock = textBlocks.textBlocksArray[index]
            textBlock.orderPosition = index
            // actual coordinates of initial frame don't matter. We'll resize after fonts are configured.
            let viewFrame = CGRect(x: 0, y: topOfViewFrame, width: textBoxWidth, height: topOfViewFrame+1)
            // Create the view - we'll resize it later.
            var newTextView = UITextView(frame: viewFrame)
            
            // Create a UITextView for it, size it according to parameters, and add it to the view.
            newTextView = configureTextView(newTextView: newTextView, textBlock: textBlock, topOfViewFrame: topOfViewFrame)
            // Give the newTextView a centerpoint relative to its superview (screen)
            newTextView.center = CGPoint(x: screenView.frame.width/2, y: topOfViewFrame + (newTextView.frame.height/2))
            // Make it so the UITextViews in the screen cannot be edited
            newTextView.isEditable = false
            
            let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
            viewTapGesture.delegate = self
            newTextView.addGestureRecognizer(viewTapGesture)
            
            textBlockViews.append(newTextView)
            screenView.addSubview(newTextView)
            topOfViewFrame = newTextView.frame.origin.y + newTextView.frame.height - reduceBlockSpaceBy
        }
    }
    
    @objc func viewTapped(sender: UITapGestureRecognizer?) {
        var indexOfTappedView = 0
        
        for index in 0..<textBlockViews.count {
            if sender?.view == textBlockViews[index] {
                indexOfTappedView = index
            }
        }
        print("****** TAPPED !!! \(indexOfTappedView) *****")
        indexOfSelectedBlock = indexOfTappedView
        selectedTextBlock = textBlocks.textBlocksArray[indexOfSelectedBlock]
        configureUserInterface()
        colorTextField.text = selectedTextBlock.blockFontColor
    }
    
    func configureTextView(newTextView: UITextView, textBlock: TextBlock, topOfViewFrame: CGFloat) -> UITextView {
        // Set the UITextView's font
        let viewFont = UIFont(name: "AvenirNextCondensed-Medium", size: textBlock.blockFontSize)
        newTextView.font = viewFont
        newTextView.text = textBlock.blockText
        // With font & text set, get the height to show all of the text in a single textView
        let textViewHeight = newTextView.contentSize.height
        // Resize using the properHeight
        newTextView.frame = CGRect(x: 0, y: topOfViewFrame, width: textBoxWidth, height: textViewHeight)
        newTextView.backgroundColor = UIColor.clear
        
        // Configure newTextView based on textBlock data
        newTextView.textColor = UIColor().colorWithHexString(hexString: textBlock.blockFontColor)
        colorTextField.text = textBlock.blockFontColor
        newTextView.textAlignment = setAlignment(alignmentValue: textBlock.alignment)
        return newTextView
    }
    
    func setAlignment(alignmentValue: Int) -> NSTextAlignment {
        switch alignmentValue {
        case 0:
            return NSTextAlignment.left
        case 1:
            return NSTextAlignment.center
        case 2:
            return NSTextAlignment.right
        default:
            print("😡 ERROR: This fontAlignmentSegmentedControl = \(alignmentValue) should not have occurred ")
            return NSTextAlignment.left
        }
    }
    
    func configureFontSizeControl() {
        switch selectedTextBlock.blockFontSize {
        case Constants.smallFontSize:
            fontSizeSegmentedControl.selectedSegmentIndex = 0
        case Constants.mediumFontSize:
            fontSizeSegmentedControl.selectedSegmentIndex = 1
        case Constants.largeFontSize:
            fontSizeSegmentedControl.selectedSegmentIndex = 2
        default:
            print("😡 ERROR: This fontSizeSegmentedControl = \(fontSizeSegmentedControl.selectedSegmentIndex) should not have occurred ")
        }
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        if backgroundImageView.image!.size.width > 0 { // if there is an image to remove
            let deleteAction = UIAlertAction(title: "Delete Background", style: .destructive) { _ in
                self.backgroundImageView.image = UIImage()
                self.backgroundImageStatus = .delete
            }
            alertController.addAction(deleteAction)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func colorFieldEditingEnded(_ sender: UITextField) {
        selectedTextBlock.blockFontColor = colorTextField.text!
        configureUserInterface()
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        selectedTextBlock.blockText = textView.text!
        textBoxView = configureTextView(newTextView: textBoxView, textBlock: textBlocks.textBlocksArray[indexOfSelectedBlock], topOfViewFrame: 0)
        configureUserInterface()
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func fontSizeSegmentPressed(_ sender: UISegmentedControl) {
        switch fontSizeSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedTextBlock.blockFontSize = Constants.smallFontSize
        case 1:
            selectedTextBlock.blockFontSize = Constants.mediumFontSize
        case 2:
            selectedTextBlock.blockFontSize = Constants.largeFontSize
        default:
            print("😡 ERROR: This fontSizeSegmentedControl = \(fontSizeSegmentedControl.selectedSegmentIndex) should not have occurred ")
            selectedTextBlock.blockFontSize = Constants.largeFontSize
        }
        configureUserInterface()
    }
    
    @IBAction func fontAlignmentSegmentPressed(_ sender: UISegmentedControl) {
        selectedTextBlock.alignment = fontAlignmentSegmentedControl.selectedSegmentIndex
        configureUserInterface()
    }
    
    @IBAction func moveUpPressed(_ sender: Any) {
        if indexOfSelectedBlock > 0 {
            let itemToMove = textBlocks.textBlocksArray[indexOfSelectedBlock]
            textBlocks.textBlocksArray.remove(at: indexOfSelectedBlock)
            textBlocks.textBlocksArray.insert(itemToMove, at: indexOfSelectedBlock-1)
            indexOfSelectedBlock -= 1
            for index in 0..<textBlocks.textBlocksArray.count {
                textBlocks.textBlocksArray[index].orderPosition = index
            }
        }
        configureUserInterface()
    }
    
    @IBAction func moveDownPressed(_ sender: Any) {
        if indexOfSelectedBlock < textBlocks.textBlocksArray.count {
            let itemToMove = textBlocks.textBlocksArray[indexOfSelectedBlock]
            textBlocks.textBlocksArray.remove(at: indexOfSelectedBlock)
            textBlocks.textBlocksArray.insert(itemToMove, at: indexOfSelectedBlock+1)
            indexOfSelectedBlock += 1
            for index in 0..<textBlocks.textBlocksArray.count {
                textBlocks.textBlocksArray[index].orderPosition = index
            }
        }
        configureUserInterface()
    }
    
    @IBAction func addBlockPressed(_ sender: UIButton) {
        let textBlock = TextBlock()
        textBlocks.textBlocksArray.append(textBlock)
        indexOfSelectedBlock = self.textBlocks.textBlocksArray.count-1 // select the last block to edit
        selectedTextBlock = textBlocks.textBlocksArray[indexOfSelectedBlock]
        configureUserInterface()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        
        textBlocks.saveData(element: element) { success in
            if success {
                self.leaveViewController()
                switch self.backgroundImageStatus {
                case .delete:
                // TODO: Something will go here, but for now, break
                    break // do nothing
                case .save:
                    self.element.backgroundImageUUID = UUID().uuidString
                    self.element.saveData { (success) in
                        if success {
                            self.element.saveImage { (success) in
                            }
                        } else {
                            print("😡 ERROR: Could not add backgroundImageUUID to elment \(self.element.elementName)")
                        }
                    }
                case .unchanged:
                    break // do nothing
                }
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    
    @IBAction func addImageButtonPressed(_ sender: UIBarButtonItem) {
        cameraOrLibraryAlert()
    }
}

extension ScreenLayoutTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (screenCellIndexPath.section, screenCellIndexPath.row):
            return screenCellHeight
        case (alignmentAndColorCellIndexPath.section, alignmentAndColorCellIndexPath.row):
            return alignmentAndColorCellHeight
        case (sizeSegmentCellIndexPath.section, sizeSegmentCellIndexPath.row):
            return sizeSegmentCellHeight
        case (textBoxViewCellIndexPath.section,
              textBoxViewCellIndexPath.row):
            return textBoxView.frame.height
        case (moveDeleteAddCellIndexPath.section, moveDeleteAddCellIndexPath.row):
            return moveDeleteAddSegmentCellHeight
        default:
            return 44
        }
    }
}

/*
 - I could add an image where one did not exist
 - create UUID and save image to firebase storage
 - if background UUID == "" and .save
 - delete an existing image, leaving no image
 - delete UUID (? set it to "") and delete image from firebase storage
 - if background UUID != "" and .delete
 - update an existing image
 - replace image on Firebase Storage at existing UUID with new image
 - if background UUID != "" and .save
 
 backgroundImageStatus
 .unchanged
 .save
 .delete
 */

extension ScreenLayoutTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // show the selected image in the app's backgroundImageView
        backgroundImageView.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        element.backgroundImage = backgroundImageView.image! // and store image in element
        backgroundImageStatus = .save
        dismiss(animated: true) {
            // TODO: image saving here
            //            photo.saveData(spot: self.spot) { (success) in
            //            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}
