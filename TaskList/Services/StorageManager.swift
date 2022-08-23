//
//  StorageManager.swift
//  TaskList
//
//  Created by Андрей Парчуков on 23.08.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext(completion: (() -> Void)? = nil) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion?()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Fetching support
    func fetch<T>(of type: T.Type, completion: ([T]) -> Void) where T: NSManagedObject {
        guard let request = type.fetchRequest() as? NSFetchRequest<T> else { return }
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            completion(result)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Core Data Deleting support
    func delete<T>(_ object: T) where T: NSManagedObject {
        persistentContainer.viewContext.delete(object)
        saveContext()
    }
    
    // MARK: - Core Data Object Initiating support
    func objectInContext<T>(of type: T.Type) -> T where T: NSManagedObject {
        T(context: persistentContainer.viewContext)
    }
    
}
