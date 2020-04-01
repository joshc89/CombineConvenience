//
//  File.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import CoreData
import Combine

extension Combinable where Base: NSPersistentContainer {
    
    /// Attempts to load the container of the given name
    /// - Parameter named: The name of the container to load
    /// - Returns: A `Publisher` the succeeds with the container after creation, or fails with the given error
    static func create(named: String) -> Deferred<Future<Base, Error>> {
        
        return Deferred {
            Future { promise in
                let container = Base.init(name: named)
                container.loadPersistentStores { [unowned container] (storeDescription, error) in
                    if let failure = error {
                        promise(.failure(failure))
                    } else {
                        promise(.success(container))
                    }
                }
            }
        }
    }
    
    static func loadContainer<Trigger>(named containerName: String, retryingWith trigger: Trigger) -> SinglePageLoader<Base, Error> where Trigger: Publisher, Trigger.Output == Void, Trigger.Failure == Never {
        SinglePageLoader(trigger: trigger, containerSource: create(named: containerName))
    }
}
