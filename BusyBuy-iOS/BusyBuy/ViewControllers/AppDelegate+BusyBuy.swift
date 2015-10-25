//
//  AppDelegate+BusyBuy.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import Foundation
import Parse

extension AppDelegate {
    func setupParse(launchOptions: [NSObject: AnyObject]?) {
        if let id = Configuration.getParseClientID(), secret = Configuration.getParseClientSecret() {
            Parse.setApplicationId(id, clientKey: secret)
        }
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Background {
            let preBackgroundPush = !UIApplication.sharedApplication().respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
                // Send the to Parse along with the 'read' event
                PFAnalytics.trackEventInBackground("read", dimensions: nil, block: nil)
            }
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)        
        installation.saveInBackgroundWithBlock(nil)
        
        
        let user = PFUser.currentUser()
        let relation = user?.relationForKey("device")
        relation?.addObject(installation)
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                print("save successs")
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.", terminator: "")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error, terminator: "")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        print(userInfo["order_id"])
        
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: nil)
        }
        
        if let delegate = notificationsListener {
            delegate.notificationReceivedWith(userInfo)
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let _ = identifier {

        }
        
        completionHandler()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }
}