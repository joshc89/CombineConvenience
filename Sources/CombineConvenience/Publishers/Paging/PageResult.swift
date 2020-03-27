//
//  PageResult.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 24/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation

/// Encapsulates an instance of a paging API request
///
/// This effectively marks a position in a paging API.
public struct PageResult<Page: PageType, Failure: Error> {
    
    /// The successful `Page` before this request
    public let previous: Page?
    
    /// The result of this request. If `.failure`, `previous` can be used to generate a re-request
    public let result: Result<Page, Failure>
    
    public init(previous: Page?, result: Result<Page, Failure>) {
        self.previous = previous
        self.result = result
    }
}

extension PageResult: Equatable where Page: Equatable, Failure: Equatable {
    
    public static func == (lhs: PageResult, rhs: PageResult) -> Bool {
        return lhs.previous == rhs.previous &&
            lhs.result == rhs.result
    }
}
