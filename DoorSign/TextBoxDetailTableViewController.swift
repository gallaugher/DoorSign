//
//  TextBoxDetailTableViewController.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/18/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import UIKit

class TextBoxDetailTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var screenView: UIView!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var fontAlignmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textBoxView: UITextView!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var lineSizeLabel: UILabel!
    
    @IBOutlet var textBlockViews: [UITextView]! = []
    
    var screen: Screen!
    var textBlock: TextBlock!
    var textBlockIndex: Int!
    let screenCellIndexPath = IndexPath(row: 0, section: 0)
    let linesAndColorCellIndexPath = IndexPath(row: 0, section: 1)
    let sizeSegmentCellIndexPath = IndexPath(row: 0, section: 2)
    let textBoxViewCellIndexPath = IndexPath(row: 0, section:
        3)
    let alignmentSegmentCellIndexPath = IndexPath(row: 0, section: 4)
    
    let screenCellHeight: CGFloat = 240
    let linesAndColorCellHeight: CGFloat = 36
    let sizeSegmentCellHeight: CGFloat = 35
    let alignmentSegmentCellHeight: CGFloat = 33
    let textBoxWidth: CGFloat = 270
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBoxView.delegate = self
        
        // hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if textBlock == nil {
            textBlock = TextBlock()
            textBlock.blockText = textBoxView.text
            screen.textBlockArray.append(textBlock)
            textBlockIndex = screen.textBlockArray.count-1
        }
        
        configureUserInterface()
    }
    
    func setUpTextBlock(index: Int, topOfViewFrame: CGFloat) -> CGFloat {
        let textBlock = screen.textBlockArray[index]
        let textBlockHeight = CGFloat(textBlock.numberOfLines) * textBlock.blockFontSize
        let viewFrame = CGRect(x: 0, y: topOfViewFrame, width: textBoxWidth, height: textBlockHeight)
        var newTextView = UITextView(frame: viewFrame)
        newTextView.center = CGPoint(x: screenView.frame.width/2, y: topOfViewFrame + (textBlockHeight/2))
        let viewFont = UIFont(name: "AvenirNextCondensed-Medium", size: textBlock.blockFontSize)
        newTextView.font = viewFont
        newTextView.text = screen.textBlockArray[index].blockText
        newTextView = configureTextBlockView(textBoxView: newTextView, textBlock: textBlock)
        textBlockViews.append(newTextView)
        screenView.addSubview(newTextView) // unsure if this is needed
        
        return topOfViewFrame + textBlockHeight
    }
    
    func configureFontSizeControl() {
        switch textBlock.blockFontSize {
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
    
    func configureUserInterface() {
        textBlockViews = []
        screenView.backgroundColor = UIColor.white
        screenView.setNeedsDisplay()
        
        var topOfViewFrame: CGFloat = 0
        for index in 0..<screen.textBlockArray.count {
            topOfViewFrame = setUpTextBlock(index: index, topOfViewFrame: topOfViewFrame)
        }
        
        lineSizeLabel.text = "\(textBlock.numberOfLines) line\(textBlock.numberOfLines>1 ? "s" : "")"
        fontAlignmentSegmentedControl.selectedSegmentIndex = textBlock.alignment
        configureFontSizeControl()
        textBoxView = configureTextBlockView(textBoxView: textBoxView, textBlock: textBlock)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func getTextBlockHeight(textBlock: TextBlock) -> CGFloat {
        switch textBlock.blockFontSize {
        case Constants.largeFontSize:
            return CGFloat(textBlock.numberOfLines) * Constants.largeFontLineHeight
        case Constants.mediumFontSize:
            return CGFloat(textBlock.numberOfLines) * Constants.mediumFontLineHeight
        case Constants.smallFontSize:
            return CGFloat(textBlock.numberOfLines) * Constants.smallFontLineHeight
        default:
            print("😡 ERROR: This textBlock.blockFontSize = \(textBlock.blockFontSize) should not have occurred ")
            return CGFloat(textBlock.numberOfLines) * Constants.largeFontLineHeight
        }
    }
    
    func configureTextBlockView(textBoxView: UITextView, textBlock: TextBlock) -> UITextView {
        textBoxView.font = textBoxView.font!.withSize(textBlock.blockFontSize)
        textBlock.blockFontColor = colorTextField.text!
        textBoxView.textColor = UIColor().colorWithHexString(hexString: textBlock.blockFontColor)
        let textBlockHeight = getTextBlockHeight(textBlock: textBlock)
        let rect = textBoxView.frame
        textBoxView.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: textBlockHeight)
        textBoxView.textAlignment = setAlignment(alignmentValue: fontAlignmentSegmentedControl.selectedSegmentIndex)
        return textBoxView
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
            print("😡 ERROR: This fontAlignmentSegmentedControl = \(fontAlignmentSegmentedControl.selectedSegmentIndex) should not have occurred ")
            return NSTextAlignment.left
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        screen.textBlockArray[textBlockIndex].blockText = textView.text!
        configureUserInterface()
    }
    
    @IBAction func colorFieldEditingEnded(_ sender: UITextField) {
        textBlock.blockFontColor = colorTextField.text!
        configureUserInterface()
    }
    
    @IBAction func fontSizeSegmentPressed(_ sender: UISegmentedControl) {
        switch fontSizeSegmentedControl.selectedSegmentIndex {
        case 0:
            textBlock.blockFontSize = Constants.smallFontSize
        case 1:
            textBlock.blockFontSize = Constants.mediumFontSize
        case 2:
            textBlock.blockFontSize = Constants.largeFontSize
        default:
            print("😡 ERROR: This fontSizeSegmentedControl = \(fontSizeSegmentedControl.selectedSegmentIndex) should not have occurred ")
            textBlock.blockFontSize = Constants.largeFontSize
        }
        configureUserInterface()
    }
    
    @IBAction func changeLineSize(_ sender: UIButton) {
        if sender.tag == Constants.plusTag {
            textBlock.numberOfLines += 1
        } else if sender.tag == Constants.minusTag {
            textBlock.numberOfLines -= 1
        }
        if textBlock.numberOfLines == 0 {
            textBlock.numberOfLines = 1
        }
        configureUserInterface()
    }
    
    @IBAction func fontAlignmentSegmentPressed(_ sender: UISegmentedControl) {
        textBlock.alignment = fontAlignmentSegmentedControl.selectedSegmentIndex
        configureUserInterface()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension TextBoxDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (screenCellIndexPath.section, screenCellIndexPath.row):
            return screenCellHeight
        case (linesAndColorCellIndexPath.section, linesAndColorCellIndexPath.row):
            return linesAndColorCellHeight
        case (sizeSegmentCellIndexPath.section, sizeSegmentCellIndexPath.row):
            return sizeSegmentCellHeight
        case (textBoxViewCellIndexPath.section,
              textBoxViewCellIndexPath.row):
            return textBoxView.frame.height
        case (alignmentSegmentCellIndexPath.section, alignmentSegmentCellIndexPath.row):
            return alignmentSegmentCellHeight
        default:
            return 44
        }
    }
}
