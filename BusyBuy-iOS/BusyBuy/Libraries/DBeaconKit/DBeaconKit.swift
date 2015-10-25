//
//  DBeaconKit.swift
//  Pods
//
//  Created by Prasad Pamidi on 9/16/15.
//
//

import Foundation
import CoreLocation

// MARK: -  DBeaconKitErrorDomain
enum DBeaconKitErrorDomain: ErrorType {
    case InitializationError(msg: String)
    case AuthorizationError(msg: String)
    case RegionMonitoringError(msg: String)
    case InvalidUUIDString
    case InvalidDBeaconInfo
}

// MARK: -  DBeaconKitProtocol
protocol DBeaconKitProtocol:class {
    func initializationFailed(error: NSError)
    func entered(dbeacon:  DBeacon)
    func exited(dbeacon: DBeacon)
    func rangingComplete(dbeacons: [DBeacon])
    func monitoringFailedForRegion(dbeacon: DBeacon, error: NSError)
    func rangingFailed(dbeacon: DBeacon, error: NSError)
}

// MARK: - DBeaconProtocol
protocol DBeaconProtocol: CustomStringConvertible, CustomDebugStringConvertible {
    var uuid: String {get set}
    var major: Int? {get set}
    var minor: Int? {get set}
    var identifier: String {get set}
}

// MARK: - Extension to DBeaconProtocol
extension DBeaconProtocol  {
    var description: String {
        return "UUID: \(uuid) - identifier: \(identifier) - Major: \(major) - Minor: \(minor)"
    }
    
    var debugDescription: String {
        return "UUID: \(uuid) - identifier: \(identifier) - Major: \(major) - Minor: \(minor)"
    }
}

// MARK: - DBeacon structure
class DBeacon: NSObject, NSCoding, DBeaconProtocol  {
    var uuid: String
    var major: Int?
    var minor: Int?
    var identifier: String
    
    init (uuid: String, identifier: String, major: Int?, minor: Int?) {
        self.uuid = uuid
        
        if let amajor = major {
            self.major = amajor
        }
        
        if let aminor = minor {
            self.minor = aminor
        }
        
        self.identifier = identifier
    }
    
    override var hashValue: Int { return "\(self.identifier)".hashValue }
    
    required init?(coder aDecoder: NSCoder) {
        self.uuid = aDecoder.decodeObjectForKey("uuid") as! String
        self.major = aDecoder.decodeObjectForKey("major") as? Int
        self.minor = aDecoder.decodeObjectForKey("minor") as? Int
        self.identifier = aDecoder.decodeObjectForKey("identifier") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.uuid, forKey: "uuid")
        aCoder.encodeObject(self.major, forKey: "major")
        aCoder.encodeObject(self.minor, forKey: "minor")
        aCoder.encodeObject(self.identifier, forKey: "identifier")
    }
}

// MARK: - DBeacon extenstion for equatable  protocol
func == (lhs: DBeacon, rhs: DBeacon) -> Bool {
    return lhs.uuid == rhs.uuid && lhs.identifier == rhs.identifier
}

// MARK: - DBeaconKitManager
@available(iOS 9.0, *)
class DBeaconKitManager: NSObject, CLLocationManagerDelegate {
    private var manager: CLLocationManager
    
