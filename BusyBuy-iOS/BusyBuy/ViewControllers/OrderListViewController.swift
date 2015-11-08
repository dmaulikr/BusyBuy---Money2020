//
//  OrderListViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/25/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import PassKit
import Parse

protocol NotificationReceiverDelegate: class {
    func notificationReceivedWith(payload: [NSObject: AnyObject])
}

class OrderListViewController: UIViewController, NotificationReceiverDelegate {
    private let table_cell_identifier = "order_list_cell"
    @IBOutlet weak var tableView: UITableView!
    
    let paymentProcessor = FDInAppPaymentProcessor(apiKey: Configuration.getPayeegyAPIKey(), apiSecret: Configuration.getPayeegyAPISecret(), merchantToken: Configuration.getPayeegyMerchantToken(), merchantIdentifier: Configuration.getApplePayMerchantID(), environment: "CERT")
    
    var transactions: [Transaction] = []
    
    
    var selectedTransactionIdx: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        paymentProcessor.paymentMode = FDPurchase

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsListener = self
    }
    
    deinit {
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationsListener = .None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    @IBAction func logOutUser(sender: AnyObject) {
        PFUser.logOutInBackground()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func notificationReceivedWith(payload: [NSObject : AnyObject]) {
        let transaction = Transaction(payload: payload)
        print(payload)
        if transactions.contains(transaction) {
            let actual = transactions.filter({$0 == transaction}).first
            
            if let status = TransactionStatusType(rawValue: payload["status"] as! String), order = payload["order_id"] as? String {
                actual?.amount = 9000.0
                actual?.orderId = order
                actual?.transactionStatus = status
            }
        } else {
            transaction.transactionStatus = TransactionStatusType(rawValue: payload["status"] as! String)!
            transaction.amount = 0.0
            transactions.append(transaction)
        }
        
        transactions.sortInPlace({$0.lastTransactionUpdate > $1.lastTransactionUpdate})
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
}

extension OrderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCellWithIdentifier(table_cell_identifier, forIndexPath: indexPath) as! MerchantTransactionCell
        
        let transaction = transactions[indexPath.row]
        
        cell.lbl_merchantName.text = transaction.merchantName
        cell.lbl_transactionDetails.text = DateHelper.stringFromDateFormat2(transaction.lastTransactionUpdate)
        cell.imgVw_transactionStatus.image = transaction.transactionStatus.imageObj()
        cell.lbl_transaction_status.text = transaction.transactionStatus.statusMessage()
        
        cell.lbl_transactionAmnt.text = "$90.00"
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if transactions[indexPath.row].checkIfPaymentRequested() {
            let paymentAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Pay" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.selectedTransactionIdx = indexPath.row
                self.tableView.editing = false
                self.makePayment()
                return
            })
            
            paymentAction.backgroundColor = UIColor.blueColor()
            
            let cancelAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Cancel" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                
                self.tableView.editing = false
                return
            })
            
            paymentAction.backgroundColor = UIColor.blueColor()

            return [cancelAction, paymentAction]
        }
        
        return []
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Doing nothing
    }
}

extension OrderListViewController: FDPaymentAuthorizationViewControllerDelegate {
    func makePayment() {
        guard let row = selectedTransactionIdx where FDInAppPaymentProcessor.canMakePayments() && FDInAppPaymentProcessor.canMakePaymentsUsingNetworks(PaymentNetworks.availablePaymentNetworks()) else {
            return
        }
        
        let request = FDPaymentRequest()
        let transaction = transactions[row]
        
        request.merchantIdentifier = Configuration.getApplePayMerchantID()
        request.supportedNetworks = PaymentNetworks.availablePaymentNetworks()
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.merchantCapabilities = FDMerchantCapability3DS
        request.requiredBillingAddressFields = .All
        request.requiredShippingAddressFields = .None
        
        request.applicationData = "Merchant Id: \(transaction.merchantId) Order Id: \(transaction.orderId!)".dataUsingEncoding(NSUTF8StringEncoding)
        request.merchantRef = transaction.merchantName
        
        let item = FDPaymentSummaryItem()
        item.label = transaction.merchantName
        item.amount = 90
        
        request.paymentSummaryItems = [item]
        
        guard paymentProcessor.presentPaymentAuthorizationViewControllerWithPaymentRequest(request, presentingController: self, delegate: self) else {
            print("Unable to launch apple pay")
            return
        }
    }
    
    func paymentAuthorizationViewController(controller: UIViewController!, didAuthorizePayment payment: FDPaymentResponse!) {
        print(payment)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: UIViewController!) {
        print("Authorization View Controller loaded")
        guard let row = selectedTransactionIdx else {
            return
        }

        let transaction = transactions[row]
        transaction.transactionStatus = .Approved
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
        
        HTTPManager.informPurchaseConfirmationTo(transaction.merchantId, order: transaction.orderId!, amount: transaction.amount ?? 0.0, success: {[weak self] (responseObject) -> () in
            print(responseObject)
            transaction.transactionStatus = .Approved
            self?.selectedTransactionIdx = .None
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self?.tableView.reloadData()
            }
        }) {[weak self] (responseError) -> () in
            print(responseError)
            self?.selectedTransactionIdx = .None

        }
    }
    
    func paymentAuthorizationViewController(viewcontroller: UIViewController!, didSelectShippingAddress: ABRecord!) {
        print("not implemented")
    }
    
    func paymentAuthorizationViewController(controller: UIViewController!, didSelectShippingMethod shippingMethod: FDShippingMethod!) {
        print("not implemented")
    }
}