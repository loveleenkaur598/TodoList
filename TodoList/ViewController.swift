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
                
                if(self.userEmail.text == "" && self.userPassword.text == ""){
                    self.showToast(message : "Enter Email/Password")
                }
                
                if error != nil && self.userEmail.text != "" && self.userPassword.text != ""{
                    print(error!._code)
                    if(error!._code == 17008){
                        self.showToast(message : "Invalid email address!")
                    }else if(error!._code == 17007){
                        self.showToast(message : "Email already exist!")
                    }else{
                        self.showToast(message : "Check Email/Password")
                    }
                }else if(self.userEmail.text != "" && self.userPassword.text != ""){
                    self.uid = (result?.user.uid)!
                    let ref = Database.database().reference(withPath: "users").child(self.uid)
                    ref.setValue(["email" : self.userEmail.text! , "password" : self.userPassword.text!])
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                    self.showToast(message : "Successfully registered!")
                }
            }
        }
        
    }
    @IBAction func signInUser(_ sender: Any) {
        if(userEmail.text != nil && userPassword.text != nil){
            Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (result, error) in
                if(self.userEmail.text == "" && self.userPassword.text == ""){
                    self.showToast(message : "Enter Email/Password")
                }
                if error != nil{
                    //print(error!)
                    print(error!._code)
                    if(error!._code == 17008){
                        self.showToast(message : "Invalid email address!")
                    }else if(error!._code == 17011){
                        self.showToast(message : "Please registered first!")
                    }else{
                        self.showToast(message : "Check Email/Password")
                    }
                }else if(self.userEmail.text != "" && self.userPassword.text != ""){
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

