//
//  Paging.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine

extension Publishers {
    
    /// `Publisher` that publishes results of attempting to load multiple sequential paged requests.
    ///
    /// `Page` is the type of page that will be in the result of a single page request.
    /// `Failure` is the type of error that will be result of a single page request.
    ///
    /// This publisher never fails, and instead publishes failures through the `PageResult` output.
    /// This allows paging to maintain its current position to effectively implement retrying a failure
    public struct Paging<Page: PageType, Failure: Error>: Publisher {
        
        /// The `Output` type of this publisher
        public typealias Output = PageResult<Page, Failure>
        
        /// The `Failure` type of this publisher
        public typealias Failure = Never
        
        /// Underlying publisher this type uses to receive subscriptions
        let source: AnyPublisher<PageResult<Page, Failure>, Never>
        
        /// Default initialiser
        /// - Parameter provider: The object to provide page generation and loading triggers. This is implicitly capture by the recursion.
        public init<Provider: PageProvider>(provider: Provider) where Provider.Page == Page, Provider.Failure == Failure {
            
            source = Paging.recurse(from: nil, with: provider)
                .print("Source")
                .eraseToAnyPublisher()
        }
        
        /// Protocol conformance
        ///
        /// Forwards the receiving on to the internal `source` publisher.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == Output {
            source.receive(subscriber: subscriber)
        }
        
        // MARK: - Recursion
        
        private static func recurse<Provider: PageProvider>(from previousPageResult: PageResult<Page, Failure>?, with provider: Provider) -> AnyPublisher<PageResult<Page, Failure>, Never> where Provider.Page == Page, Provider.Failure == Failure {
            
            let previousPage: Page?
            if case .success(let previous) = previousPageResult?.result {
                // last was success, so this is our new previous
                previousPage = previous
            } else {
                // last was failure, or nil, so this is nil for first page, or a retry of the failure
                previousPage = previousPageResult?.previous
            }
            
            let thisPageLoad = provider.loadNextPage(after: previousPage)
            
            let thisPageResult = thisPageLoad.map {
                PageResult<Page, Failure>(previous: previousPage, result: .success($0))
                }.removeErrors {
                    PageResult<Page, Failure>(previous: previousPage, result: .failure($0))
                }
                .prefix(1) // only take a single result
                .eraseToAnyPublisher()
            
            let recursion = thisPageResult.flatMap { pageResult -> AnyPublisher<PageResult<Page, Failure>, Never> in
                
                if case .success(let page) = pageResult.result,
                    !page.hasNextPage {
                    return .just(pageResult)
                }
                
                /// note: `guard` isn't used here as a failure should be able to pass through to here so we can recurse from the previous page to retry
                
                return recurse(from: pageResult, with: provider)
                    .afterFirstOutputOf(source: provider.trigger)
                    .prepend(pageResult)
                    .eraseToAnyPublisher()
                
                }.eraseToAnyPublisher()
            
            return recursion
        }
    }
}
