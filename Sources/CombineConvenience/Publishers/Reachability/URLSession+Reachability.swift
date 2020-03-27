//
//  URLSession+Reachability.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension URLSession {
    
    /// Enum for the published outputs from a `reachableDataTaskPublisher`.
    /// These allow receive notification of the reachability failure, e.g. to provide UI updates, whilst also automatically retrying once reachability is resumed.
    public enum DataTaskOutcome {
        /// A successful response
        case success(DataTaskPublisher.Output)
        
        /// A failure due to a reachability error has occured. The request has been queued for retrying.
        case retrying(URLError)
    }
    
    /// Creates a publisher that retries the request on a reachability error, whilst also notifying the subscriber of the error that occuring.
    /// If an error occurs that is not caused by reachability, the returned publisher fails.
    ///
    /// - Parameters:
    ///    - request: The request to perform on `self`
    ///    - types: The types of connection notification to wait for before retrying
    ///    - center: The notification center to subscribe to reachability notifications on. A `Reachability` instance is created for the `NotificationCenter` if one isn't already registered.
    public func reachableDataTaskPublisher(for request: URLRequest, types: [Reachability.Connection] = [.wifi, .cellular], from center: NotificationCenter = .default) -> AnyPublisher<DataTaskOutcome, URLError> {
        
        return dataTaskPublisher(for: request)
            .map { DataTaskOutcome.success($0) }
            .catch { (error) -> AnyPublisher<DataTaskOutcome, URLError> in
                
                if error.isReachabilityFailure {
                    
                    return self.reachableDataTaskPublisher(for: request)
                        .onceReachable(types: types, observedIn: center)
                        .prepend(.retrying(error))
                        .eraseToAnyPublisher()
                    
                } else {
                    
                    return .error(error) // just error
                }
            }
            .eraseToAnyPublisher()
    }
}

