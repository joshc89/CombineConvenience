//
//  CompoundPublisher.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

/// Protocol for a basic `Publisher` with a single underlying `source` which is used to receive subscribers providing automatic `Publisher` conformance
public protocol CompoundPublisher: Publisher {
    
    associatedtype Compound: Publisher
    
    var source: Compound { get }
}

extension CompoundPublisher {
    
    public func receive<S>(subscriber: S) where S : Subscriber, Compound.Failure == S.Failure, Compound.Output == S.Input {
        source.receive(subscriber: subscriber)
    }
}
