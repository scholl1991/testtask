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

    func handleMessage(_ message: String?, author: String?) -> Void {
        addMessage(id: author!, text: message!)
    }
    
    func handleCommand(_ command: CommandType) -> Void {
        
    }
    
    func onAddEvent(_ sender: UIBarButtonItem) -> Void {
        socketManager.sendRandomCommand(author: senderId)
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
        if message.senderId == senderId {
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
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
            cell.cellTopLabel.textAlignment = .right
            cell.cellTopLabel.textInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 15.0)
        } else {
            cell.textView!.textColor = UIColor.black
            cell.cellTopLabel.textAlignment = .left
            cell.cellTopLabel.textInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        return NSAttributedString.init(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20.0
    }
}

// MARK: - custom cells

extension MainViewController {
    
}
