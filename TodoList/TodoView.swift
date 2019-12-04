//
//  TodoView.swift
//  TodoList
//
//  Created by MacUser on 2019-12-03.
//  Copyright © 2019 MacUser. All rights reserved.
//

import UIKit

class TodoView: UIViewController {

    @IBOutlet weak var homeScreenLabel: UILabel!
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = userId{
            homeScreenLabel.text = uid
        }

        // Do any additional setup after loading the view.
    }

}
