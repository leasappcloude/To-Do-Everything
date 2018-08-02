//
//  CategoryViewController.swift
//  To Do Everything
//
//  Created by Lea Gnatzig on 12.07.18.
//  Copyright © 2018 Lea Gnatzig. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        tableView.separatorStyle = .none
    }

    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // if categories != 0 -> zählen, if categories == 0 _> auf 1 setzen
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name
            
//            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
//
//            cell.backgroundColor = categoryColour
//            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
       }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category : Category) {
        
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving Items, \(error)")
        }

        tableView.reloadData()
    }
    
    func loadCategory(){
    
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let categoryForDeleting = self.categories?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDeleting)
                }
            } catch {
                print("Error delete caegory, \(error)")
            }
            //self.tableView.reloadData()
        }

    }
    
    //MARK: - Add New Categories
  
    
    @IBAction func categoryAddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alert) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
            }
        
        alert.addAction(action)
  
        
        alert.addTextField {(field) in
            textField = field
            textField.placeholder = "Create new Category"
            }

        present(alert, animated: true, completion: nil)
        //tableView.reloadData()
    }
    

}


