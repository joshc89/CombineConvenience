//
//  WaitUntilOutputOf.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension Publishers {
    
    /// `Publisher` that emits completion once an upstream publisher emits an element.
    ///
    /// - seealso: `Publisher.afterOutputOf(source:meets:)`
    /// - seealso: `Publisher.afterFirstOutputOf(source:)`
    public struct WaitUntilOutputOf<Source: Publisher, Upstream: Publisher>: CompoundPublisher {
        
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        public let source: Concatenate<PrefixUntilOutput<Empty<Upstream.Output, Upstream.Failure>, First<DropWhile<Source>>>, Upstream>
        
        public init(upstream: Upstream, source: Source, condition: @escaping (Source.Output) -> Bool) {
            
            // because Source and Upstream can have mismatched types, we have to use an empty of Upstream types that is prefixed until the output of Source to allow mixing
            
            let wait = Empty<Output, Failure>(completeImmediately: false)
                .prefix(untilOutputFrom: source.complete(when: condition))
            
            self.source = upstream.prepend(wait)
        }
    }
}

extension Publisher {
    
    /// Subscribes `self` after the output of another publisher meets a given condition
    ///
    /// - Parameters:
    ///   - source: The upstream `Publisher` whose outputs will determine when `self` can subscribe.
    ///   - condition: Closure to evaluate when `self` can subscribe.
    public func afterOutputOf<Source: Publisher>(source: Source, meets condition: @escaping (Source.Output) -> Bool) -> Publishers.WaitUntilOutputOf<Source, Self> {
        
        return Publishers.WaitUntilOutputOf(upstream: self, source: source, condition: condition)
    }
    
    /// Subscribes `self` after the first output of another publisher
    ///
    /// - Parameters:
    ///   - source: The upstream `Publisher` whose first output will determine when `self` can subscribe.
    public func afterFirstOutputOf<Source: Publisher>(source: Source) -> Publishers.WaitUntilOutputOf<Source, Self> {
        
        return Publishers.WaitUntilOutputOf(upstream: self, source: source, condition: { _ in true })
    }
}
