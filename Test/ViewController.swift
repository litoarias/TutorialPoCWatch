//
//  ViewController.swift
//  Test
//
//  Created by Hipólito Arias on 14/06/2018.
//  Copyright © 2018 MasterApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Connect with InterfaceBuilder
    // 1: Get singleton class whitch manage WCSession
    var connectivityHandler = SessionHandler.shared
    
    // 2: Counter for manage number of messages sended
    var messagesCounter = 0
    
    // ...
    
    /// Send messages on main thread
    @IBAction func sendMessage(_ sender: UIButton) {
        messagesCounter += 1
        // 3: Send message to apple watch, we don't wait to response, only trace errors
        connectivityHandler.session.sendMessage(["msg" : "Message \(messagesCounter)"], replyHandler: nil) { (error) in
            print("Error sending message: \(error)")
        }
    }
    
}

