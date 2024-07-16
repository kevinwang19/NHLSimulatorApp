//
//  CoreDataManager.swift
//  NHLSimulatorApp
//
//  Created by Kevin Wang on 2024-07-09.
//

import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // Initialized persistent container for Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppInfo.appModel.rawValue)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Managed object context associated with the persistent container's view context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save changes in the managed object context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
