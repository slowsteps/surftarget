//
//  File.swift
//  tuto
//
//  Created by Peter Squla on 03/09/2022.
//

import Foundation
import CoreBluetooth
import CoreGraphics

class Motor : NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var bleDevices = "none"
    var centralManager: CBCentralManager!
    var nano : CBPeripheral!
    var characteristicTurnMotor : CBCharacteristic!
    var characteristicDegree : CBCharacteristic!
    public var myTracker : Tracker = Tracker()
    var camPoint = CGPoint(x:0.0,y:1.0)
    var surfPoint = CGPoint(x:0.1,y:1)
    var centerPoint = CGPoint(x:0.0,y:0.0)
    var turnDegree : CGFloat = 0
    
    override init() {
        super.init()
        startBluetooth()
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")
        
        switch central.state  {
        
        case CBManagerState.poweredOn :
            print("poweredOn")
            centralManager.scanForPeripherals(withServices: nil,options: nil)
        case CBManagerState.poweredOff :
            print("poweredOff")
        case CBManagerState.unknown :
            print("unknown")
        case CBManagerState.unauthorized :
            print("unauthorized")
        case CBManagerState.resetting :
            print("unauthorized")
        case CBManagerState.unsupported :
            print("unsupported")
        default :
            print("fell through case")
        }
    
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            //print("scanning for Nano")
        if (peripheral.name != nil) {
            if (peripheral.name!.contains("Nano") || peripheral.name!.contains("Arduino") ) {
                nano = peripheral
                bleDevices = nano.name!
                central.stopScan()
                centralManager.connect(peripheral)
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to: \(peripheral.debugDescription)" )
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("services")
        print(peripheral.services.debugDescription)
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let charac = service.characteristics {
            for characteristic in charac {
                print("found characteristics")
                
                print(characteristic.debugDescription)
                if (characteristic.uuid.debugDescription.contains("1A57")) { characteristicDegree = characteristic }
                if (characteristic.uuid.debugDescription.contains("2A57")) { characteristicTurnMotor = characteristic }
                
                
                var myInt = 20
                let data = Data(bytes: &myInt,count: MemoryLayout.size(ofValue: myInt))
                
                peripheral.writeValue(data, for: characteristicTurnMotor, type: .withResponse)

                }
            }
    }
    //untested below and  todo need to check if should turn lef or right - below or over 180 degrees
    
    var str = "0"
    
    
    func sendStringtoNano() {
        print("trying to send teststring to nano: ")
        str = "45"
        //house
        centerPoint.x = 52.3143842466015
        centerPoint.y = 5.046078517198089
        //north
        camPoint.x = 52.31474577145129
        camPoint.y = 5.04604871383498
        //church
        surfPoint.x = 52.31227426147402
        surfPoint.y = 5.046760629721911

//
        let magneticAngle = myTracker.magneticHeading
        print("magneticAngle \(myTracker)")
        surfPoint.x = centerPoint.x + cos(magneticAngle*Double.pi/180)
        surfPoint.y = centerPoint.y + sin(magneticAngle*Double.pi/180)


//        surfPoint.x = centerPoint.x + cos(90*Double.pi/180)
//        surfPoint.y = centerPoint.y + sin(90*Double.pi/180)

        
        turnDegree = angleBetweenThreePoints(center: centerPoint, firstPoint: camPoint, secondPoint: surfPoint)*180/Double.pi
        print("turndegree \(turnDegree)")
        if(nano != nil) {
            nano.writeValue((str.data(using: String.Encoding.utf8)!), for: characteristicDegree, type: .withResponse)
        }
    }
    
    func startBluetooth() {
        print("trying to start bluetooth")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    
    }
    
    func startScanning() {
        print("trying to start scanning")
        centralManager.scanForPeripherals(withServices: nil,options: nil)
    }
 
    func angleBetweenThreePoints(center: CGPoint, firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
            let firstAngle = atan2(firstPoint.y - center.y, firstPoint.x - center.x)
            let secondAnlge = atan2(secondPoint.y - center.y, secondPoint.x - center.x)
            let angleDiff = firstAngle - secondAnlge
            
//            if angleDiff < 0 {
//                angleDiff *= -1
//            }
            
            return angleDiff
        }
    
    
}
