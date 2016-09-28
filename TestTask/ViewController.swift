//
//  ViewController.swift
//  TestTask
//
//  Created by Sergii Shulga on 9/27/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let socketManager = SocketManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketManager.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

