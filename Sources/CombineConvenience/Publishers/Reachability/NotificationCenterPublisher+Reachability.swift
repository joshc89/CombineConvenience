//
//  NotificationCenterPublisher+Reachability.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

private var reachabilityKey: Int = 0

extension NotificationCenter {
    
    /// Internal variable to store `Reachability` object
    private var _sharedReachability: Reachability? {
        get {
            return objc_getAssociatedObject(self, &reachabilityKey) as? Reachability
        }
        set {
            objc_setAssociatedObject(self, &reachabilityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Fetches or creates a `Reachability` object.
    private func getSharedReachability() throws -> Reachability {
        
        if let found = _sharedReachability {
            return found
        }
        
        let newReachability = try Reachability()
        _sharedReachability = newReachability
        return newReachability
    }

    
    /// Creates a `Publisher` emitting reachability connection notifications.
    ///
    /// This will only error if the creation of the `ReachabilityObject` fails.
    public func reachabilityPublisher() -> AnyPublisher<Reachability.Connection, ReachabilityError> {
        
        do {
            let reachability = try getSharedReachability()
            let result = publisher(for: .reachabilityChanged, object: reachability)
            
            return result
                .map { _ in
                    reachability.connection
                }.eraseToErrorPublisher()
            
        } catch let error as ReachabilityError {
            return .error(error)
        } catch {
            return .empty()
        }
    }
}
