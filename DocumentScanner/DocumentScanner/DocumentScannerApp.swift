//
//  DocumentScannerApp.swift
//  DocumentScanner
//
//  Created by Fenuku kekeli on 5/23/25.
//

import SwiftUI

@main
struct DocumentScannerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .modelContainer(for: Document.self)
        }
        
    }
}
   
