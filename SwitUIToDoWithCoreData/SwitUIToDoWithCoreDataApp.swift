//
//  SwitUIToDoWithCoreDataApp.swift
//  SwitUIToDoWithCoreData
//
//  Created by Oleksii Leshchenko on 23.09.2022.
//

import SwiftUI

@main
struct SwitUIToDoWithCoreDataApp: App {
    
    let persistentContainer = CoreDataManager.shared.persistentContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
