//
//  File.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import Combine

/// Wrapper than can be extended for neat combine extensions to existing `Foundation` and other classes
struct Combinable<Base> {
    
    let base: Base
    init(base: Base) {
        self.base = base
    }
}
