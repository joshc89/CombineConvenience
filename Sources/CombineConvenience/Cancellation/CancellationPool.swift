//
//  CancellationPool.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 09/07/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Combine

public final class CancellationPool {
    
    var toCancel: [AnyCancellable]
    
    public init(@CancellationBuilder subscriptions: () -> [AnyCancellable]) {
        toCancel = subscriptions()
    }
    
    deinit {
        for cancelation in toCancel {
            cancelation.cancel()
        }
    }
}