    private var lastDetection: NSDate? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.valueForKey("lastDetection") as? NSDate
        }
        
        set(newValue) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: "lastDetection")
            userDefaults.synchronize()
        }
    }

    private var isMonitoring: Bool {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.boolForKey("isMonitoring")
        }
        
        set(newValue) {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(newValue, forKey: "isMonitoring")
            userDefaults.synchronize()
        }
    }
    
    private var repository: [String: DBeacon] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("repository") as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: DBeacon]
            }
            
            return [:]
        }
        
        set(newValue) {
            guard newValue.count > 0 else {
                return
            }
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "repository")
            userDefaults.synchronize()
        }
    }
    
    private var monitoredRegions: [String: DBeacon] {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("monitoredRegions") as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [String: DBeacon]
            }
            
            return [:]
        }
        
        set(newValue) {
            guard newValue.count > 0 else {
                return
            }
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "monitoredRegions")
            userDefaults.synchronize()
        }
    }
    
    private var notifyBackground = true
    static let sharedManager = DBeaconKitManager()
    
    weak var delegate:DBeaconKitProtocol? {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey("delegate") as? NSData {
                return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? DBeaconKitProtocol
            }
            
            return nil
        }
        
        set(newValue) {
            let data = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "delegate")
            userDefaults.synchronize()
        }
    }
    
    private override init() {
        manager = CLLocationManager()
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        
        super.init()
        manager.delegate = self
        isMonitoring = false
        repository =  [:]
        monitoredRegions = [:]
    }
    
    func startMonitoringForDBeacons(dbeacons: [DBeacon]) throws {
        try dbeacons.forEach { (dbeacon) -> () in
            try startMonitoringForDBeacon(dbeacon)
        }
    }
    
    func startMonitoringForDBeacon(dbeacon: DBeacon) throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw DBeaconKitErrorDomain.AuthorizationError(msg: "Location services not enabled")
        }
        
        guard CLLocationManager.authorizationStatus() == .AuthorizedAlways else {
            switch CLLocationManager.authorizationStatus() {
            case .Denied:
                throw DBeaconKitErrorDomain.AuthorizationError(msg: "User denied location services")
            case .Restricted:
                throw DBeaconKitErrorDomain.AuthorizationError(msg: "App is prevented from accessing Location Services")
            default:
                throw DBeaconKitErrorDomain.AuthorizationError(msg: "App doesn't have authorization to monitor regions")
            }
        }
        
        guard CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) else {
            throw DBeaconKitErrorDomain.RegionMonitoringError(msg: "Region monitoring not available on this device")
        }
        
        guard let auuid = NSUUID(UUIDString: dbeacon.uuid) else {
            throw DBeaconKitErrorDomain.InvalidUUIDString
        }
        
        let region:CLBeaconRegion!
        
        switch (dbeacon.major, dbeacon.minor) {
            case (.None, .None):
                region = CLBeaconRegion(proximityUUID: auuid, identifier: dbeacon.identifier)
            case (.Some(let major), .None):
                region = CLBeaconRegion(proximityUUID: auuid, major: UInt16(major), identifier: dbeacon.identifier)
            case (.Some(let major), .Some(let minor)):
                region = CLBeaconRegion(proximityUUID: auuid, major: UInt16(major), minor: UInt16(minor), identifier: dbeacon.identifier)
            default:
                throw DBeaconKitErrorDomain.InvalidDBeaconInfo
        }
        
        region.notifyEntryStateOnDisplay = false
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        repository[dbeacon.identifier] = dbeacon
        manager.startMonitoringForRegion(region)
    }
    
    func isMonitoringDBeacon(dbeacon: DBeacon) -> Bool {
        guard isMonitoring else {
            return false
        }
        
        return (monitoredRegions[dbeacon.identifier] != nil)
    }
    
    func monitoring() -> Bool {
        return isMonitoring
    }
    
    func stopMonitoringForDBeacons(dbeacons: [DBeacon]) {
        guard isMonitoring else {
            return
        }
        
        dbeacons.forEach { (dbeacon) -> () in
            stopMonitoringForDBeacon(dbeacon)
        }
    }
    
    func stopMonitoringForDBeacon(dbeacon: DBeacon) {
        guard isMonitoring, let _ = monitoredRegions[dbeacon.identifier], region = manager.monitoredRegions.filter({$0.identifier == dbeacon.identifier}).first else {
            return
        }
        
        manager.stopMonitoringForRegion(region)
        monitoredRegions[dbeacon.identifier] = nil
    }
    
    func stopMonitoring() {
        guard isMonitoring && monitoredRegions.count > 0 else {
            return
        }
        
        stopMonitoringForDBeacons(Array(monitoredRegions.values))
    }
    
    // MARK: - CoreLocation, CLBeacon delegate methods
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == .AuthorizedAlways {
                //do nothing
            } else if status == .AuthorizedWhenInUse {
                //alert user
                showLocationAccessRequestAlert()
                print("User granted only when in use authorization")
            } else if status == .Denied {
                //alert user
                showLocationAccessRequestAlert()
                print("User denied location access")
            }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        guard let handler = delegate else {
            return
        }
        
        handler.initializationFailed(error)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        guard let aregion = region as? CLBeaconRegion, dbeacon = repository[aregion.identifier] else {
            return
        }
        
        isMonitoring = true
        monitoredRegions[aregion.identifier] = dbeacon
        manager.requestStateForRegion(region)
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        guard let aregion = region as? CLBeaconRegion, dbeacon = repository[aregion.identifier], handler = delegate else {
            return
        }
        
        handler.monitoringFailedForRegion(dbeacon, error: error)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let aregion = region as? CLBeaconRegion else {
            return
        }
        
        guard let dbeacon = monitoredRegions[aregion.identifier] else {
            return
        }
        
        guard let handler = delegate else {
            return
        }
        
        handler.entered(dbeacon)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let aregion = region as? CLBeaconRegion, dbeacon = monitoredRegions[aregion.identifier], handler = delegate else {
            return
        }
        
        handler.exited(dbeacon)
    }

    required init?(coder aDecoder: NSCoder) {
        self.manager = aDecoder.decodeObjectForKey("manager") as! CLLocationManager
        super.init()
        
        self.lastDetection = aDecoder.decodeObjectForKey("lastDetection") as? NSDate
        self.isMonitoring = aDecoder.decodeBoolForKey("isMonitoring")
        self.repository = aDecoder.decodeObjectForKey("repository") as! [String: DBeacon]
        self.monitoredRegions = aDecoder.decodeObjectForKey("monitoredRegions") as! [String: DBeacon]
        self.delegate = aDecoder.decodeObjectForKey("delegate") as? DBeaconKitProtocol
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.lastDetection, forKey: "lastDetection")
        aCoder.encodeBool(self.isMonitoring, forKey: "isMonitoring")
        aCoder.encodeObject(self.repository, forKey: "repository")
        aCoder.encodeObject(self.monitoredRegions, forKey: "monitoredRegions")
        aCoder.encodeObject(self.delegate, forKey: "delegate")
        aCoder.encodeObject(self.manager, forKey: "manager")
    }
    
    deinit {
    }
}

