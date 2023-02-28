//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Aleksei Voronovskii on 2/20/23.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
 
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let context: NSManagedObjectContext
    
    private init () {
        context = persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD
    func delete(task: Task) {
        context.delete(task)
        saveContext()
    }
}
