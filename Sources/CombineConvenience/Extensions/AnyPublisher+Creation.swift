//
//  AnyPublisher+Creation.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

public extension AnyPublisher {
    
    static func just(_ value: Output) -> Self {
        return Just(value).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
    
    static func error(_ error: Failure) -> Self {
        return Result<Output, Failure>.Publisher(error).eraseToAnyPublisher()
    }
    
    static func empty(completeImmediately: Bool = true) -> Self {
        return Empty(completeImmediately: completeImmediately, outputType: Output.self, failureType: Failure.self)
            .eraseToAnyPublisher()
    }
    
    static func never() -> Self {
        return empty(completeImmediately: false)
    }
}

public extension Publisher where Failure == Never {
    
    func eraseToErrorPublisher<ErrorType>() -> AnyPublisher<Output, ErrorType> where ErrorType: Error {
        return self.setFailureType(to: ErrorType.self)
            .eraseToAnyPublisher()
    }
}
