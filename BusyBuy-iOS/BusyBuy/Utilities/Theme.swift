//
//  Theme.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/25/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit
import ChameleonFramework

struct Theme {
    
    static let sharedTheme = Theme()
    
    func setUpMainTheme() {
        UITabBar.appearance().tintColor = UIColor.mainColor()
        UITabBar.appearance().selectedImageTintColor = UIColor.mainColor()

        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.fontColor()]
    }
}

