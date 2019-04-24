//
//  ScreenLayoutTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/19/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class ScreenLayoutTableViewController: UITableViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var screenView: UIView!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var fontAlignmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textBoxView: UITextView!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var moveUpButton: UIButton!
    @IBOutlet weak var moveDownButton: UIButton!
    
    @IBOutlet var textBlockViews: [UITextView]! = []
    
    var selectedTextBlock: TextBlock!
    var textViewArray: [UITextView] = []
    let reduceBlockSpaceBy: CGFloat = 10
    
    // var screen: Screen!
    var element: Element!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBoxView.delegate = self
        textBoxView.becomeFirstResponder()
        
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Reloads table view so cells resize properly once data & UITextViews are configured.
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func configureUserInterface() {
        // Clear out old UITextView subviews. setting array to empty isn't enough to get rid of residual data structures
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
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
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
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
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
