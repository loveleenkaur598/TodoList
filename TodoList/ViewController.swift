//
//  ViewController.swift
//  TodoList
//
//  Created by MacUser on 2019-12-03.
//  Copyright © 2019 MacUser. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
    var uid: String = ""
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        userEmail.text = ""
        userPassword.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userEmail.text = ""
        userPassword.text = ""
    }

    @IBAction func registerUser(_ sender: Any) {
        
        if(userEmail.text != nil && userPassword.text != nil){
            Auth.auth().createUser(withEmail: userEmail.text!, password: userPassword.text!) { (result, error) in
                if error != nil{
                    print("There is an error")
                    print(error!)
                }else{
                    self.uid = (result?.user.uid)!
                    let ref = Database.database().reference(withPath: "users").child(self.uid)
                    ref.setValue(["email" : self.userEmail.text! , "password" : self.userPassword.text!])
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
        
    }
    @IBAction func signInUser(_ sender: Any) {
        if(userEmail.text != nil && userPassword.text != nil){
            Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (result, error) in
                if error != nil{
                    print("There is an error")
                }else{
                    self.uid = (result?.user.uid)!
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as! UINavigationController
        let todoVc = navigation.topViewController as! TodoView
        todoVc.userId = uid
    }
}

