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
    @IBOutlet weak var screenView: UIView!
    
    @IBOutlet var textBlockViews: [UITextView]! = []
    
    var textViewArray: [UITextView] = []
    let reduceBlockSpaceBy: CGFloat = 5
    
    var screen: Screen!
    var textBlocks: TextBlocks!
    let textBoxWidth: CGFloat = 270
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        hideDoneButtonIfNeeded()
        textBlocks = TextBlocks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textBlocks.loadData(screen: screen) {
            self.textBlocks.textBlocksArray.sort(by: { $0.orderPosition < $1.orderPosition })
            self.tableView.reloadData()
            self.configureScreen()
        }
    }
    
    func setUpTextBlock(textBlock: TextBlock, topOfViewFrame: CGFloat) -> CGFloat {
        let textBlockHeight = getTextBlockHeight(textBlock: textBlock)
        let viewFrame = CGRect(x: 0, y: topOfViewFrame, width: textBoxWidth, height: textBlockHeight)
        var newTextView = UITextView(frame: viewFrame)
        newTextView.center = CGPoint(x: screenView.frame.width/2, y: topOfViewFrame + (textBlockHeight/2))
        let viewFont = UIFont(name: "AvenirNextCondensed-Medium", size: textBlock.blockFontSize)
        newTextView.font = viewFont
        newTextView.text = textBlock.blockText
        newTextView = configureTextBlockView(textBoxView: newTextView, textBlock: textBlock)
        newTextView.backgroundColor = UIColor.clear
        
        let properHeight = newTextView.contentSize.height
        let newFrame = CGRect(x: 0, y: topOfViewFrame, width: textBoxWidth, height: properHeight)
        textBlockViews.append(newTextView)
        screenView.addSubview(newTextView)
        return topOfViewFrame + textBlockHeight - reduceBlockSpaceBy
    }
    
    func configureScreen() {
        // textViewArray = []
        textBlockViews = []
        for subview in screenView.subviews {
            if subview is UITextView {
                subview.removeFromSuperview()
            }
        }
        var topOfViewFrame: CGFloat = 0
        
        for textBlock in textBlocks.textBlocksArray {
            topOfViewFrame = setUpTextBlock(textBlock: textBlock, topOfViewFrame: topOfViewFrame)
        }
        // screenView.setNeedsDisplay()
    }
    
    func configureTextBlockView(textBoxView: UITextView, textBlock: TextBlock) -> UITextView {
        // textBoxView.font = textBoxView.font!.withSize(textBlock.blockFontSize)
        
        textBoxView.font = UIFont(name: "AvenirNextCondensed-Medium", size: textBlock.blockFontSize)
        //        newTextView.font = viewFont
        
        textBoxView.textColor = UIColor().colorWithHexString(hexString: textBlock.blockFontColor)
        let textBlockHeight = getTextBlockHeight(textBlock: textBlock)
        let rect = textBoxView.frame
        textBoxView.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: textBlockHeight)
        textBoxView.textAlignment = setAlignment(alignmentValue: textBlock.alignment)
        textBoxView.text = textBlock.blockText
        return textBoxView
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
            destination.textBlocks = textBlocks
            let selectedIndex = tableView.indexPathForSelectedRow!
            destination.textBlock = textBlocks.textBlocksArray[selectedIndex.row]
        } else {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! TextBoxDetailTableViewController
            destination.screen = screen
            destination.textBlocks = textBlocks
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
        print("Stop Here")
    }
    
    @IBAction func addBlockTextPressed(_ sender: UIBarButtonItem) {
    }
}


extension ScreenLayoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textBlocks.textBlocksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = textBlocks.textBlocksArray[indexPath.row].blockText
        return cell
    }
}
