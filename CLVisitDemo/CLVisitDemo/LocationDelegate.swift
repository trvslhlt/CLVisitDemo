//
//  LocationManager.swift
//  CLVisitDemo
//
//  Created by trvslhlt on 2/24/15.
//  Copyright (c) 2015 travis holt. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
  
  class var locationDatafilepath: String { return "locationData.plist" }
  class var locationDataUpdatedNotification: String { return "locationDataUpdated" }
  let visitsKey = "visits"
  let locationsKey = "significantLocationChanges"
  let manualLoggingLocationKey = "manualLoggingLocation"
  let distanceFilterForSignificantChanges: CLLocationDistance = 50
  
  let pastControlDate = NSDate.distantPast() as NSDate
  let futureControlDate = NSDate.distantFuture() as NSDate
  var locationDataFilepath: String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    let filepath = documentsPath.stringByAppendingPathComponent(LocationDelegate.locationDatafilepath)
    let fileManager = NSFileManager.defaultManager()
    if !fileManager.fileExistsAtPath(filepath) {
      let locationData: NSDictionary = [self.visitsKey: NSArray(), self.locationsKey: NSArray(), self.manualLoggingLocationKey: NSArray()]
      locationData.writeToFile(filepath, atomically: true)
    }
    return filepath
  }
  
  lazy private var locationManager: CLLocationManager = {
    let lm = CLLocationManager()
    lm.delegate = self
    return lm
    }()
  
  class var sharedInstance: LocationDelegate {
    struct Static {
      static let instance: LocationDelegate = LocationDelegate()
    }
    Static.instance.locationManager.requestAlwaysAuthorization()
    return Static.instance
  }
  
  func monitorVisits(monitor: Bool) {
    if monitor {
      locationManager.startMonitoringVisits()
    } else {
      locationManager.stopMonitoringVisits()
    }
  }
  
  func monitorSignificantLocationChanges(monitor: Bool) {
    if CLLocationManager.significantLocationChangeMonitoringAvailable() {
      if monitor {
        locationManager.distanceFilter = distanceFilterForSignificantChanges
        locationManager.startMonitoringSignificantLocationChanges()
      } else {
        locationManager.stopMonitoringSignificantLocationChanges()
      }
    }
  }
  
  // MARK: CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let locs = locations as? [CLLocation] {
      var locationDictionaries = NSMutableArray()
      for location in locs {
        let locationDictionary = [
          "timestamp": location.timestamp,
          "latitude": NSNumber(double: location.coordinate.latitude),
          "longitude": NSNumber(double: location.coordinate.longitude),
          "horizontalAccuracy": NSNumber(double: location.horizontalAccuracy)
        ]
        locationDictionaries.addObject(locationDictionary)
      }
      appendObjectsToArrayWithKey(locationsKey, objects: locationDictionaries)
    }
  }
  
  func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
    if let v = visit {
      let arrivalDate = v.arrivalDate ?? pastControlDate
      let departureDate = v.departureDate ?? futureControlDate
      let coordinate = v.coordinate
      let horizontalAccuracy = v.horizontalAccuracy
      
      let newVisit: NSDictionary = [
        "arrivaleDate": arrivalDate,
        "departureDate": departureDate,
        "latitude": NSNumber(double: coordinate.latitude),
        "longitude": NSNumber(double: coordinate.longitude),
        "horizontalAccuracy": NSNumber(double: horizontalAccuracy)
      ]
      appendObjectsToArrayWithKey(visitsKey, objects: [newVisit])
      showNotification("\(newVisit)")
    }
  }
  
  func manuallyLogCurrentLocation(#arriving: Bool) {
    let status = arriving ? "arriving" : "departing"
    if let currentLocation = locationManager.location {
      let latitude = currentLocation.coordinate.latitude
      let longitude = currentLocation.coordinate.longitude
      let timestamp = currentLocation.timestamp
      let horizontalAccuracy = currentLocation.horizontalAccuracy
      let newLog: NSDictionary = [
        "status": status,
        "latitude": NSNumber(double: latitude),
        "longitude": NSNumber(double: longitude),
        "timestamp": timestamp,
        "horizontalAccuracy": NSNumber(double: horizontalAccuracy)
      ]
      appendObjectsToArrayWithKey(manualLoggingLocationKey, objects: [newLog])
    }
  }
  
  func appendObjectsToArrayWithKey(key: String, objects: [AnyObject]) {
    if !NSFileManager.defaultManager().fileExistsAtPath(locationDataFilepath) { return }
    if let oldPlistDictionary = NSDictionary(contentsOfFile: locationDataFilepath) {
      let newPlistDictionary: NSMutableDictionary = NSMutableDictionary(dictionary: oldPlistDictionary)
      if let arrayForKey = oldPlistDictionary.objectForKey(key) as? NSArray {
        let newArrayForKey = NSMutableArray(array: arrayForKey)
        for object in objects {
          newArrayForKey.addObject(object)
        }
        newPlistDictionary.setObject(newArrayForKey, forKey: key)
        newPlistDictionary.writeToFile(locationDataFilepath, atomically: true)
        NSNotificationCenter.defaultCenter().postNotificationName(LocationDelegate.locationDataUpdatedNotification, object: nil, userInfo: nil)
      }
    }
  }
  
  func locationDataToString() -> String {
    if !NSFileManager.defaultManager().fileExistsAtPath(locationDataFilepath) { return "no data available" }
    if let oldPlistDictionary = NSDictionary(contentsOfFile: locationDataFilepath) {
      return "\(oldPlistDictionary)"
    }
    return "no data available"
  }
  
  // MARK: UserNotifications
  func showNotification(body: String) {
    let notification = UILocalNotification()
    notification.alertAction = "alertAction"
    notification.alertBody = body
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }
  
}


















