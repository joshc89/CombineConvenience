//
//  PageProvider.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 24/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

/// An object that can generate paging requests to be used with a `Publishers.Paging`
public protocol PageProvider {
    
    /// The type of `Publisher` that will load a single page
    associatedtype PageGenerator: Publisher where PageGenerator.Output: PageType
    
    /// The type of `Publisher` that will indicate when to load another page
    associatedtype Trigger: Publisher where Trigger.Output == Void, Trigger.Failure == Never
    
    /// Convenience alias for the `Output` of a single page.
    /// This should encapsulate any information necessary to generate the next request, such as a next URL or token.
    typealias Page = PageGenerator.Output
    
    /// Convenice alias for the `Failure` of a single page
    typealias Failure = PageGenerator.Failure
    
    /// The function that generates a `Publisher` to load a single page.
    /// - Parameters:
    /// - page: An optional previous page from which the next page should be requested. If `nil`, it can be assumed to load the first page.
    /// - Returns: A `Publisher` that will return the next page. This is truncated to a single result.
    func loadNextPage(after page: Page?) -> PageGenerator
    
    /// Object that indicates when the next page should be attempted to be loaded. If a page request is already in progress outputs from this will be ignored.
    var trigger: Trigger { get }
}
