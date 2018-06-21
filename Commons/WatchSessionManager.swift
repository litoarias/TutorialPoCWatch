//
//  WatchSessionManager.swift
//  ComunicationWatch
//
//  Created by Hipolito Arias on 17/06/2018.
//  Copyright © 2018 MasterApps. All rights reserved.
//


import WatchKit
import WatchConnectivity

// 1: Encapsulating in a tuple for don't duplicate code
typealias MessageReceived = (session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?)

// 2: Protocol for manage all watchOS delegations
protocol WatchOSDelegate: AnyObject {
    func messageReceived(tuple: MessageReceived)
}

// 3: Protocol for manage all iOS delegations
protocol iOSDelegate: AnyObject {
    func messageReceived(tuple: MessageReceived)
}

class WatchSessionManager: NSObject {

    // 4: Singleton for manage only one instance
    static let shared = WatchSessionManager()
    
    // 5: Delegates for each platform
    weak var watchOSDelegate: WatchOSDelegate?
    weak var iOSDelegate: iOSDelegate?

    // 6: Getting session if we want get it, if not return nil
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    // 7: If device it's avaliable
    var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience
        
        #if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
        #elseif os(watchOS)
        return session
        #endif
    }
    
    // 8: Method for start session and set this class with a delegate
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    

}

// MARK: WCSessionDelegate
extension WatchSessionManager: WCSessionDelegate {
    
    /**
     * Called when the session has completed activation.
     * If session state is WCSessionActivationStateNotActivated there will be an error with more details.
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // 9: Only for iOS OS
    #if os(iOS)
    /**
     * Called when the session can no longer be used to modify or add any new transfers and,
     * all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur.
     * This will happen when the selected watch is being changed.
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    /**
     * Called when all delegate callbacks for the previously selected watch has occurred.
     * The session can be re-activated for the now selected watch using activateSession.
     */
    // 10: 
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        /**
         * This is to re-activate the session on the phone when the user has switched from one
         * paired watch to second paired one. Calling it like this assumes that you have no other
         * threads/part of your code that needs to be given time before the switch occurs.
         */
        self.session?.activate()
    }
    #endif

}

// 11: MARK: Interactive Messaging
extension WatchSessionManager {
    
    // 12: Live messaging! App has to be reachable
    private var validReachableSession: WCSession? {
        if let session = validSession, session.isReachable {
            return session
        }
        return nil
    }
    
    // 13: Sender
    func sendMessage(message: [String : AnyObject], replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendMessageData(data: Data, replyHandler: ((Data) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    // end Sender
    
    // 14: Receiver
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleSession(session, didReceiveMessage: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleSession(session, didReceiveMessage: message, replyHandler: replyHandler)
    }
    // end Receiver
    
    // 15: Helper Method
    func handleSession(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: (([String : Any]) -> Void)? = nil) {
        // handle receiving message
        #if os(iOS)
        iOSDelegate?.messageReceived(tuple: (session, message, replyHandler))
        #elseif os(watchOS)
        watchOSDelegate?.messageReceived(tuple: (session, message, replyHandler))
        #endif
    }
    
   
}

//// MARK: Application Context
//// use when your app needs only the latest information
//// if the data was not sent, it will be replaced
//extension WatchSessionManager {
//
//    // Sender
//    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
//        if let session = validSession {
//            do {
//                try session.updateApplicationContext(applicationContext)
//            } catch let error {
//                throw error
//            }
//        }
//    }
//
//    // Receiver
//    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//        // handle receiving application context
//        DispatchQueue.main.async() {
//            // make sure to put on the main queue to update UI!
//        }
//    }
//}

//// MARK: User Info
//// use when your app needs all the data
//// FIFO queue
//extension WatchSessionManager {
//
//    // Sender
//    func transferUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
//        return validSession?.transferUserInfo(userInfo)
//    }
//
//    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
//        // implement this on the sender if you need to confirm that
//        // the user info did in fact transfer
//    }
//
//    // Receiver
//    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
//        // handle receiving user info
//        DispatchQueue.main.async() {
//            // make sure to put on the main queue to update UI!
//        }
//    }
//
//}

//// MARK: Transfer File
//extension WatchSessionManager {
//
//    // Sender
//    func transferFile(file: NSURL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
//        return validSession?.transferFile(file as URL, metadata: metadata)
//    }
//
//    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: Error?) {
//        // handle filed transfer completion
//    }
//
//    // Receiver
//    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
//        // handle receiving file
//        DispatchQueue.main.async() {
//            // make sure to put on the main queue to update UI!
//        }
//    }
//}


