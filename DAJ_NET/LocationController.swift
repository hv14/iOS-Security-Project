//
//  LocationController.swift
//  DAJ_NET
//
//  Created by James Wegner on 4/14/16.
//  Copyright © 2016 James Wegner. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    var trackedLocations = NSMutableArray()
    let manager = CLLocationManager()
    var locationsData = String()

    func requestLocationAccess() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
            
        case .AuthorizedAlways:
            print("Location access authorized")
            manager.startUpdatingLocation()
            
        case .AuthorizedWhenInUse:
            print("Location access authorized when in use")
            manager.startUpdatingLocation()
            
        case .Denied:
            print("Location access denied")
            
        case .NotDetermined:
            print("Requesting location access")
            manager.requestAlwaysAuthorization()
            
        case.Restricted:
            print("Location access restricted")
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last != nil {
            let currentLocation = locations.last!
            trackedLocations.addObject(currentLocation)
            
            let currentDate = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            locationsData = locationsData.stringByAppendingString("\(dateFormatter.stringFromDate(currentDate)): \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)\n")
            saveLocationsFile()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location manager did fail: " + error.description)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            manager.startUpdatingLocation()
            print("Location services authorized")
            
        } else {
            print("Location services not authroized")
        }
    }
    
    // MARK: File management
    
    func saveLocationsFile() {
        let file = Constants.locationsFileName
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
            do {
                try locationsData.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
            } catch {
            }
        }
    }
}
