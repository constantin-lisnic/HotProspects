//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Constantin Lisnic on 23/12/2024.
//

import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Prospect.self)
        }
    }
}
