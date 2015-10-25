//
//  Constants.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import Foundation
extension NSUserDefaults {
    class func defaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}

public enum NotificationType: Int {
    case Type1, Type2, Type3, Type4
    public func name() -> String {
        switch self {
        case .Type1:
            return "Type1"
        case .Type2:
            return "Type2"
        case .Type3:
            return "Type3"
        case .Type4:
            return "Type4"
        }
    }
}

public enum Notification: Int {
    case On, From, To, Interval
    public func key() -> String {
        switch self {
        case .On:
            return "NOTIFICATION_ON"
        case .From:
            return "NOTIFICATION_FROM"
        case .To:
            return "NOTIFICATION_TO"
        case .Interval:
            return "NOTIFICATION_INTERVAL"
        }
    }
}

public enum LocationAccess: Int {
    case On
    public func key() -> String {
        switch self {
        case .On:
            return "Location_Access_ON"
        }
    }
}



enum PaymentType: String {
    case Purchase,
    PreAuthorization
}


public enum PaymentNetworks: String {
    case Visa, MasterCard, AmEx
    
    static func availablePaymentNetworks() -> [String] {
        return [Visa.rawValue, MasterCard.rawValue, AmEx.rawValue]
    }
}

public func registerDefaults() {
    let userDefaults = NSUserDefaults.defaults()
    
    // The defaults registered with registerDefaults are ignore by the Today Extension. :/
    if (!userDefaults.boolForKey("DEFAULTS_INSTALLED")) {
        userDefaults.setBool(true, forKey: "DEFAULTS_INSTALLED")
    }
    userDefaults.synchronize()
}


func showLocationAccessRequestAlert() {
    let alertController = UIAlertController(title: "Location Access required.",
        message: "Always location access permission was denied. Please enable it in Settings.",
        preferredStyle: .Alert)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (alertAction) in
        if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(appSettings)
        }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(settingsAction)
    alertController.addAction(cancelAction)
    
    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
}

func showAlertController(withTitle title: String, msg: String) {
    let alertController = UIAlertController(title: title,
        message: msg,
        preferredStyle: .Alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
    alertController.addAction(okAction)
    
    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
}

