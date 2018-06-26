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
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var btnSendMessage: UIButton!
    
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectivityHandler.iOSDelegate = self
        
        picker.delegate = self
        picker.dataSource = self
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
    
    func applicationContextReceived(tuple: ApplicationContextReceived) {
        DispatchQueue.main.async() {
            if let row = tuple.applicationContext["row"] as? Int {
                self.btnSendMessage.backgroundColor = Constants.itemList[row].2
            }
        }
    }
    
    
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

// MARK: UIPickerViewDataSource - UIPickerViewDelegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.itemList.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.itemList[row].1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        do {
            try connectivityHandler.updateApplicationContext(applicationContext: ["row" : row])
        } catch {
            print("Error: \(error)")
        }
        self.btnSendMessage.backgroundColor = Constants.itemList[row].2
    }
}
