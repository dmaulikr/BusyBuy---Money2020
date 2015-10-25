//
//  NotificationHelper.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import Foundation
import UIKit

class NotificationHelper {
    class func rescheduleNotifications() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (!userDefaults.boolForKey(Notification.On.key())) {
            return
        }
        unscheduleNotifications()
        askPermission()
    }
    
    class func showLocalNotificationWith(msg: String, userInfo: [String: AnyObject]) {
        let notification = UILocalNotification()
        notification.alertBody = msg
        notification.fireDate = NSDate(timeIntervalSinceNow: 0)
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    class func showLocalNotificationWith(msg: String) {
        let notification = UILocalNotification()
        notification.alertBody = msg
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    class func scheduleNotification(date date:NSDate) {
        let reminder = UILocalNotification()
        reminder.fireDate = date
        reminder.repeatInterval = .Day
        reminder.alertBody = NSLocalizedString("notification text", comment: "")
        reminder.alertAction = "Ok"
    }
    
    class func unscheduleNotifications() {
        if let _ = UIApplication.sharedApplication().scheduledLocalNotifications {
            UIApplication.sharedApplication().scheduledLocalNotifications!.removeAll()
        }
    }
    
    class func askPermission() {
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    class func handleNotification(notification: UILocalNotification, identifier: String) {
        if (notification.category == "*") {
            if (identifier == "*") {
            }
            if (identifier == "*") {
            }
        }
    }
}

func showLocalNotificationWith(msg: String, userInfo: [String: AnyObject]) {
    let notification = UILocalNotification()
    notification.alertBody = msg
    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
}

func showLocalNotificationWith(msg: String) {
    let notification = UILocalNotification()
    notification.alertBody = msg
    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
}