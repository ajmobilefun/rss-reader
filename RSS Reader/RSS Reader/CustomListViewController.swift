//
//  CustomListViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/16/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

/**
    A delegate protocol that interfaces a selection chosen inside the SelectionListViewController.
*/
protocol CustomListDelegate {

    func didSelectItem(item: String?, forListID id: String)
}


/**
    A view controller that allows a user to create a new item or
    create an item based on previously used items.
*/
class CustomListViewController: UITableViewController {

    // MARK: Fields
    
    let listID: String
    let list: [String]
    var filteredList: [String]
    var listDelegate: CustomListDelegate?
    var selection: String?  
    var textFieldButtonCell = TextFieldButtonTableViewCell()
    
    // MARK: Initializers
    
    init(items: [String], selection: String?, listID: String, title: String?, listDelegate: CustomListDelegate?) {
        list = items
        filteredList = list
        self.selection = selection
        self.listID = listID
        self.listDelegate = listDelegate
        super.init(style: .Grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used")
    }
    
    
    // MARK: Helper Methods
    
    // Loads the filteredList parameter based of the textFieldButtonCell text string. Calling this method does not reaload the table view.
    private func loadFilteredList() {
        //If the searchbar is empty display all items
        guard let searchText = textFieldButtonCell.textField.text where searchText != "" else {
            filteredList = list
            return
        }
        //Filter the list since there is search text
        filteredList = list.filter({
            return $0.lowercaseString.containsString(searchText.lowercaseString)
        })
    }
    
    private func refreshAddButton() {
        let text = textFieldButtonCell.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? ""
        textFieldButtonCell.addButton.enabled = text != ""
    }
    
    func setupTextFieldButtonCell() {
        textFieldButtonCell.addButton.addTarget(self, action: #selector(addButtonTapped(_:)), forControlEvents: .TouchUpInside)
        textFieldButtonCell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        textFieldButtonCell.textField.placeholder = "Tap to add a new field"
        textFieldButtonCell.textField.delegate = self
        
        // Preset the text field if the selection is not in the list
        if let selection = selection where !list.contains(selection) {
            textFieldButtonCell.textField.text = selection
        }
        
        refreshAddButton()
    }
    
    
    // MARK: UIViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldButtonCell()
    }
    
    override func viewWillDisappear(animated: Bool) {
        textFieldButtonCell.textField.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: Selectors

    func textFieldDidChange(sender: UITextField!) {
        loadFilteredList()
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        refreshAddButton()
    }
    
    func addButtonTapped(sender: UIButton?) {
        selection = textFieldButtonCell.textField.text
        listDelegate?.didSelectItem(selection, forListID: listID)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: UITableView DataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // TextFieldButtonCell and list
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 { return textFieldButtonCell }
        else {
            let reuseID = "list_cell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) ?? UITableViewCell(style: .Value1, reuseIdentifier: reuseID)
            let item = filteredList[indexPath.row]
            cell.textLabel?.attributedText = TextUtils.boldSearchResult(textFieldButtonCell.textField.text, resultString: item, size: cell.textLabel?.font.pointSize)
            cell.selectionStyle = .Gray
            cell.accessoryView = nil
            cell.accessoryType = selection == item ? .Checkmark : .None
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : filteredList.count
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Assert a list cell was touched
        guard indexPath.section == 1 else { return }
        let item = filteredList[indexPath.row]
        
        // Set the selection or deselect
        selection = selection == item ? nil : item
        
        // Update the cell
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        // Call the delegate method and pop the controller
        listDelegate?.didSelectItem(selection, forListID: listID)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        textFieldButtonCell.textField.resignFirstResponder()
    }
}


// MARK: TextField Delegate
extension CustomListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addButtonTapped(nil)
        return true
    }
}