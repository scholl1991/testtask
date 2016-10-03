//
//  SocketManager.swift
//  TestTask
//
//  Created by Sergii Shulga on 9/28/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import Foundation
import SocketIO

struct DateCommand {
    var author: String?
}

struct MapCommand {
    var author: String?
    var latitude = 0.0
    var longtitude = 0.0
}

struct RateCommand {
    var author: String?
}

struct CompleteCommand {
    var author: String?
}

enum CommandType {
    case date(DateCommand)
    case map(MapCommand)
    case rate(RateCommand)
    case complete(CompleteCommand)
}

class SocketManager {
    
    private let client = SocketIOClient(socketURL: URL(string: "http://demo-chat.ottonova.de")!, config: [.log(false), .forcePolling(true)])
    
    var messageHandler: ((String?, String?)->Void)?
    var eventHandler: ((String, Dictionary<String, Any>)->Void)?
    
    func start() -> Void {
        
        client.on("connect") {data, ack in
            print("socket connected")
        }
        
        client.on("message") { (data, ack) in
            
            if let dataDict = data[0] as? Dictionary<String, String> {
                if let handler = self.messageHandler {
                    handler(dataDict["message"], dataDict["author"])
                }
            }
        }
        
        client.on("command") { (data, ack) in
            
            var command: CommandType
            
            if let dataDict = data[0] as? Dictionary<String, AnyObject> {
                if let commandData = dataDict["command"] as? Dictionary<String, AnyObject> {
                    if let type = commandData["type"] as? String {
                        switch type {
                        case "map":
                            command = .map(MapCommand.init())
                        default :
                            break
                        }
                        
                    }
                    
                }
            }
            
            if let handler = self.eventHandler {
                handler("author", ["type":"type", "data":[:]])
            }
            
            print("---------------------------\(data)")
        }

        client.connect()
    }
    
    func sendMessage(message: String, author: String) -> Void {
        client.emit("message", ["author": author, "message": message])
    }
    
    func sendRandomCommand(author sender: String) -> Void {
//        client.emit("command", ["author":sender, "command":["type":"", "data":[:]]])
        client.emit("command", [:])
    }
}
