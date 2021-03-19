//
//  BLEManager.swift
//  BLE_20210318
//
//  Created by macbook on 2021/3/18.
//

// https://www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/
// BLE GATT Intro :  https://medium.com/@nalydadad/概述-gatt-藍芽傳輸-9fa218ce6022


/// TODO
/// [ ] Make `alert list` for case in scanning result is greater than 2 (id >= 1)
/// [ ]

import Foundation
import CoreBluetooth


// define struct for Peripheral
//struct Peripheral: Identifiable {
//
////    let uuid : String
//    let id: Int
//    let name: String
//    let rssi: Int
//    let advertisementData: [String : Any] // https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html
//
//}

// Peripheral Service UUID
// https://btprodspecificationrefs.blob.core.windows.net/assigned-values/16-bit%20UUID%20Numbers%20Document.pdf
// Page. 18
let BATTERY_SERVICE_UUID        = "180F"
let DEVICE_INFO_SERVICE_UUID    = "180A"

// new a class
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // new a object with class 'CBCentralManager'
    var myCentral : CBCentralManager!
    var targetPeripheral : CBPeripheral!
    @Published var isSwitchedOn = false
//    @Published var peripherals = [Peripheral]()
    
    // init function
    override init(){
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    
    // Check available Bluetooth Service
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // https://developer.apple.com/forums/thread/25783
        switch (central.state) {
            case .unsupported:  print("CoreBluetooth BLE hardware is unsupported on this platform")
            case .unauthorized: print("CoreBluetooth BLE state is unauthorized")
            case .unknown:      print("CoreBluetooth BLE state is unknown")
            case .resetting:    print("CoreBluetooth BLE is resetting")
            case .poweredOff:   print("CoreBluetooth BLE hardware is powered off")
           
            case .poweredOn:    isSwitchedOn = true
                
            @unknown default:   print("@unknown default in 'centralManagerDidUpdateState'")
        }
        
//        if central.state == .poweredOn {
//            isSwitchedOn = true
//        } else {
//            isSwitchedOn = false
//        }
    }
    
    
    // full flow from scanning > found device > store Peripheral > add the delegate > connect to Peripheral
    // 大致流程 掃 Device -> 掃 Device 裡面的 Service -> 掃 Service 裡面的 Characteristic
    // Device / Service / Characteristic  分別都是用 UUID 來辨認
    // https://medium.com/macoclock/core-bluetooth-ble-swift-d2e7b84ea98e
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // print(type(of: advertisementData)) // Dictionary<String, Any>
        /*
         Peripheral(
            id: 5,
            name: "Jian Jian Bao J21",
            rssi: -46,
            advertisementData: [
                "kCBAdvDataRxSecondaryPHY": 0,
                "kCBAdvDataServiceUUIDs": <__NSArrayM 0x28074d110>(Battery,Device Information),
                "kCBAdvDataRxPrimaryPHY": 0,
                "kCBAdvDataTimestamp": 637769278.3579741,
                "kCBAdvDataIsConnectable": 1,
                "kCBAdvDataTxPowerLevel": -2,
                "kCBAdvDataManufacturerData": <5cf3705b 6f89>,
                "kCBAdvDataLocalName": Jian Jian Bao J21
            ]
         )
        */
        
        targetPeripheral = peripheral
        targetPeripheral.delegate = self
        
        var peripheralName: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            peripheralName = name
            
            
            // https://stackoverflow.com/questions/53191695/converting-cbuuid-to-string-in-swift
//            guard let uuids = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] else { return }
//            guard let peripheralUuid = uuids.first?.uuidString else { return }
            
            
            // about `guard`
            // https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/檢查條件是否成立-不成立就離開的-guard-else-9650f3ac8e04
            //
            // Extract advertisementData["kCBAdvDataManufacturerData"]
            // https://www.coder.work/article/748470
            guard name == "Jian Jian Bao J21" else { // do if J21 is not found
                print("No device founded !!")
                stopScanning()
                return
            }
//            guard let nsdata = advertisementData["kCBAdvDataManufacturerData"] as? NSData else{
//                return
//            }
//            print("nsdata: \(nsdata)") // nsdata:{length = 6, bytes = 0x5cf3705b6f89}
//            let publicData = Data(bytes: nsdata.bytes, count: Int(nsdata.length))
            

// For multi devices scanning
//            // do if guard condition is `True`
//            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, advertisementData: advertisementData)
//            print(newPeripheral)
//            peripherals.append(newPeripheral) // append to list for display
 
        } // end of "if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String"

        // Connecting
        
        myCentral.connect(targetPeripheral!, options: nil)
        
        
    } // end of func centralManager()
    
    func startScanning() {
        print("startScanning")
        myCentral.scanForPeripherals(withServices: nil, options: nil)
//        myCentral.scanForPeripherals(withServices: serviceUUIDs:[CBUUID]?, options: nil)
    }
        
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        targetPeripheral.discoverServices(nil)
    }
    
    
} // end of class 'BLEManager'
