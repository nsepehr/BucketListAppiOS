//
//  DataObject.swift
//  CoreDataPractice
//
//  Created by Nima Sepehr on 11/23/15.
//  Copyright © 2015 Nima Sepehr. All rights reserved.
//

import Foundation
import CoreData

public enum SaveState: ErrorType {
    case Success, Error, Unknown
}



public class DataHandler<T: NSManagedObject> {
    
    // MARK: - Initializations
    
    // *** REMEMBER *** Database name must be same as App name
    var dbName: String!
    var copyDataBaseIfNotPresent: Bool = false
    
    let modelExtension: String! = "momd"
    let sqlExtenstion: String! = "sqlite"
    
    var entityClassName: String {
        var className = NSStringFromClass(T)
        if className.rangeOfString(".") != nil {
            let nsClassName = className as NSString
            className = nsClassName.pathExtension
        }
        return className
    }
    
    
    // MARK: - Class Variables
    
    //\\\\\\\\\\\\\\\\ Application Document Directory ////////////////
    /// Returns the URL of the path where the data is being stored
    lazy var applicationDocumentDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        // Printing the url for debug
        print("My Data Handler directory url:")
        print(urls)
        
        // We're only interested in the first url. There should never be more than one anyway
        return urls[urls.count - 1]
        }()
    
    
    //\\\\\\\\\\\\\\\\ Managed Object Model ////////////////
    /// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource(self.dbName, withExtension: self.modelExtension)!
        var model: NSManagedObjectModel? = NSManagedObjectModel(contentsOfURL: modelURL)
        
        return model!
        }()
    
    
    //\\\\\\\\\\\\\\\\ Managed Object Context ////////////////
    /// Returns the managed object context using the class's persistent store coordinator
    lazy public var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        let managedObjectContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
        }()
    
    
    //\\\\\\\\\\\\\\\\\ Persistent Store Coordinator ////////////////
    /// Persistent coordinator for the application. This property must be optional as there are legitimate errors that could occur
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        let storeURL: NSURL = self.getStoreURL()
        
        if self.copyDataBaseIfNotPresent {
            // If we're going to ship a database with the application, then you will turn this feature on
            let dbPath = storeURL.path!
            var fileManager: NSFileManager = NSFileManager.defaultManager()
            
            // check to see if the sqlite database exists
            if !fileManager.fileExistsAtPath(dbPath) {
                // It doesn't so let's see if there was a database shiped with the app
                var defaultStorePath = NSBundle.mainBundle().pathForResource(self.dbName, ofType: self.sqlExtenstion)
                
                if defaultStorePath != nil {
                    // There was a sqlite database shipped with this app, let's copy it
                    do {
                        try fileManager.copyItemAtPath(defaultStorePath!, toPath: dbPath)
                    } catch var error as NSError {
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                    } catch {
                        fatalError("FATAL: Unable to copy the database shipped with app")
                    }
                }
            }
        }
        
        // Create coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let failureReason: String = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true])
        } catch var error as NSError {
            coordinator = nil
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            //error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            NSLog("Unresolved error \(error), \(error.userInfo)")
            abort()
        } catch {
            fatalError(failureReason)
        }
        
        return coordinator
        }()
    
    
    // MARK: - Class functions
    
    
    //\\\\\\\\\\\\\\\\ Initialize Function ////////////////
    /// The functions which gets called on the initialization of the class
    init() {
        // Nothing to do for parent init
    }
    
    //\\\\\\\\\\\\\\\\ Gets the path of the store ////////////////
    /// Returns the URL of the store, which is the database name created by the object + sqlite extension
    func getStoreURL() -> NSURL {
        return self.applicationDocumentDirectory.URLByAppendingPathComponent("\(self.dbName).\(self.sqlExtenstion)")
    }
    
    //\\\\\\\\\\\\\\\\ Register Child Object ////////////////
    /// Registers the child object for DataHandler object
    func registerChildObject(object: DataHandler) {
        object.managedObjectContext = self.managedObjectContext
    }
    
    
    // MARK: - Saving Entities
    
    //\\\\\\\\\\\\\\\\ Save Entity ////////////////
    /// Funciton for saving the entities that have been changed
    //public func saveEntities() throws -> (state: SaveState, message: String?) {
    public func saveEntities() {
        //var saveState: SaveState = SaveState.Unknown
        //var message: String?
        
        if let managedObjectContext = self.managedObjectContext {
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    //saveState = SaveState.Error
                    //message = error.description
                } catch {
                    //message = "Unknown error during saveEntinties"
                    NSLog("Unknown error during saveEntinties")
                }
            } else {
                //message = "Save Success"
            }
        } else {
            //saveState = SaveState.Error
            //message = "Managed Object Context returned nil"
        }
        
        //return (saveState, message)
    }
    
    
    //\\\\\\\\\\\\\\\\ Save Changes of Specific Entity ////////////////
    // TODO: - Save Specific Entity
    
    
    // MARK: - Getting Entities
    
    //\\\\\\\\\\\\\\\\ Get the Entity ////////////////
    /// Gets the entity described by the predicate and sorts it by the descriptor. If no predicate, all entities are returned, if no sort it will return as is.
    func getEntity(sortedBy sortDescriptor: NSSortDescriptor?, matchingPredicate predicate: NSPredicate?) -> Array<T> {
        
        // Create the request object
        let request: NSFetchRequest = NSFetchRequest()
        
        // Set the entity type to be fetched
        let entityDescriptor: NSEntityDescription! = NSEntityDescription.entityForName(self.entityClassName, inManagedObjectContext: self.managedObjectContext!)
        
        request.entity = entityDescriptor
        
        // Add the predicate if the user is filtering for specific entity
        if predicate != nil {
            request.predicate = predicate
        }
        
        // FIXME: - Sort descriptor
        // Not sure if this will work, test and find out
        if sortDescriptor != nil {
            request.sortDescriptors = [sortDescriptor!]
        }
        
        // Execcute the feth request
        var results = Array<T>?()
        do {
            try results = self.managedObjectContext?.executeFetchRequest(request) as! Array<T>?
            return results!
        } catch let error as NSError {
            NSLog("Unable to get results for entity \(error), \(error.userInfo)")
            return results! // returns empty array
        } catch {
            NSLog("Unresolved error during entity catching")
            return results!
        }
        
    }
    
    
    //\\\\\\\\\\\\\\\\ Get All the Entity ////////////////
    /// Gets all the entities
    func getAllEntities() -> Array<T> {
        return self.getEntity(sortedBy: nil, matchingPredicate: nil)
    }
    
    
    //\\\\\\\\\\\\\\\\ Get All the Entity Matching Predicate ////////////////
    /// Gets all the entities filtered by the predicate passed to it
    func getEntitiesMatchingPredicate(matchingPredicate predicate: NSPredicate) -> Array<T> {
        return self.getEntity(sortedBy: nil, matchingPredicate: predicate)
    }
    
    //\\\\\\\\\\\\\\\\ Get All the Entity and Sort ////////////////
    /// Gets all the entities available and sorts them by the descriptor passed to it
    func getAllEntitiesAndSortBy(sortedBy sort: NSSortDescriptor) -> Array<T> {
        return self.getEntity(sortedBy: sort, matchingPredicate: nil)
    }
    
    
    // MARK: - Create Entities
    
    //\\\\\\\\\\\\\\\\ Creates Entities ////////////////
    /// Creates an empty entity object
    func createEntity() -> T {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityClassName, inManagedObjectContext: self.managedObjectContext!) as! T
    }
    
    
    // MARK: - Adding Entities
    
    //\\\\\\\\\\\\\\\\ Adding Entities to DataBase ////////////////
    /// Adds the array of entity objects passed to it
    func addEntities(entityList: Array<T>) {
        for e: T in entityList {
            let keys = Array(e.entity.attributesByName.keys)
            let dict = e.dictionaryWithValuesForKeys(keys)
            let eCopy = self.createEntity()
            eCopy.setValuesForKeysWithDictionary(dict)
        }
    }
    
    
    // MARK: - Delete Entity
    
    //\\\\\\\\\\\\\\\\ Delete Entities ////////////////
    /// Deletes the entity object passed to it
    func deleteEntity(entity: T) {
        self.managedObjectContext?.deleteObject(entity)
    }
    
    
}