//
//  FlatMapFirstTests.swift
//  CombineConvenienceTests
//
//  Created by Joshua Campion on 21/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import XCTest
import Combine
import CombineConvenience

class FlatMapFirstTests: XCTestCase {
    
    var trigger: PassthroughSubject<Int, TestError>!
    var completeTrigger: PassthroughSubject<Void, TestError>!
    
    var sut: Publishers.FlatMapFirst<PassthroughSubject<Int, TestError>, AnyPublisher<Int, TestError>>!
    
    var next: Int?
    var finished: Bool = false
    var error: TestError?
    
    var token: AnyCancellable!
    
    override func setUp() {
        super.setUp()
        
        trigger = PassthroughSubject<Int, TestError>()
        
        _ = trigger.print("outside")
        
        completeTrigger = PassthroughSubject<Void, TestError>()
        let completePublisher = completeTrigger
            .print("inside")
        
        sut = Publishers.FlatMapFirst(upstream: trigger) { value -> AnyPublisher<Int, TestError> in
            
            return completePublisher.flatMap { Result<Int, TestError>.Publisher(value * 10) }
                .prefix(1)
                .print("calculation")
                .eraseToAnyPublisher()
        }
        
        _ = sut.print("sut")
        
        token = sut.sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                self.finished = true
            case .failure(let e):
                self.error = e
            }
        }, receiveValue: { self.next = $0 })
    }
    
    override func tearDown() {
        next = nil
        finished = false
        error = nil
        token = nil
    }
    
    func test_flatMapFirst_flatMaps() {
        
        // ensure correct set up
        XCTAssertNil(next)
        XCTAssertFalse(finished)
        XCTAssertNil(error)
        
        // Tests
        
        // flat map not completed immediately
        trigger.send(1)
        XCTAssertNil(next)
        
        // flat map maps
        completeTrigger.send()
        XCTAssertEqual(next, 10)
        
        // still active
        XCTAssertFalse(finished)
        XCTAssertNil(error)
    }
    
    func test_flatMapFirst_ignoresUntilInnerCompletes() {
        
        // ensure correct set up
        XCTAssertNil(next)
        XCTAssertFalse(finished)
        XCTAssertNil(error)
        
        // Tests
        
        // flat map not completed immediately
        trigger.send(1)
        XCTAssertNil(next)
        
        // send new value. Should be ignored
        trigger.send(2)
        
        // inner completes
        completeTrigger.send()
        XCTAssertEqual(next, 10)
        
        // still active
        XCTAssertFalse(finished)
        XCTAssertNil(error)
    }
    
    func test_flatMapFirst_skipsIgnoredValue() {
        
        // ensure correct set up
        XCTAssertNil(next)
        XCTAssertFalse(finished)
        XCTAssertNil(error)
        
        // Tests
        
        // flat map not completed immediately
        trigger.send(1)
        XCTAssertNil(next)
        
        // send new value. Should be ignored
        trigger.send(2)
        
        // inner completes
        completeTrigger.send()
        XCTAssertEqual(next, 10)
        
        // new value is used, ignored is skipped
        trigger.send(3)
        completeTrigger.send()
        XCTAssertEqual(next, 30)
        
        // still active
        XCTAssertFalse(finished)
        XCTAssertNil(error)
    }
    
    func test_flatMapFirst_passesError() {
        
        // ensure correct set up
        XCTAssertNil(next)
        XCTAssertFalse(finished)
        XCTAssertNil(error)
        
        // Tests
        
        // flat map not completed immediately
        trigger.send(1)
        XCTAssertNil(error)
        
        // flat map completes
        completeTrigger.send(completion: .failure(.one))
        XCTAssertEqual(error, .one)
        XCTAssertNil(next)
        XCTAssertFalse(finished)
    }
}
