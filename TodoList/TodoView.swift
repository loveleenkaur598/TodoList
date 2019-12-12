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
    var notes:String
}

class TodoView: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    @IBOutlet weak var homeScreenLabel: UILabel!
    @IBOutlet weak var todoTV: UITableView!
    
    
    var todos: [Todo] = []
    
    var userId: String?
    
    var todoDetails = [String: Any]()
    var name = ""
    var isDone = false
    var desc = ""
    
    override func viewDidAppear(_ animated: Bool) {
        loadTodos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWelcomeLabel()
        todoTV.delegate = self
        todoTV.dataSource = self
        todoTV.rowHeight = 80
        loadTodos()
        
    }
    
    //welcome message
    func setWelcomeLabel(){
        let userRef = Database.database().reference(withPath: "users").child(userId!)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value!["email"] as? String
            self.homeScreenLabel.text = "Hello " + email! + "!"
        }
    }
    
    // logout action
    @IBAction func logout(_ sender: Any) {
        
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // add todo list
    @IBAction func addTodo(_ sender: Any) {
        let todoAlert = UIAlertController(title: "New Todo", message: "Add a todo", preferredStyle: .alert)
        todoAlert.addTextField()
        
        let addTodoAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let todoText = todoAlert.textFields![0].text
            self.todos.append(Todo(isChecked: false, todoName: todoText!, notes: ""))
            
            let ref = Database.database().reference(withPath: "users").child(self.userId!).child("todos")
            ref.child(todoText!).setValue(["isChecked": false, "notes": ""])
            
            self.todoTV.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        todoAlert.addAction(addTodoAction)
        todoAlert.addAction(cancelAction)
        
        present(todoAlert, animated: true, completion: nil)
    }
    

    // load all todos
    func loadTodos(){
        todos = [Todo]()
        let ref = Database.database().reference(withPath: "users").child(userId!).child("todos")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let todoName = child.key
                let todoRef = ref.child(todoName)
                todoRef.observeSingleEvent(of: .value) { (todoSnapshot) in
                    let value = todoSnapshot.value as? NSDictionary
                    let isChecked = value!["isChecked"] as? Bool
                    let desc = value!["notes"] as? String
                    self.todos.append(Todo(isChecked: isChecked!, todoName: todoName, notes: desc ?? ""))
                    print("todos",self.todos)
                    self.todoTV.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(todos.count == 0){
            showToast(message : "Get started with TODO's!")
        }
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! TodoCell

        cell.todoLabel.text = todos[indexPath.row].todoName
        if todos[indexPath.row].isChecked{
            cell.checkMarkImage.image = UIImage(named: "onToggle.png")
        }
        else{
            cell.checkMarkImage.image = UIImage(named: "offToggle.png")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child(todos[indexPath.row].todoName)
//        if todos[indexPath.row].isChecked{
//            todos[indexPath.row].isChecked = false
//            ref.updateChildValues(["isChecked": false])
//        }
//        else
//        {
//            todos[indexPath.row].isChecked = true
//            ref.updateChildValues(["isChecked": true])
//        }
//        
//      todoTV.reloadData()
        
               
        let index = todos[indexPath.row]
        name = index.todoName
        isDone = index.isChecked
        desc = index.notes
        
        
//        todoDetails["name"] = Database.database().reference(withPath: "users").child(userId!).child("todos").child(todos[indexPath.row].todoName)
//
       self.performSegue(withIdentifier: "passDetail", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{

            let ref = Database.database().reference(withPath: "users").child(userId!).child("todos").child(todos[indexPath.row].todoName)
            
            ref.removeValue()
            todos.remove(at: indexPath.row)
            todoTV.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passDetail"{
           let detail = segue.destination as? TodoDetail
            detail!.name = name
            detail!.isChecked = isDone
            detail!.desc = desc
        }
    }
    
    // print message function
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

}
