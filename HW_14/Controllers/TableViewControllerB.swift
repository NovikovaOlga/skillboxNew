
import UIKit
import RealmSwift

class TableViewControllerB: UITableViewController {
    
    var realm: Realm!
    
    @IBAction func addNotes(_ sender: Any) { // модальное окно для ввода задачи
        
        let alert = UIAlertController(title: "Появилась новое задание?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addTextField { textField in
            textField.placeholder = "Введите задание здесь..."
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action  in
            
            let textFieldNotes = (alert.textFields?.first)! as UITextField
            let notesItem = Notes()
            notesItem.name = textFieldNotes.text!
            
            // добавим запись в базу данных
            try! self.realm.write({
                self.realm.add(notesItem)
                self.tableView.insertRows(at: [IndexPath.init(row: self.notebookList.count-1, section: 0)], with: .automatic)
            })
            print("Добавлена новая запись в базу")
        } ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var notebookList: Results<Notes> {     // вызовем записи
        get {
            return try! Realm().objects(Notes.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm() // загрузим базу
        print("База загружена")
    }
    
    override func didReceiveMemoryWarning() { // можно без этого
        super.didReceiveMemoryWarning()
        // Из документации разработчика: Ваше приложение никогда не вызывает этот метод напрямую. Вместо этого этот метод вызывается, когда система определяет, что объем доступной памяти невелик.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebookList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = notebookList[indexPath.row]
        cell.textLabel!.text = item.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { // удаление записи
        
        if (editingStyle == .delete){
            let item = notebookList[indexPath.row]
            try! self.realm.write({
                self.realm.delete(item)
            })
            
            tableView.deleteRows(at:[indexPath], with: .automatic)
            print("Запись удалена из базы")
        }
    }
}

