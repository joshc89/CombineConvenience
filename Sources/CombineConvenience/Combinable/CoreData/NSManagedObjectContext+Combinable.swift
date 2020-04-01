//
//  File.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import CoreData
import Combine

extension Combinable where Base: NSManagedObjectContext {
    
    /// Publisher that completes after saving, or fails with any error
    func save() -> Deferred<Future<Void, Error>> {
        return Deferred {
            Future<Void, Error> { promise in
                guard self.base.hasChanges == true else {
                    // either context doesn't exist, or no changes, so no saving needs to be performed
                    promise(.success(()))
                    return
                }
                
                do {
                    try self.base.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
