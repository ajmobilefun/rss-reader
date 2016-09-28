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

    func didSelectItem(_ item: String?, forListID id: String)
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
        super.init(style: .grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used")
    }
    
    
    // MARK: Helper Methods
    
    // Loads the filteredList parameter based of the textFieldButtonCell text string. Calling this method does not reaload the table view.
    fileprivate func loadFilteredList() {
        //If the searchbar is empty display all items
        guard let searchText = textFieldButtonCell.textField.text , searchText != "" else {
            filteredList = list
            return
        }
        //Filter the list since there is search text
        filteredList = list.filter({
            return $0.lowercased().contains(searchText.lowercased())
        })
    }
    
    fileprivate func refreshAddButton() {
        let text = textFieldButtonCell.textField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        textFieldButtonCell.addButton.isEnabled = text != ""
    }
    
    func setupTextFieldButtonCell() {
        textFieldButtonCell.addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        textFieldButtonCell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textFieldButtonCell.textField.placeholder = "Tap to add a new field"
        textFieldButtonCell.textField.delegate = self
        
        // Preset the text field if the selection is not in the list
        if let selection = selection , !list.contains(selection) {
            textFieldButtonCell.textField.text = selection
        }
        
        refreshAddButton()
    }
    
    
    // MARK: UIViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldButtonCell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textFieldButtonCell.textField.resignFirstResponder()
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: Selectors

    func textFieldDidChange(_ sender: UITextField!) {
        loadFilteredList()
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        refreshAddButton()
    }
    
    func addButtonTapped(_ sender: UIButton?) {
        selection = textFieldButtonCell.textField.text
        listDelegate?.didSelectItem(selection, forListID: listID)
        _ = navigationController?.popViewController(animated: true) // TODO - Prompt error
    }
    
    
    // MARK: UITableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // TextFieldButtonCell and list
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 { return textFieldButtonCell }
        else {
            let reuseID = "list_cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseID) ?? UITableViewCell(style: .value1, reuseIdentifier: reuseID)
            let item = filteredList[(indexPath as NSIndexPath).row]
            cell.textLabel?.attributedText = TextUtils.boldSearchResult(textFieldButtonCell.textField.text, resultString: item, size: cell.textLabel?.font.pointSize)
            cell.selectionStyle = .gray
            cell.accessoryView = nil
            cell.accessoryType = selection == item ? .checkmark : .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : filteredList.count
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Assert a list cell was touched
        guard (indexPath as NSIndexPath).section == 1 else { return }
        let item = filteredList[(indexPath as NSIndexPath).row]
        
        // Set the selection or deselect
        selection = selection == item ? nil : item
        
        // Update the cell
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        // Call the delegate method and pop the controller
        listDelegate?.didSelectItem(selection, forListID: listID)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textFieldButtonCell.textField.resignFirstResponder()
    }
}


// MARK: TextField Delegate
extension CustomListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addButtonTapped(nil)
        return true
    }
}
