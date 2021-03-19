//
//  ContentView.swift
//  BLE_20210318
//
//  Created by macbook on 2021/3/18.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
//        Text("Hello, world!")
//            .padding()
        
        VStack{
            Button(action: {
                // 所需執行的內容
                self.bleManager.startScanning()
//                print("Start Scanning")
            }) {
                // 按鈕介面外觀設置
                Text("Start Scanning")
            }
            Button(action: {
                // 所需執行的內容
                self.bleManager.stopScanning()
//                print("Stop Scanning")
            }) {
                // 按鈕介面外觀設置
                Text("Stop Scanning")
            }
        } // end of VStack
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
