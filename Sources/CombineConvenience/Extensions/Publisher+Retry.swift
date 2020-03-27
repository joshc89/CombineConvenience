//
//  Publisher+Retry.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    
    /// Retries after a certain element from another publisher is received.
    ///
    /// - Parameters:
    ///    - source: The publisher to watch for outputs on
    ///    - condition: Closure to evaluate whether retry can be performed
    func retryOnOutput<Source: Publisher>(of source: Source, when condition: @escaping (Source.Output) -> Bool) -> Publishers.WaitUntilOutputOf<Source, Publishers.Retry<Self>> {
        
        return retry(1)
            .afterOutputOf(source: source, meets: condition)
    }
    
    /// Convenience method for `retryOnOutput(of:condition:)` which suceeds on the first value of `source`.
    /// This can be useful for `Void` outputs used as triggers.
    func retryOnFirstOutput<Source: Publisher>(of source: Source) -> Publishers.WaitUntilOutputOf<Source, Publishers.Retry<Self>> {
        
        return retry(1)
            .afterOutputOf(source: source, meets: { _ in true })
    }
}
