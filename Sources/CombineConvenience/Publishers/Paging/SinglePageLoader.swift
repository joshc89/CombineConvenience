//
//  SinglePageLoader.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import CoreData
import Combine

/// Publisher that can be used to attempt to load a failable resource. It reports failures through a `Result` output, and if it succeeds, the successful `Value` is returned _without_ retrying.
///
/// Underlying `source` is a `Paging` publisher, for a single page, with a provider given at initialisation
public struct SinglePageLoader<Value, SourceFailure: Error>: CompoundPublisher {
    
    public typealias Output = Result<Value, SourceFailure>
    public typealias Failure = Never
    
    // use a paging provider to keep retrying on trigger, as there are no auto-recoverable errors
    private struct Page: PageType {
        
        let value: Value
        
        // only item is the single value
        var items: [Value] {
            return [value]
        }
        
        // only need to load one page i.e. one value
        let hasNextPage = false
    }
    
    private struct Provider<Source, Trigger>: PageProvider
        where Trigger: Publisher, Trigger.Output == Void, Trigger.Failure == Never,
    Source: Publisher, Source.Output == Value, Source.Failure == SourceFailure {
        
        let source: () -> Source
        let trigger: Trigger
        
        func loadNextPage(after page: Page?) -> Publishers.Map<Source, SinglePageLoader<Value, SourceFailure>.Page> {
            return source().map { Page(value: $0) }
        }
    }
    
    /// Underlying `Publisher` referenced by `CompoundPublisher`
    public let source: AnyPublisher<Result<Value, SourceFailure>, Never>
    
    /// Default initialiser
    ///
    /// - Parameters:
    ///   - trigger: Trigger to attempt an retries, or re-publishings with
    ///   - containerSource: How to load, or retry loading, `Value`
    public init<Source, Trigger>(trigger: Trigger, containerSource: @escaping @autoclosure () -> Source)
        where Trigger: Publisher, Trigger.Output == Void, Trigger.Failure == Never,
        Source: Publisher, Source.Output == Value, Source.Failure == SourceFailure {
            
            let provider = Provider(source: containerSource, trigger: trigger)
            let source = Publishers.Paging(provider: provider)
                .map { $0.result.map { $0.value } }
                .eraseToAnyPublisher()
            self.source = source
    }
}
