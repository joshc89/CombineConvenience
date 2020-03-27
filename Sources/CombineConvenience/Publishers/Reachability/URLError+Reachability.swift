//
//  URLError+Reachability.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension URLError {
    
    /// Flag for whether this error is based on reachability and retrying is appropriate after a reachability notification
    public var isReachabilityFailure: Bool {
        switch code {
        case .networkConnectionLost, .notConnectedToInternet, .timedOut:
            return true
        default:
            return false
        }
    }
}
