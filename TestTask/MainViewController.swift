//
//  ViewController.swift
//  TestTask
//
//  Created by Sergii Shulga on 9/27/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MainViewController: JSQMessagesViewController {

    let socketManager = SocketManager()
    var messages = [JSQMessageData]()
    
    
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketManager.messageHandler = handleMessage
        socketManager.eventHandler = handleCommand
        socketManager.start()
        
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.init()
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.init()
        
        let barButtonItem = UIBarButtonItem.init(title: "Add event", style: .plain, target: self, action: (#selector(MainViewController.onAddEvent(_:))))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }

    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: id, text: text)
        messages.append(message!)
        finishReceivingMessage()
    }

    private func handleMessage(_ message: String?, author: String?) -> Void {
        addMessage(id: author!, text: message!)
    }
    
    private func handleCommand(_ command: CommandType) -> Void {
        switch command {
        case .map(let mapCommand):
            let location = CLLocation.init(latitude: mapCommand.latitude, longitude: mapCommand.longtitude)
            let item = JSQLocationMediaItem.init(location: location)
            let message = JSQMessage.init(senderId: mapCommand.author, displayName: mapCommand.author, media: item)
            messages.append(message!)
            item?.setLocation(location, withCompletionHandler: {
                self.finishReceivingMessage()
            })
            finishReceivingMessage()
        case .complete(let completeCommand):
            showOptions(options: completeCommand.values!, author: completeCommand.author!, title: "Have you completed?")
        case .date(let dateCommand):
            showOptions(options: dateCommand.values!, author: dateCommand.author!, title: "Please choose date")
        case .rate(let rateCommand):
            showOptions(options: rateCommand.values!, author: rateCommand.author!, title: "Please rate your experience")
        default:
            break
        }
    }
    
    private func showOptions(options: Array<String>, author: String, title: String) -> Void {
        let item = OptionItem.init()
        item.options = options
        item.textOption = title
        item.completion = onOption
        let message = JSQMessage.init(senderId: author, displayName: author, media: item)
        messages.append(message!)
        finishReceivingMessage()
    }
    
    func onAddEvent(_ sender: UIBarButtonItem) -> Void {
        socketManager.sendRandomCommand(author: senderId)
    }
    
    private func onOption (title: String, item: OptionItem) -> Void {
        socketManager.sendMessage(message: title, author: senderId)

        var index: Int?
        for (curIndex, messageItem) in messages.enumerated() {
            if let option = messageItem.media!() as? OptionItem {
                if (option.dateCreation == item.dateCreation) {
                    index = curIndex
                }
            }
        }
        
        if index != nil {
            let message = JSQMessage(senderId: senderId, displayName: senderId, text: title)
            messages[index!] = message!
            finishReceivingMessage()
            finishSendingMessage()
        }
    }
}

// MARK: - overriding

extension MainViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        socketManager.sendMessage(message: text, author: senderId)
        addMessage(id: senderId, text: text)
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId() == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId() == senderId {
            if let textView = cell.textView {
                textView.textColor = UIColor.white
            }
            cell.cellTopLabel.textAlignment = .right
            cell.cellTopLabel.textInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 15.0)
        } else {
            if let textView = cell.textView {
                textView.textColor = UIColor.black
            }
            cell.cellTopLabel.textAlignment = .left
            cell.cellTopLabel.textInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        return NSAttributedString.init(string: message.senderDisplayName())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20.0
    }
}
