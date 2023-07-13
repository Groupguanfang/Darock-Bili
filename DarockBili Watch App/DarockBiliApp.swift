//
//  DarockBiliApp.swift
//  DarockBili Watch App
//
//  Created by WindowsMEMZ on 2023/6/30.
//

import SwiftUI
import SDWebImage
import SDWebImageWebPCoder
import SDWebImageSVGCoder
import SDWebImagePDFCoder

@main
struct DarockBili_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImagePDFCoder.shared)
        
//        let nsd = biliEmojiDictionary as NSDictionary
//        let manager = FileManager.default
//        let urlForDocument = manager.urls(for: .documentDirectory, in: .userDomainMask)
//        try! nsd.write(to: URL(string: (urlForDocument[0] as URL).absoluteString + "biliEmoji.plist")!)
//        debugPrint((urlForDocument[0] as URL).absoluteString + "biliEmoji.plist")
        
    }
}
