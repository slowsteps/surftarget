import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var tracker = Tracker()
    @StateObject var motor = Motor ()
    @State private var msgfornano: String = "1"
    
    var body: some View {
        
        VStack {
            
            
            Group {
                Text("True north")
                Text(tracker.trueNorth.debugDescription).padding()
                Button("ask for location permission") {
                    tracker.requestPermission()
                }
            }
            
            Group {
            
                Text("Bluetooth devices")
                
                Text(motor.bleDevices)

                Button("ask for bluetooth permission") {
                    motor.startBluetooth()
                }
    
                Text("Turndegrees").padding()
                Text(motor.turnDegrees.description)
                
                Button("Send msg to nano") {
                    motor.sendStringtoNano()
                }.padding()
        
                Button("Send location to server") {
                    tracker.sendLocationToServerJSON()
                }.padding()

                Button("Get location from server") {
                    tracker.getLocationFromServer()
                }.padding()

                Text(tracker.serverResult).padding().fixedSize(horizontal: false, vertical: true).font(.system(size: 16)).textSelection(.enabled)
                
                Text(motor.locationNames[motor.curlocation]).padding()
                
            }
   
         }
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    
}


