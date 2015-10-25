//
//  ProfileInputFormViewController.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/25/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import Eureka
import Parse

class ProfileInputFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TextRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .flatSkyBlueColor() }
        DateRow.defaultRowInitializer = { row in row.maximumDate = NSDate() }
        PhoneRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .flatSkyBlueColor() }
        
        let user = PFUser.currentUser()
        
        form =
            Section()
            <<< TextRow() {
                $0.title = "First Name"
                $0.placeholder = "First Name"
                $0.tag = "First_Name"
                $0.value = user?.valueForKey("firstName") as? String
            }
            
            <<< TextRow() {
                $0.title = "Middle Name"
                $0.placeholder = "Middle Name"
                $0.tag = "Middle_Name"
                $0.value = user?.valueForKey("middleName") as? String
            }

            <<< TextRow() {
                $0.title = "Last Name"
                $0.placeholder = "Last Name"
                $0.tag = "Last_Name"
                $0.value = user?.valueForKey("lastName") as? String
            }

            <<< PhoneRow() {
                $0.title = "Mobile"
                $0.placeholder = "(***) *** ****"
                $0.tag = "Mobile"
                if let mobile = user?.valueForKey("mobile") {
                    $0.value = "\(mobile)"
                }
            }
            
            <<< DateRow() { $0.value = NSDate(); $0.title = "Birth Date"; $0.tag = "Birth_Date";
                $0.value = user?.valueForKey("birthDate") as? NSDate}

            +++ Section()
            
            <<< TextAreaRow() {
                $0.title = "Address #1"
                $0.placeholder = "Address #1"
                $0.tag = "Address1"
                $0.value = user?.valueForKey("address1") as? String
            }

            <<< TextRow() {
                $0.title = "Address #2"
                $0.placeholder = "Address #2"
                $0.tag = "Address2"
                $0.value = user?.valueForKey("address2") as? String
            }

            <<< TextRow() {
                $0.title = "City"
                $0.placeholder = "City"
                $0.tag = "City"
                $0.value = user?.valueForKey("city") as? String
            }

            <<< TextRow() {
                $0.title = "State"
                $0.placeholder = "State"
                $0.tag = "address3"
                print(user?.valueForKey("address3"))
                $0.value = user?.valueForKey("address3") as? String
            }
            
            <<< TextRow() {
                $0.title = "Zip Code"
                $0.placeholder = ""
                $0.tag = "Zip_Code"
                $0.value = user?.valueForKey("zipCode") as? String
            }
    }
    @IBAction func saveProfileInfo(sender: AnyObject) {
        print(self.form.rowByTag("Last_Name")?.baseValue)
        
        guard let user = PFUser.currentUser() else {
            return
        }

        if let lastName = self.form.rowByTag("Last_Name")?.baseValue {
            user.setValue(lastName as! String, forKey: "lastName")
        }

        if let firstName = self.form.rowByTag("First_Name")?.baseValue {
            user.setValue(firstName as! String, forKey: "firstName")
        }

        if let middleName = self.form.rowByTag("Middle_Name")?.baseValue {
            user.setValue(middleName as! String, forKey: "middleName")
        }

        if let mobile = self.form.rowByTag("Mobile")?.baseValue {
            user.setValue(Int(mobile as! String), forKey: "mobile")
        }
        
        if let birthDate = self.form.rowByTag("Birth_Date")?.baseValue {
            user.setValue(birthDate as! NSDate, forKey: "birthDate")
        }
        
        if let address1 = self.form.rowByTag("Address1")?.baseValue {
            user.setValue(address1 as! String, forKey: "address1")
        }

        if let address2 = self.form.rowByTag("Address2")?.baseValue {
            user.setValue(address2 as! String, forKey: "address2")
        }
        
        if let city = self.form.rowByTag("City")?.baseValue {
            user.setValue(city as! String, forKey: "city")
        }
        
        if let state = self.form.rowByTag("address3")?.baseValue {
            user.setValue(state as! String, forKey: "address3")
        }

        if let zipCode = self.form.rowByTag("Zip_Code")?.baseValue {
            user.setValue(zipCode as! String, forKey: "zipCode")
        }

        user.saveInBackground()
    }
}