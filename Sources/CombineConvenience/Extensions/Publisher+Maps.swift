//
//  Publisher+Maps.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

// MARK: - Extra Maps

extension Publisher {
    
    /// Convenience operator for `Publisher` that
    public func tryFlatMap<P: Publisher>(transform: @escaping (Output) throws -> P) -> Publishers.FlatMap<P, Publishers.TryMap<Self,P>> {
        
        return self.tryMap(transform)
            .flatMap { $0 }
    }
    
    // MARK: First
    
    public func flatMapFirst<P: Publisher>(transform: @escaping (Output) -> P) -> Publishers.FlatMapFirst<Self, P> {
        return Publishers.FlatMapFirst(upstream: self, transform: transform)
    }
    
    // MARK: Latest
    
    public func flatMapLatest<P: Publisher>(transform: @escaping (Output) -> P) -> Publishers.SwitchToLatest<P, Publishers.Map<Self, P>> where P.Failure == Failure {
        return self.map(transform)
            .switchToLatest()
    }
    
    public func tryFlatMapLatest<P: Publisher>(transform: @escaping (Output) throws -> P) -> Publishers.SwitchToLatest<P, Publishers.TryMap<Self, P>>  where P.Failure == Error {
        
        return self.tryMap(transform)
            .switchToLatest()
    }
}
