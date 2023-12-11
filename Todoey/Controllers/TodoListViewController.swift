

import UIKit
import RealmSwift
//import CoreData
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? //Categoría opcional, será nulo en principio
    {
        didSet{   //Cuando se cargue valor en categoría
            loadItems()
        }
    }
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

        
        /* let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Destroy Demogogo"
        itemArray.append(newItem3) */
        
    
         //if let items = defaults.array(forKey: "TodoListArray") as? [Item]{
        
         //itemArray = items
             
         //}
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
    }
    
    //número de celdas, retornará 3
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //celdas por fila
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell",
//        for: indexPath)
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let item = todoItems?[indexPath.row]  {//si no es nulo cantidad de items entonces selección de fila actual
            
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
             //si existe un color entonces
             //UIColor(hexString: selectedCategory!.colour)? si existe un color válido dentro de colour, no un simple String, sino con formato hexString para representar colores. Entonces se oscure con darken.
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
            
            // if item.done == true {
            //     cell.accessoryType = .checkmark
            // }else{
            //     cell.accessoryType = .none
            // }
        }else{
            
            cell.textLabel?.text = "No Items Added"
            
        }
        
        return cell
        
    }
    
    // TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    //realm.delete(item)
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        /*
         itemArray[indexPath.row].done = !itemArray[indexPath.row].done //se asigna valor contrario a la fila de la posición actual.
        */
        
        //if itemArray[indexPath.row].done == false {  //selección de fila actual
        //   itemArray[indexPath.row].done = true //se pasa verdadero a la variable done.
        //}else{
        //  itemArray[indexPath.row].done = false //si está seleccionada, al seleccionar de nuevo se pasa falso a la variable donne
        //}
        
        //saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Añade nuevo ítem", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Añadir ítem", style: .default) { (action) in
            //lo que sucede cuando el usuario realiza click en el botón de añadir

            //Create
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textfield.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new items")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Crear nuevo ítem"
            textfield = (alertTextField)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //Save Data
    /*func saveItems(){
        
        //let encoder = PropertyListEncoder()
        
        do{
            //let data = try encoder.encode(itemArray)
            //try data.write(to: self.dataFilePath!)
            try context.save()
            
        }catch{
            print("Error saving context \(error)")
        }
        
        //self.defaults.set(self.itemArray, forKey: "TodoListArray")
        
        self.tableView.reloadData()
    }*/
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
        //método decodificar datos
        
       /* if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
            itemArray = try decoder.decode([Item].self, from: data)
            } catch{
               print("Error decoding item array, \(error)")
            }
    } */
   }
    
    //Reading Data from Core Data
    /*
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){   //función retorna Array de Item
        //parámetro externo
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        //Item.fetchRequest() valor predeterminado de invocación
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate{
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
            
        }else{
            request.predicate = categoryPredicate
        }
        
        //Si existe búsqueda en barra y categoría, se realizan ambos request, sino sólo request de categoría
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    */
    
    //MARK: - Delete Data Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                self.realm.delete(itemForDeletion)
        
                }
                }catch{
                print("Error erasing item, \(error)")
                      }
        
                }
    }
    
}
//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //Quitar cursor de barra de búsqueda y ocultar teclado
            }
        }
    }
    
}

