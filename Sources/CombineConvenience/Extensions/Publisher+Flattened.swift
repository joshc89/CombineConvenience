//
//  Publisher+Flattened.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Output: Publisher, Output.Failure == Failure {
    
    func flattened() -> Publishers.FlatMap<Self.Output, Self> {
        return self.flatMap { $0 }
    }
}
