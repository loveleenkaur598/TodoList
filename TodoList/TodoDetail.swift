//
//  TodoDetail.swift
//  TodoList
//
//  Created by MacUser on 2019-12-05.
//  Copyright © 2019 MacUser. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TodoDetail: UIViewController {
    
    var name = ""
    var isChecked = false
    var desc = ""

    @IBOutlet weak var todoName: UITextField!
    
    @IBOutlet weak var taskSwitch: UISwitch!
    
    @IBOutlet weak var notes: UITextView!
    
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoName.text = name
        
        let ref = Database.database().reference(withPath: "users").child(self.defaults.string(forKey: "uid")!).child("todos").child(name)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in

            let value = snapshot.value as? NSDictionary
            let description = value?["notes"] as? String ?? ""

            self.notes.text = description
        }
        
        
        if (isChecked == true)
        {
            taskSwitch.setOn(true, animated: true)
        }
        else
        {
            taskSwitch.setOn(false, animated: true)
        }
        
        print("uid is",self.defaults.string(forKey: "uid")!)
    }
    // change of switch
    @IBAction func stateChanged(_ sender: Any) {
        if taskSwitch.isOn {
            taskSwitch.setOn(true, animated:true)
            isChecked = true;
        } else {
            taskSwitch.setOn(false, animated:true)
            isChecked = false;
        }
    }
    
    // update list
    @IBAction func update(_ sender: Any) {
        var title: String = todoName.text!
        let state: Bool = isChecked
        let desc: String = notes.text!
        let ref = Database.database().reference(withPath: "users").child(self.defaults.string(forKey: "uid")!).child("todos")
        ref.child(name).setValue(["isChecked": state, "notes": desc])
        navigationController?.popViewController(animated: true)
        
    }
// cancel action
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    // for detleting row
    @IBAction func delteRow(_ sender: Any) {
        let ref = Database.database().reference(withPath: "users").child(self.defaults.string(forKey: "uid")!).child("todos").child(name)
        ref.removeValue()
        navigationController?.popViewController(animated: true)
    }
    
}
