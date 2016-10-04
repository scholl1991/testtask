//
//  Commands.swift
//  TestTask
//
//  Created by Sergii Shulga on 10/3/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class OptionItem: JSQMediaItem {
    let dateCreation = Date.init()
    
    var options = [String]()
    var textOption: String?
    var completion: ((String, OptionItem) -> Void)?
    
    override func mediaView() -> UIView! {
        
        let view = UIView.init()
        view.backgroundColor = UIColor.lightText
        view.layer.cornerRadius = 5.0
        view.layer.borderColor = UIColor.lightText.cgColor
        view.layer.masksToBounds = true
        
        let label = UILabel.init()
        label.text = textOption
        label.sizeToFit()
        label.frame = CGRect.init(x: 3.0, y: 3.0, width: label.bounds.size.width, height: label.bounds.size.height)
        view.addSubview(label)
        
        var buttons = [UIButton]()
        var width = CGFloat(3.0)
        
        for option in options {
            let button = UIButton.init(type: .custom)
            button.setTitle(option, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(OptionItem.onOption(sender:)), for: .touchUpInside)
            button.layer.cornerRadius = 3.0
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.masksToBounds = true
            button.sizeToFit()
            view.addSubview(button)
            buttons.append(button)
            
            button.frame = CGRect.init(x: width, y: label.bounds.size.height + 6, width: max(button.bounds.size.width, 30.0), height: button.bounds.size.height)
            
            width += button.bounds.size.width + 3.0
        }
        
        width += CGFloat(buttons.count * 3)
        
        view.frame = CGRect.init(x: 0.0, y: 0.0, width: max(width, label.bounds.size.width + 6.0), height: label.bounds.size.height + (buttons.first?.bounds.size.height)! + 9.0)
        
        return view
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return self.mediaView().bounds.size
    }
    
    override func mediaPlaceholderView() -> UIView! {
        return UIView.init()
    }
    
    func onOption(sender: UIButton) -> Void {
        if let handler = completion {
            handler(sender.title(for: .normal)!, self)
        }
    }
    
    override func mediaHash() -> UInt {
        return UInt(bitPattern: self.hash) ^ UInt(bitPattern: self.dateCreation.hashValue)
    }
}
