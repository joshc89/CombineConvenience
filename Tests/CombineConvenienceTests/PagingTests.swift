//
//  PagingTests.swift
//  CombineConvenienceTests
//
//  Created by Joshua Campion on 24/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import XCTest
import Combine
import CombineConvenience

class PagingTests: XCTestCase {
    
    // MARK: - Variables
    
    var provider: TestProvider<TestPage, TestError>!
    
    var sut: Publishers.Paging<TestPage, TestError>!
    
    var next: TestResult?

    var finished: Bool = false
    
    /// Token to persist the subscription during test run
    var token: AnyCancellable!
    
    // MARK: - Set up
    
    override func setUp() {
        super.setUp()
        
        provider = TestProvider()
        sut = Publishers.Paging(provider: provider)
        
        
        token = sut.sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                self.finished = true
            case .failure(let never):
                fatalError("Never shouldn't fail: \(never)")
            }
        }) { (value) in
            self.next = value
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        provider = nil
        sut = nil
        token = nil
        
        next = nil
        finished = false
    }
    
    // MARK: - Tests
    
    func test_paging_completesWithSinglePage() {
        
        XCTAssertNil(next)
        
        let page = TestPage(range: 0..<50)
        provider.send(page)
        
        XCTAssertEqual(next, PageResult(previous: nil, result: .success(page)))
        XCTAssert(finished)
    }
    
    func test_paging_completesWithMultiplePages() {
        
        let pages = TestPage.make(count: 5, length: 10)
        
        for (idx, page) in pages.enumerated() {
            
            let previous = idx > 0 ? pages[idx - 1] : nil
            let expected = TestResult(previous: previous, result: .success(page))
            
            provider.send(page)
            
            XCTAssertEqual(next, expected)
            
            guard idx < pages.count - 1 else {
                XCTAssertTrue(finished)
                break
            }
            
            XCTAssertFalse(finished)
            
            provider.trigger.send()
        }
        
        XCTAssert(finished)
    }
    
    func test_paging_errorsRetriedByNextTrigger() {
        
        provider.error(.one)
        let expected = TestResult(previous: nil, result: .failure(.one))
        XCTAssertEqual(next, expected)

        provider.trigger.send()
        
        let page = TestPage(range: 0..<10)
        provider.send(page)

        let expected2 = TestResult(previous: nil, result: .success(page))
        XCTAssertEqual(next, expected2)
    }
    
    func test_multiplePageOutputsIgnored() {
        
        let pages = TestPage.make(count: 5, length: 10)
        
        for page in pages {
            provider.send(page)
        }
        
        let expected = TestResult(previous: nil, result: .success(pages[0]))
        XCTAssertEqual(next, expected)
    }
    
    func test_pageOutputBeforeTriggerIsIgnored() {
        
        let pages = TestPage.make(count: 5, length: 10)
        provider.send(pages[0])
        
        let expected = TestResult(previous: nil, result: .success(pages[0]))
        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        for page in pages.dropFirst().dropLast() {
            provider.send(page)
        }
        
        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        provider.trigger.send()

        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        provider.send(pages[4])
        
        let expected2 = TestResult(previous: pages[0], result: .success(pages[4]))
        XCTAssertEqual(next, expected2)
        XCTAssert(finished)
    }
    
    func test_paging_ignoresTriggersWhilstLoadingPage() {
        
        
        let page = TestPage(range: 0..<10)
        provider.send(page)
        
        let expected = TestResult(previous: nil, result: .success(page))
        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        provider.trigger.send()
        
        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        provider.trigger.send()
        provider.trigger.send()
        provider.trigger.send()
        
        XCTAssertEqual(next, expected)
        XCTAssertFalse(finished)
        
        let page2 = TestPage(range: 10..<20)
        let expected2 = TestResult(previous: page, result: .success(page2))
        provider.send(page2)
        XCTAssertEqual(next, expected2)
    }
    
    // MARK: - Types
    
    typealias TestResult = PageResult<TestPage, TestError>
    
    struct TestPage: Equatable, PageType {
        
        let range: Range<Int>
        
        var nextOffset: Int {
            return range.upperBound
        }
        
        var hasNextPage: Bool {
            return nextOffset < 50
        }
        
        var items: [Int] {
            return Array(range)
        }
        
        static func make(count: Int, length: Int) -> [TestPage] {
            return (0..<count).map { p -> TestPage in
                let start = p * length
                let end = start + length
                return TestPage(range: start..<end)
            }
        }
    }
    
    struct TestProvider<Page: PageType, Failure: Error>: PageProvider {
        
        let pageResults = PassthroughSubject<Result<Page, Failure>, Never>()
        
        let trigger = PassthroughSubject<Void, Never>()
        
        func send(_ page: Page) {
            pageResults.send(.success(page))
        }
        
        func error(_ error: Failure) {
            pageResults.send(.failure(error))
        }
        
        func loadNextPage(after page: Page?) -> AnyPublisher<Page, Failure> {
            // flatMap to a new publisher so a single value can be taken and ended without breaking the subscription to `pageLoads`
            return pageResults.tryMap { result throws -> Page in
                switch result {
                case .success(let page):
                    return page
                case .failure(let error):
                    throw error
                }
                }
                .mapError { $0 as! Failure }
                .eraseToAnyPublisher()
        }
    }
}
