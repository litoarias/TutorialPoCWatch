//
//  InterfaceController.swift
//  Test WatchKit Extension
//
//  Created by Hipólito Arias on 14/06/2018.
//  Copyright © 2018 MasterApps. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    // Session property
    private var session = WCSession.default
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    // MARK: - Items Table
    
    private var items = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.updateTable()
            }
        }
    }
    
    
    /// Updating all contents of WKInterfaceTable
    private func updateTable() {
        table.setNumberOfRows(items.count, withRowType: "Row")
        for (i, item) in items.enumerated() {
            if let row = table.rowController(at: i) as? Row {
                row.lbl.setText(item)
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        items.append("We are ready!!")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Initialization of session and set as delegate this InterfaceController if it's supported
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
    }
    
    // With our session property which allows implement a method for start communication
    // and manage the counterpart response
    @IBAction func sendMessage() {
        /**
         *  The iOS device is within range, so communication can occur and the WatchKit extension is running in the
         *  foreground, or is running with a high priority in the background (for example, during a workout session
         *  or when a complication is loading its initial timeline data).
         */
        if isReachable() {
            session.sendMessage(["request" : "version"], replyHandler: { (response) in
                self.items.append("Reply: \(response)")
            }, errorHandler: { (error) in
                print("Error sending message: %@", error)
            })
        } else {
            print("iPhone is not reachable!!")
        }
    }
}


extension InterfaceController: WCSessionDelegate {
    
    // Required stub for delegating session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // Intercambiar mensajes con sendMessage en primer plano
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice.current().play(.notification)
        let msg = message["msg"]!
        self.items.append("\(msg)")
    }
    
}
