//
//  HTTPManager.swift
//  Networking
//
//  Created by Prasad Pamidi on 2/11/15.
//

import Foundation

class HTTPManager {
    class func processUserLogInWith(username: String, password: String, success: HttpSuccessHandler, failure: HttpErrorHandler) {
        HTTPClient.client.defaultEncoding = .JSON
        HTTPClient.client.postResource("login", parameters: ["username":username, "password": password], success: success, failure: failure)
    }
    
    class func informPurchaseConfirmationTo(merchant: String, order: String, amount: Double,success: HttpSuccessHandler, failure: HttpErrorHandler) {
        HTTPClient.client.defaultEncoding = .JSON

        HTTPClient.client.postResource("merchants/\(merchant)/orders/\(order)/payments?access_token=99c5fc42-9398-77e6-ce24-496597109789", parameters: ["tender" : ["id": "PDE158T96D396"], "amount": amount, "result": "SUCCESS", "order": ["id": order]], success: success, failure: failure)
    }
    
}