//
//  WelcomeViewController.swift
//  TestTask
//
//  Created by  Sergii Shulga on 10/3/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import UIKit

enum WelcomeSegueIdentifiers: String {
    case main = "showMainController"
}

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MainViewController {
            controller.senderId = nameField.text
            controller.senderDisplayName = "\(nameField.text) chat"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text
        
        let result = (text! as NSString).replacingCharacters(in: range, with: string)
        enterButton.isEnabled = result.characters.count > 0
        
        return true
    }
}
