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
    
    @IBOutlet var messagesTable: WKInterfaceTable!    
    @IBOutlet weak var picker: WKInterfacePicker!
    @IBOutlet weak var btnDate: WKInterfaceButton!
    @IBOutlet weak var btnVersion: WKInterfaceButton!
    
    var connectivityHandler = WatchSessionManager.shared
    var session : WCSession?
    var counter = 0
    var messages = [String]() {
        didSet {
            OperationQueue.main.addOperation {
                self.updateMessagesTable()
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        messages.append("ready")
        
        // Set picker data
        let pickerItems: [WKPickerItem] = Constants.itemList.map {
            let pickerItem = WKPickerItem()
            pickerItem.caption = $0.0
            pickerItem.title = $0.1
            return pickerItem
        }
        picker.setItems(pickerItems)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        connectivityHandler.startSession()
        connectivityHandler.watchOSDelegate = self
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func dateRequest() {
        let data = ["request" : RequestType.date.rawValue as AnyObject]
        connectivityHandler.sendMessage(message: data, replyHandler: { (response) in
            self.messages.append("Reply: \(response)")
        }) { (error) in
            print("Error sending message: \(error)")
        }
    }
    
    
    @IBAction func versionRequest() {
        let data = ["request" : RequestType.version.rawValue as AnyObject]
        connectivityHandler.sendMessage(message: data, replyHandler: { (response) in
            self.messages.append("Reply: \(response)")
        }) { (error) in
            print("Error sending message: \(error)")
        }
    }
    
    // MARK: - Messages Table
    
    func updateMessagesTable() {
        messagesTable.setNumberOfRows(messages.count, withRowType: "Row")
        for (i, msg) in messages.enumerated() {
            let row = messagesTable.rowController(at: i) as? Row
            row?.lbl.setText(msg)
        }
    }
    
    @IBAction func changeTheme(_ value: Int) {
        selectedTheme(row: value)
        do {
            try connectivityHandler.updateApplicationContext(applicationContext: ["row" : value] as [String : AnyObject])
        } catch {
            print("Error: \(error)")
        }
    }
    
    func selectedTheme(row: Int) {
        self.btnDate.setBackgroundColor(Constants.itemList[row].2)
        self.btnVersion.setBackgroundColor(Constants.itemList[row].2)
    }
}

extension InterfaceController: WatchOSDelegate {
    
    func applicationContextReceived(tuple: ApplicationContextReceived) {
        DispatchQueue.main.async() {
            if let row = tuple.applicationContext["row"] as? Int {
                self.changeTheme(row)
            }
        }
    }
    
    
    func messageReceived(tuple: MessageReceived) {
        DispatchQueue.main.async() {
            WKInterfaceDevice.current().play(.notification)
            if let msg = tuple.message["msg"] {
                self.messages.append("\(msg)")
            }
        }
    }
    
}
