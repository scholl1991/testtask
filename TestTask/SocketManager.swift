//
//  SocketManager.swift
//  TestTask
//
//  Created by Sergii Shulga on 9/28/16.
//  Copyright © 2016 Sergii Shulga. All rights reserved.
//

import Foundation
import SocketIO

class SocketManager {
    
    let client = SocketIOClient(socketURL: URL(string: "http://demo-chat.ottonova.de")!, config: [.log(true), .forcePolling(true)])
    
    func start() -> Void {
        
        
        client.on("connect") {data, ack in
            print("socket connected")
        }
        
        client.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.client.emitWithAck("canUpdate", cur)(0) {data in
                    self.client.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        client.connect()
    }
}
