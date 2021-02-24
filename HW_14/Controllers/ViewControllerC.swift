
import UIKit
import CoreData

class ViewControllerC: UIViewController {
    
    var tasks = [Task]()
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        loadTasks()
    }
    
    func saveTasks(){ // сохранение
        do{
            try context.save()
        }catch {
            print("Error saving category with \(error)")
        }
        tableView.reloadData()
    }
    
    
    func loadTasks(){ // загрузка данных
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Новое задание", message: "", preferredStyle: .alert)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Введите новое задание здесь..."
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        let action = UIAlertAction(title: "Сохранить", style: .default) { (action) in 
            let newTask = Task(context: self.context)
            newTask.name = textField.text!
            newTask.done = false
            self.tasks.append(newTask)
            self.saveTasks()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewControllerC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.accessoryType = task.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tasks[indexPath.row].done = !tasks[indexPath.row].done
        saveTasks()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            let task = tasks[indexPath.row]
            tasks.remove(at: indexPath.row)
            context.delete(task)
            do {
                try context.save()
            } catch {
                print("Error deleting category with \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}




