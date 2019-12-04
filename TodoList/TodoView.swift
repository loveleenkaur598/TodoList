//
//  TodoView.swift
//  TodoList
//
//  Created by MacUser on 2019-12-03.
//  Copyright © 2019 MacUser. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct Todo {
    var isChecked: Bool
    var todoName: String
}

class TodoView: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var homeScreenLabel: UILabel!
    @IBOutlet weak var todoTV: UITableView!
    
    
    var todos: [Todo] = []
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWelcomeLabel()
        
        todoTV.delegate = self
        todoTV.dataSource = self
        todoTV.rowHeight = 80
        
//        if let uid = userId{
//            homeScreenLabel.text = uid
//        }
        
        loadTodos()
    }
    
    
    func setWelcomeLabel(){
        let userRef = Database.database().reference(withPath: "users").child(userId!)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value!["email"] as? String
            self.homeScreenLabel.text = "Hello " + email! + "!"
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func addTodo(_ sender: Any) {
        let todoAlert = UIAlertController(title: "New Todo", message: "Add a todo", preferredStyle: .alert)
        todoAlert.addTextField()
        
        let addTodoAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let todoText = todoAlert.textFields![0].text
            self.todos.append(Todo(isChecked: false, todoName: todoText!))
            
            let ref = Database.database().reference(withPath: "users").child(self.userId!).child("todos")
            ref.child(todoText!).setValue(["isChecked": false])
            
            self.todoTV.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        todoAlert.addAction(addTodoAction)
        todoAlert.addAction(cancelAction)
        
        present(todoAlert, animated: true, completion: nil)
    }
    

    func loadTodos(){
        let ref = Database.database().reference(withPath: "users").child(userId!).child("todos")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let todoName = child.key
                let todoRef = ref.child(todoName)
                todoRef.observeSingleEvent(of: .value) { (todoSnapshot) in
                    let value = todoSnapshot.value as? NSDictionary
                    let isChecked = value!["isChecked"] as? Bool
                    self.todos.append(Todo(isChecked: isChecked!, todoName: todoName))
                    
                    self.todoTV.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoCell
        
        cell.todoLabel.text = todos[indexPath.row].todoName
        if todos[indexPath.row].isChecked{
            cell.checkMarkImage.image = UIImage(named: "checkmark.png")
        }
        else{
            cell.checkMarkImage.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child(todos[indexPath.row].todoName)
        if todos[indexPath.row].isChecked{
            todos[indexPath.row].isChecked = false
            ref.updateChildValues(["isChecked": false])
        }
        else
        {
            todos[indexPath.row].isChecked = true
            ref.updateChildValues(["isChecked": true])
        }
        
        todoTV.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{

            let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child(todos[indexPath.row].todoName)
            
            ref.removeValue()
            todos.remove(at: indexPath.row)
            todoTV.reloadData()
        }
    }

}
