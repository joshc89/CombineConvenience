//
//  TestError.swift
//  CombineConvenienceTests
//
//  Created by Joshua Campion on 24/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation

/// Simple explicit `Error` type for use in tests to constrain `Publisher.Failure` types.
enum TestError: Error {
    case one
}
