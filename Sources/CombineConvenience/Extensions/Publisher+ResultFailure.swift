//
//  File.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import Combine

extension Publisher {
    
    /// Non-erased type for the result of `catchByResult()`
    typealias CaughtResult = Publishers.Catch<Publishers.Map<Self, Result<Self.Output, Self.Failure>>, Just<Result<Self.Output, Self.Failure>>>
    
    /// Convenience operator that maps self to a `Result` producing publisher with error `Never`
    ///
    /// This can be used when the result of a one-shot publsher is to be assigned to a property retaining the error, but having a `Never` failure state.
    ///
    /// - Returns: The mapped `Publisher` with  `Output = Result<Output, Failure>` and `Failure = Never`
    func catchByResult() -> CaughtResult {
        
        return self.map { Result<Output, Failure>.success($0) }
            .catch { return Just(.failure($0)) }
    }
}

extension Publisher where Failure == Never {
    
    /// Transforms a non failing `Publisher` outputting `Result` to a failing `Publisher`
    func promotingFailure<O, F>() -> Publishers.TryMap<Self, O> where Output == Result<O, F> {
        return self.tryMap { (result) -> O in
            switch result {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        }
    }
}
