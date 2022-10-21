//
//  File.swift
//  tuto
//
//  Created by Peter Squla on 02/09/2022.
// get the sensor data (heading, GPS)

import Foundation
import CoreLocation
import SwiftUI
import MapKit



class Tracker : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    @Published var counter = 1.0
    @Published var magneticHeading = 0.0
    @Published var trueNorth = 0.0
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var speed = 0.0
    @Published var course = 0.0
    @Published var serverResult = "no server result"
    private let locationManager : CLLocationManager
    public var myMotor : Motor?
    private var shareLocationTimer : Timer
    private var getLocationTimer : Timer
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    override init() {
        
        locationManager = CLLocationManager()
        shareLocationTimer = Timer()
        getLocationTimer = Timer()
        super.init()
        locationManager.delegate = self

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = locations.first?.coordinate.latitude ?? 0
        longitude = locations.first?.coordinate.longitude ?? 0
        speed = locations.first?.speed ?? 0
        course = locations.first?.course ?? 0
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
    
    func toggleLocationSending( _ isSurfer : Bool) {
        if (isSurfer) {
            shareLocationTimer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendLocationToServerJSON),userInfo: nil, repeats: true)
        }
        else {
            shareLocationTimer.invalidate()
        }
    }
    
    func toggleLocationGetting( _ isCamera : Bool) {
        if (isCamera) {
            getLocationTimer  = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getLocationFromServer),userInfo: nil, repeats: true)
        }
        else {
            shareLocationTimer.invalidate()
        }
    }
    
    @objc func sendLocationToServerJSON() {
        
        let timesend = NSDate().timeIntervalSince1970
        let parameters: [String: Any] = ["longitude": longitude, "latitude": latitude,"speed":speed,"course":course,"timesend":timesend]
        let url = URL(string: "https://surftracker-365018.ew.r.appspot.com/setlocation")! 

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
          
          do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
          } catch let error {
              print(error.localizedDescription)
            return
          }

        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
              print("Post Request Error: \(error.localizedDescription)")
              return
            }
            
            // ensure there is valid response code returned from this HTTP response
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode)
//            else {
//              print("Invalid Response received from the server")
//              return
//            }
            
            // ensure there is data returned
//            guard let responseData = data else {
//              print("nil Data received from the server")
//              return
//            }
//
//            do {
//              // create json object from data or use JSONDecoder to convert to Model stuct
//              if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
//                print(jsonResponse)
//                // handle json response
//              } else {
//                print("data maybe corrupted or in wrong format")
//                throw URLError(.badServerResponse)
//              }
//            } catch let error {
//              print(error.localizedDescription)
//            }
          }
          // perform the task
          task.resume()
        
        
        
    }
    
    @objc func getLocationFromServer() {
        let url = URL(string: "https://surftracker-365018.ew.r.appspot.com/getlocation")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let obj = json as? [String: Any] {
                    print(obj["longitude"]!)
                    let long = obj["longitude"] as! CLLocationDegrees
                    let lat = obj["latitude"] as! CLLocationDegrees
                    self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
                    
                }
            }
            catch {
                print(error.localizedDescription)
            }


            guard let data = data else { return }
            let result = (String(data: data, encoding: .utf8)!)
            

            
            //queue needs to be done otherwise vieuw does not pickup the binding serverresult
            DispatchQueue.main.async {
                self.serverResult = result


                
            }
            

        }

        task.resume()
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    
    
}

