//
//  ViewController.swift
//  Test
//
//  Created by Hipólito Arias on 14/06/2018.
//  Copyright © 2018 MasterApps. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    var connectivityHandler = WatchSessionManager.shared
    
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectivityHandler.iOSDelegate = self
        
    }
    
    /// Send messages on main thread
    ///
    /// - Parameter sender: UIButton
    @IBAction func sendMessage(_ sender: UIButton) {
        counter += 1
        connectivityHandler.sendMessage(message: ["msg" : "Message \(counter)" as AnyObject]) { (error) in
            print("Error sending message: \(error)")
        }
    }
}

extension ViewController: iOSDelegate {
    
    func messageReceived(tuple: MessageReceived) {
        // Handle receiving message
        
        guard let reply = tuple.replyHandler else {
            return
        }
        
        // Need reply to counterpart
        switch tuple.message["request"] as! RequestType.RawValue {
        case RequestType.date.rawValue:
            reply(["date" : "\(Date())"])
        case RequestType.version.rawValue:
            let version = ["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"]
            reply(["version" : version])
        default:
            break
        }
    }
    
}
