//
//  StoryBoard+Extensions.swift
//  BusyBuy
//
//  Created by Prasad Pamidi on 10/24/15.
//  Copyright © 2015 Self. All rights reserved.
//

import UIKit

enum SegueIdentifier:String {
    case LogInViewSegue
    case SignUpViewSegue
    case HomeViewSegue
    case NotificationAccessViewSegue
    case LocationAccessViewSegue
    case LogOutViewSegue
    case ProfileViewSegue
}

extension UIViewController {
    func performSegueWithIdentifier(identifier: SegueIdentifier, sender: AnyObject?) {
        self.performSegueWithIdentifier(identifier.rawValue, sender: self)
    }
}

enum StoryboardNames : String {
    case Main = "Main"
    case LauncScreen = "LaunchScreen"
}

enum ViewControllerStoryboardIdentifier : String {
    case ProfileViewController
}

extension UIStoryboard {
    class func main() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Main.rawValue, bundle: nil)
    }
    
    class func launchScreen() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.LauncScreen.rawValue, bundle: nil)
    }
    
    func viewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue)
    }
    
    func tableViewControllerWithID(identifier:ViewControllerStoryboardIdentifier) -> UITableViewController? {
        return self.instantiateViewControllerWithIdentifier(identifier.rawValue) as? UITableViewController
    }
}

