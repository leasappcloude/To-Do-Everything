//
//  CategoryViewController.swift
//  To Do Everything
//
//  Created by Lea Gnatzig on 12.07.18.
//  Copyright © 2018 Lea Gnatzig. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
    }

    //MARK - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // if categories != 0 -> zählen, if categories == 0 _> auf 1 setzen
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Addes yet"
        
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
    
    
    //MARK: - Add New Categories
  
    
    @IBAction func categoryAddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new ToDo-Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (alert) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
            }
        
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
            }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        tableView.reloadData()
    }
    

}
