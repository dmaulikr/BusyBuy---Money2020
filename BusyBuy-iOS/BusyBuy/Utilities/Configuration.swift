//
//  Configuration.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import Foundation

private let kBaseURL: String = "Non Secure Base URL"
private let kSecureBaseURL: String = "Secure Base URL"
private let kRequestTimeout: String = "Request Timeout"
private let kParseDict: String = "Parse Credentials"
private let kParseClientID: String = "Client ID"
private let kParseClientSecret: String = "Client Secret"

private let kPayeezyDict = "Payeezy Credentials"
private let kPayeezyAPIKey = "API Key"
private let kPayeezyAPISecret = "API Secret"
private let kPayeezyMerchantToken = "Merchant Token"
private let kApplePayMerchantID = "ApplePay Merchant ID"

class Configuration {
    private static var config:[String: AnyObject]?
    
    class func getBaseURL() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary() {
            return dictionary[kBaseURL] as? String
        }
        return nil
    }
    
    class func getSecureBaseURL() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary() {
            return dictionary[kSecureBaseURL] as? String
        }
        return nil
    }
    
    class func getRequestTimeout() -> Int? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary() {
            return dictionary[kRequestTimeout] as? Int
        }
        return nil
    }
    
    class func getParseClientID() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), parseDict = dictionary[kParseDict] as? Dictionary<String, AnyObject>, clientId = parseDict[kParseClientID] as? String {
            return clientId
        }
        return nil
    }
    
    class func getParseClientSecret() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), parseDict = dictionary[kParseDict] as? Dictionary<String, AnyObject>, clientId = parseDict[kParseClientSecret] as? String {
            return clientId
        }
        return nil
    }
    
    class func getPayeegyAPIKey() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), parseDict = dictionary[kPayeezyDict] as? Dictionary<String, AnyObject>, clientId = parseDict[kPayeezyAPIKey] as? String {
            return clientId
        }
        
        return nil
    }
    
    class func getPayeegyAPISecret() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), parseDict = dictionary[kPayeezyDict] as? Dictionary<String, AnyObject>, clientId = parseDict[kPayeezyAPISecret] as? String {
            return clientId
        }
        return nil
    }
    
    class func getPayeegyMerchantToken() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), parseDict = dictionary[kPayeezyDict] as? Dictionary<String, AnyObject>, clientId = parseDict[kPayeezyMerchantToken] as? String {
            return clientId
        }
        return nil
    }
    
    class func getApplePayMerchantID() -> String? {
        if let dictionary:Dictionary<String, AnyObject> = Configuration.dictionary(), merchantId = dictionary[kApplePayMerchantID] as? String {
            return merchantId
        }
        return nil
    }
    
    private class func configurationFilePath() -> String?{
        guard let path = NSBundle.mainBundle().pathForResource("Configuration", ofType: "plist") else {
            return nil
        }
        
        return path
    }
    
    private class func dictionary() -> Dictionary<String, AnyObject>? {
        if let values =  Configuration.config {
            return values
        }
        
        guard let path = Configuration.configurationFilePath(), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            return nil
        }
        
        Configuration.config = dict
        return dict
    }
}