//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Serj on 02.07.2023.
//


import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data  CRUD methods
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(task taskName: String, to taskList: inout [Task]) {
            let task = Task(context: persistentContainer.viewContext)
            task.title = taskName
            taskList.append(task)
        
            if persistentContainer.viewContext.hasChanges {
                do {
                    try persistentContainer.viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
    
    func fetchData(to taskList: inout [Task]) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(object: Task) {
        persistentContainer.viewContext.delete(object)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
