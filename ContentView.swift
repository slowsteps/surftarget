import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @StateObject var tracker = Tracker()
    @StateObject var motor = Motor ()
    @State private var msgfornano: String = "1"
    @State private var isSurfer = false
    @State private var isCamera = false
    
    
    var body: some View {
        
        VStack{
            
            
            Group {
                HStack {
                    Text("True north:")
                    Text(tracker.trueNorth.debugDescription)
                }
                Button("ask for location permission") {
                    tracker.requestPermission()
                }
            }
            
            Group {
                
                HStack {
                    Text("Bluetooth device:")
                    Text(motor.bleDevices)
                }

                Button("ask for bluetooth permission") {
                    motor.startBluetooth()
                }
                HStack {
                    Text("Turndegrees:")
                    Text(motor.turnDegrees.description)
                }
                Link("API", destination: URL(string: "https://surftracker-365018.ew.r.appspot.com/")!)
            }
            Group {
                
                Button("Send msg to nano") {
                    motor.sendStringtoNano()
                }.padding()
        
                Toggle("share location",isOn: $isSurfer).padding().onChange(of: isSurfer) { newValue in
                    tracker.toggleLocationSending(newValue)
                }.onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                
//                if isSurfer {
//                    ProgressView()
//                }

                Toggle("get location",isOn: $isCamera).padding().onChange(of: isCamera) { newValue in
                    tracker.toggleLocationGetting(newValue)
                }.onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                    
                
                
                Map(coordinateRegion:$tracker.region).frame(width:400,height:200)
              
                if isCamera {
                    Text(tracker.serverResult).padding().fixedSize(horizontal: false, vertical: true).font(.system(size: 16)).textSelection(.enabled)
                }
                
                Text(motor.locationNames[motor.curlocation]).padding()
                
            }
   
         }
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    
}


