//
//  File.swift
//  tuto
//
//  Created by Peter Squla on 02/09/2022.
//

import Foundation
import CoreLocation
import SwiftUI

class Tracker : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    @Published var counter = 1.0
    @Published var magneticHeading = 0.0
    @Published var trueNorth = 0.0
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    private let locationManager : CLLocationManager
    public var myMotor : Motor?
    
    override init() {
        
        
        locationManager = CLLocationManager()
        
        super.init()
        locationManager.delegate = self
        
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = locations.first?.coordinate.latitude ?? 0
        longitude = locations.first?.coordinate.longitude ?? 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        magneticHeading = newHeading.magneticHeading
        trueNorth = newHeading.trueHeading
    }
    
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager : CLLocationManager ) {
        
        //print("status changed - authorisationStatus:  \(manager.authorizationStatus) " )
        if (manager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse) {
            print("authorized")
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
        }
    }
    
}

