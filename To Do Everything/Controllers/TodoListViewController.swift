//
//  ViewController.swift
//  To Do Everything
//
//  Created by Lea Gnatzig on 11.07.18.
//  Copyright © 2018 Lea Gnatzig. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet var columnTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let realm = try! Realm()
    
    var toDoItems : Results<Item>?

    var selectedCategory : Category? {
        didSet{
            print("load Items")
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
       
    }
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
    
        guard let colorHex = selectedCategory?.colour else{fatalError()}
        
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colourHexCode : String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colourHexCode) else{fatalError() }

        navBar.barTintColor = UIColor(hexString: colourHexCode)
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    
    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title

            if let color = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)

            }

            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    //Mark - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    //realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error sarving done Status, \(error)")
            }
        }

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Mark - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (alert) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch {
                    print (" Error beim Speichern, \(error)")
                }

            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manupilation Methods

    
    func loadItems() {
       print("loadItems")
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }

    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error updating superclass, \(error)")
            }
        }
    }

   
}

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}
