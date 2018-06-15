//
//  ConnectivityHandler.swift
//  ComunicationWatch
//
//  Created by Hipólito Arias on 13/06/2018.
//  Copyright © 2018 MasterApps. All rights reserved.
//

import Foundation
import WatchConnectivity

class SessionHandler : NSObject, WCSessionDelegate {
    
    // 1: Singleton
    static let shared = SessionHandler()
    
    // 2: Property to manage session
    var session = WCSession.default
    
    override init() {
        super.init()
        
        // 3: Start and avtivate session
        session.delegate = self
        session.activate()
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }
    
    
    // MARK: - WCSessionDelegate
    
    // 4: Required protocols
    
    // a
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }

    // b
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }

    // c
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        // Reactivate session
        /**
         * This is to re-activate the session on the phone when the user has switched from one
         * paired watch to second paired one. Calling it like this assumes that you have no other
         * threads/part of your code that needs to be given time before the switch occurs.
         */
        self.session.activate()
    }
    
    /// Observer to receive messages from watch and able to response it
    ///
    /// - Parameters:
    ///   - session:
    ///   - message:
    ///   - replyHandler:
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "version" {
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
        }
    }
    
}