// MARK: - Extension for Double to allow comparisions between them
extension Double {
    func compare(aValue: Double) -> NSComparisonResult {
        var result = NSComparisonResult.OrderedSame
        if self > aValue {
            result = NSComparisonResult.OrderedAscending
        } else if self < aValue {
            result = NSComparisonResult.OrderedDescending
        } else if self == aValue {
            result = NSComparisonResult.OrderedSame
        }
        
        return result
    }
}

// MARK: - Extension for CLBeacon to allow comparision
extension CLBeacon {
    func compareByDistanceWith(beacon: CLBeacon) -> NSComparisonResult {
        var result = NSComparisonResult.OrderedSame
        if beacon.proximity == .Unknown && self.proximity != .Unknown{
            result = NSComparisonResult.OrderedAscending
        } else if self.proximity.rawValue > beacon.proximity.rawValue {
            result = NSComparisonResult.OrderedDescending
        }else if self.proximity == beacon.proximity {
            if self.accuracy < 0 && beacon.accuracy > 0 {
                result =  NSComparisonResult.OrderedDescending
            } else if self.accuracy > 0 && beacon.accuracy < 0 {
                result = NSComparisonResult.OrderedAscending
            }else {
                result =  self.accuracy.compare(beacon.accuracy)
            }
        }
        
        return result
    }
    
    func dBeacon() -> DBeacon {
        return DBeacon(uuid: proximityUUID.UUIDString,identifier: "\(proximityUUID.UUIDString)", major: major.integerValue, minor: minor.integerValue)
    }
}

// MARK: -  Extension for CLBeaconRegion
extension CLBeaconRegion {
    func dBeaconInfo() -> DBeacon {
        return DBeacon(uuid: proximityUUID.UUIDString, identifier: identifier, major: major?.integerValue, minor: minor?.integerValue)
    }
}