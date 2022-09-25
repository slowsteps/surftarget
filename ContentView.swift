import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var tracker = Tracker()
    @StateObject var motor = Motor ()
    @State private var msgfornano: String = "1"
    
    var body: some View {
        VStack {
            
            
            Group {
                Text("Magnetic Heading").padding()
                Text(tracker.magneticHeading.debugDescription)
                Text("Latitude").padding()
                Text(tracker.latitude)
                Button("ask for location permission") {
                    tracker.requestPermission()
                }
                Button("get location") {
                    tracker.getLocation()
                }
            }
            
            Group {
            
                Text("Bluetooth devices").padding()
                
                Text(motor.bleDevices).padding()

                Button("ask for bluetooth permission") {
                    motor.startBluetooth()
                }
    
        
                Button("Send msg to nano") {
                    motor.sendStringtoNano()
                }.padding()
        
                
                TextField("Enter your name", text: $msgfornano).multilineTextAlignment(.center)
                
                
                
            }

            
            
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    
}


