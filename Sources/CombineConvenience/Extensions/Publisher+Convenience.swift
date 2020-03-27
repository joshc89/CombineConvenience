//
//  Publisher+Convenience.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

public extension Publisher {
    
    func compacted<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
        return self.compactMap { $0 }
    }
    
    func asOptional() -> Publishers.Map<Self, Output?> {
        return self.map { Optional.some($0) }
    }
    
    func toVoid() -> Publishers.Map<Self, Void> {
        return self.map { _ in }
    }
    
    func generaliseError() -> Publishers.MapError<Self, Error> {
        return self.mapError { $0 as Error }
    }
    
    func removeErrors(with transform: @escaping (Failure) -> Output) -> Publishers.Catch<Self, Just<Output>> {
        return self.catch { Just(transform($0)) }
    }
    
    func complete(when condition: @escaping (Output) -> Bool) -> Publishers.First<Publishers.DropWhile<Self>> {
        return self.drop(while: { !condition($0) })
            .first()
    }
}
