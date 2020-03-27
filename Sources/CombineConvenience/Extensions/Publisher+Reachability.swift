//
//  Publisher+Reachability.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    
    
    /// `Publisher` that subscribes `self` once Reachability of a certain type is notified.
    ///
    /// - note: This doesn't check for reachability first
    ///
    /// - Parameters:
    ///   - types: The types of connections to wait until
    ///   - center: The `NotificationCenter` to wait for reachability on
    func onceReachable(types: [Reachability.Connection] = [.wifi, .cellular], observedIn center: NotificationCenter = .default) -> Publishers.WaitUntilOutputOf<AnyPublisher<Reachability.Connection, ReachabilityError>, Self>{
        return self.afterOutputOf(source: center.reachabilityPublisher(), meets: { types.contains($0) })
    }
    
    /// `Publisher` that retries an upstream `Publisher` if its failure is caused by reachability.
    ///
    /// This can be used for silent processes that want to retry without receiving notification of a reachability failure.
    ///
    /// - seealso: `reachableDataTaskPublisher(for:types:center)` for the case where you want to receive notifications of the reachability failure.
    /// 
    /// - Parameters:
    ///   - types: The types of connections to wait until
    ///   - center: The `NotificationCenter` to wait for reachability on
    func retryOnReachability(types: [Reachability.Connection] = [.wifi, .cellular], from center: NotificationCenter = .default) -> Publishers.WaitUntilOutputOf<AnyPublisher<Reachability.Connection, ReachabilityError>, Publishers.Retry<Self>> {
        
        return retryOnOutput(of: center.reachabilityPublisher(), when: { types.contains($0) })
    }
}
