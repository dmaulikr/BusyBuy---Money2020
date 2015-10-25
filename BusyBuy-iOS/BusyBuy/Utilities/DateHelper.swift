//
//  DateHelper.swift
//  
//
//  Created by Prasad Pamidi on 2/11/15.
//

import Foundation

// MARK: - String custom extension for date
public extension String {
    // MARK - Parse into NSDate
    func dateFromFormat(format: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(self)
    }
}

// MARK: - NSDate custom extension
extension NSDate: Comparable {}

public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public extension NSDate {
    func stringFromFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

class DateHelper {
    class func dateFromStringFormat1(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("MM/dd/yyyy HH:mm")
    }
    
    class func dateFromStringFormat2(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
    }
    
    class func dateFromStringFormat3(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("yyyy-MM-dd")
    }
    
    class func dateFromStringFormat4(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }
    
    class func dateFromStringFormat5(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("MM/dd/yyyy")
    }
    
    class func stringFromDateFormat1(date: NSDate) -> String? {
        return date.stringFromFormat("MM/dd/yyyy")
    }
    
    class func stringFromDateFormat2(date: NSDate) -> String? {
        return date.stringFromFormat("yyyy-MM-dd HH:mm")
    }
    
    class func stringFromDateFormat3(date: NSDate) -> String? {
        return date.stringFromFormat("yyyy-MM-dd")
    }
    
    class func stringFromDateFormat4(date: NSDate) -> String? {
        return date.stringFromFormat("yyyy-MM-dd HH:mm:ss.SSS")
    }
    
    class func stringFromDateFormat5(date: NSDate) -> String? {
        return date.stringFromFormat("yyyy-MM-dd'T'HH:mm:ss")
    }
    
    class func timeStringWithMinsFromDate(date: NSDate) -> String? {
        return date.stringFromFormat("HH:mm")
    }
    
    class func timeStringWithSecondsFromDate(date: NSDate) -> String? {
        return date.stringFromFormat( "HH:mm:ss")
    }
    
    class func timeStringWithMilliSecondsFromDate(date: NSDate) -> String? {
        return date.stringFromFormat("HH:mm:ss.SSS")
    }
    
    class func dateFromTimeStringWithMilliSeconds(dateString: String) -> NSDate? {
        return dateString.dateFromFormat("HH:mm:ss.SSS")
    }
    
    
    class func isFirstOneOld(date1: NSDate, date2: NSDate) -> Bool {
        return date1 <= date2
    }
}