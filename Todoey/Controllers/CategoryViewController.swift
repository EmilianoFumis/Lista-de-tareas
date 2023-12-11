

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewControllerTableViewController: SwipeTableViewController{ //hereda de SwipeTableViewController
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none

    }
    
    //MARK: -TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    //celdas por fila
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{ //Si categories no se encuenta nulo entonces...
            
            cell.textLabel?.text = category.name
            
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            
            cell.backgroundColor = categoryColour
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
       // cell.delegate = self
        
       // if item.done == true {
       //     cell.accessoryType = .checkmark
       // }else{
       //     cell.accessoryType = .none
       // }
        
        return cell
    }
    
    //MARK: -TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
    
    
    if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categories?[indexPath.row] //Se envía categoría seleccionada no nula
    }
    }
    
    //MARK: -Data Manipulation Methods
    
    //Save Data
    func save(category: Category){
        
        //let encoder = PropertyListEncoder()
        
        do{
            //let data = try encoder.encode(itemArray)
            //try data.write(to: self.dataFilePath!)
            try realm.write{
                realm.add(category)
            }
            
        }catch{
            print("Error saving context \(error)")
        }
        
        //self.defaults.set(self.itemArray, forKey: "TodoListArray")
        
        self.tableView.reloadData()
    }
    
    
    //Reading Data from Core Data
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        //función retorna Array de Category
        //parámetro externo
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        //Item.fetchRequest() valor predeterminado de invocación
        
        /*
        do{
            categories = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        
        */
        tableView.reloadData()
    }
    
    //MARK: - Delete Data Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                self.realm.delete(categoryForDeletion)
        
                }
                }catch{
                print("Error erasing, \(error)")
                      }
        
                }
    }
    
    
    //MARK: -Add new categories
    

    @IBAction func addButtonPresed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Añade nueva categoría", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Añadir categoría", style: .default) { (action) in
            //lo que sucede cuando el usuario realiza click en el botón de añadir

            //Create
            let newCategory = Category()
            newCategory.name = textfield.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            //self.categories.append(newCategory)
            
            self.save(category: newCategory)
                    
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Crear nueva categoría"
            textfield = (alertTextField)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    

    
}

