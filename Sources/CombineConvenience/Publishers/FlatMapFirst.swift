//
//  FlatMapFirst.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine


extension Publishers {
    
    /// Internal class to persistently store the value of whether we should be blocking the elements in a `FlatMapFirst`
    private final class Box<Wrapped> {
        
        var value: Wrapped
        
        init(_ value: Wrapped) {
            self.value = value
        }
    }
    
    /// `Publisher` that transforms the elements from an upstream publisher into a new or existing publisher, filtering elements in upstream until the new publisher completes.
    public struct FlatMapFirst<Upstream: Publisher, P: Publisher>: CompoundPublisher where P.Failure == Upstream.Failure {
        
        public typealias Output = P.Output
        public typealias Failure = P.Failure
        
        public let source: Publishers.FlatMap<Publishers.HandleEvents<P>, Publishers.Filter<Upstream>>
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> P) {
            
            let blockFlag = Box(false)
            let result = upstream
                .filter { _ in !blockFlag.value }
                .flatMap { element -> HandleEvents<P> in
                    
                    blockFlag.value = true
                    
                    return transform(element)
                        .handleEvents(receiveCompletion: { _ in blockFlag.value = false },
                                      receiveCancel: { blockFlag.value = false })
            }
            
            source = result
        }
    }
}
