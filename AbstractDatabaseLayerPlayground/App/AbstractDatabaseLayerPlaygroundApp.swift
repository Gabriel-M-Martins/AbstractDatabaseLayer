//
//  AbstractDatabaseLayerPlaygroundApp.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 01/11/23.
//

import SwiftUI

@main
struct AbstractDatabaseLayerPlaygroundApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Playground()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
