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
    var values: [String]?
}

struct MapCommand {
    var author: String?
    var latitude = 0.0
    var longtitude = 0.0
}

struct RateCommand {
    var author: String?
    var values: [String]?
}

struct CompleteCommand {
    var author: String?
    var values: [String]?
}

enum CommandType {
    case undefined
    case date(DateCommand)
    case map(MapCommand)
    case rate(RateCommand)
    case complete(CompleteCommand)
}

class SocketManager {
    
    private let client = SocketIOClient(socketURL: URL(string: "http://demo-chat.ottonova.de")!, config: [.log(false), .forcePolling(true)])
    
    var messageHandler: ((String?, String?)->Void)?
    var eventHandler: ((CommandType)->Void)?
    
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
            
            var command = CommandType.undefined
            
            print("---------------------------\(data)")
            
            if let dataDict = data[0] as? Dictionary<String, AnyObject> {
                if let commandData = dataDict["command"] as? Dictionary<String, AnyObject> {
                    if let type = commandData["type"] as? String {
                        let author = dataDict["author"] as! String?
                        switch type {
                        case "map":
                            let coordinates = commandData["data"] as! Dictionary<String, Double>
                            command = .map(MapCommand.init(author: author, latitude: coordinates["lat"]!, longtitude: coordinates["lng"]!))
                        case "complete":
                            let values = commandData["data"] as! Array<String>
                            command = .complete(CompleteCommand.init(author: author, values: values))
                        case "date":
                            let dateString = commandData["data"]
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            let date = formatter.date(from: dateString as! String)
                            
                            let myCalendar = NSCalendar(calendarIdentifier: .gregorian)!
                            let myComponents = myCalendar.components(.weekday, from: date!)
                            let weekDay = myComponents.weekday!
                            
                            let days = ["Mon", "Tue", "Wen", "Thu", "Fri"]
                            
                            var resultDays = days
                            
                            if (weekDay > 2 && weekDay < 7) {
                                resultDays = Array(days[weekDay-2...days.count-1])
                                resultDays.append(contentsOf: days[0...weekDay-3])
                            }
                            
                            command = .date(DateCommand.init(author: author, values: resultDays))
                        case "rate":
                            let values = commandData["data"] as! Array<Int>
                            
                            var options = [String]()
                            
                            for index in values.first!...values.last! {
                                options.append(String(index))
                            }
                            
                            command = .rate(RateCommand.init(author: author, values: options))
                        default :
                            break
                        }
                        
                        if let handler = self.eventHandler {
                            handler(command)
                        }
                    }
                    
                }
            }
        }

        client.connect()
    }
    
    func sendMessage(message: String, author: String) -> Void {
        client.emit("message", ["author": author, "message": message])
    }
    
    func sendRandomCommand(author sender: String) -> Void {
        client.emit("command", [:])
    }
}
