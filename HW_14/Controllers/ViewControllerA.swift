
import UIKit

class ViewControllerA: UIViewController {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var surnameLabel: UITextField!
    
    @IBAction func saveButton(_ sender: Any) {
        
        Visitor.shared.userName = nameLabel.text!
        Visitor.shared.userSurname = surnameLabel.text!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = Visitor.shared.userName
        surnameLabel.text = Visitor.shared.userSurname
    }
    
    class Visitor{ // посетители
        
        static let shared = Visitor()
        
        private let kUserNameKey = "Visitor.kUserNameKey"
        private let kUserSurnameKey = "Visitor.kUserSurnameKey"
        
        var userName: String{
            set { UserDefaults.standard.set(newValue, forKey: kUserNameKey) }
            get { return UserDefaults.standard.string(forKey: kUserNameKey) ?? "" }
        }
        
        var userSurname: String{
            set { UserDefaults.standard.set(newValue, forKey: kUserSurnameKey) }
            get { return UserDefaults.standard.string(forKey: kUserSurnameKey) ?? "" }
        }
    }
}
