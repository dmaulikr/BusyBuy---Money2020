//
//  Transaction.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/25/15.
//  Copyright © 2015 Self. All rights reserved.
//

import Foundation

enum TransactionStatusType: String {
    case Created = "created"
    case PaymentRequested = "paymentRequested"
    case Approved
    case Cancelled
    case Unknown
    
    func imageObj() -> UIImage? {
        switch self {
        case .Created:
            return UIImage(named: "Pending")
        case .PaymentRequested:
            return UIImage(named: "Attention")
        case .Approved:
            return UIImage(named: "Approved")
        case .Cancelled:
            return UIImage(named: "Cancelled")
        case .Unknown:
            return UIImage(named: "Unknown")
        }
    }
    
    func statusMessage() -> String {
        switch self {
        case .Created:
            return "Processing request"
        case .PaymentRequested:
            return "Payment Required"
        case .Approved:
            return "Request Complete."
        case .Cancelled:
            return "Request cancelled"
        case .Unknown:
            return "Unknown issue occured"
        }
    }
}

class Transaction {
    let merchantId: String
    var orderId: String?
    let merchantName: String
    var lastTransactionUpdate: NSDate
    var transactionStatus: TransactionStatusType
    var amount: Double?
    
    init(id: String, name: String, status: String, order: String) {
        self.merchantId = id
        self.merchantName = name
        self.transactionStatus = .Created
        self.lastTransactionUpdate = NSDate()
        self.orderId = order
    }
    
    func updateStatus(toStatus: TransactionStatusType) {
        self.transactionStatus = toStatus
        self.lastTransactionUpdate = NSDate()
    }
    
    func addAmount(amount: Double) {
        self.amount = amount
        self.lastTransactionUpdate = NSDate()
    }
    
    func checkIfPaymentRequested() -> Bool {
        if self.transactionStatus == .PaymentRequested {
            return true
        }
        
        return false
    }
    
    convenience init(payload: [NSObject: AnyObject]) {
        self.init(id: payload["merchant_id"] as! String, name: payload["merchant_name"] as! String, status: payload["status"] as! String, order: payload["order_id"] as? String ?? "")
    }
}

extension Transaction: Equatable {}

func == (lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.merchantId == rhs.merchantId
}