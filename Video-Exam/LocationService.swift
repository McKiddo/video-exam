//
//  LocationService.swift
//  Video-Exam
//
//  Created by Coffee Bean on 22.04.2022.
//

import Foundation
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate{
    
    public static var sharedInstance = LocationService()
    let locationManager: CLLocationManager
    
    let horizontalAccuracyThreshhold = 100
    
    override init() {
        locationManager = CLLocationManager()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        super.init()
        locationManager.delegate = self
    }
    
    func startUpdatingLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    //MARK: CLLocationManagerDelegate protocol methods
    public func locationManager(_ manager: CLLocationManager,
                                  didUpdateLocations locations: [CLLocation]) {
        
        if let currentLocation = locations.last {
            if filter(currentLocation) {
                print("(\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.latitude))")
                notifiyDidUpdateLocation()
            }
        }
    }
    
    func filter(_ location: CLLocation) -> Bool{
            let age = -location.timestamp.timeIntervalSinceNow
            
            if age > 10 {
                print("Locaiton too old.")
                return false
            }
            
            if location.horizontalAccuracy < 0 {
                print("Latitidue and longitude values are invalid.")
                return false
            }
            
            if location.horizontalAccuracy > horizontalAccuracyThreshhold {
                print("Location not accurate enough.")
                return false
            }
            
            return true
        }
    
    public func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            startUpdatingLocation()
        }
    }
    
    func notifiyDidUpdateLocation(){
        NotificationCenter.default.post(name: Notification.Name(rawValue:"didUpdateLocation"), object: nil)
    }
}
