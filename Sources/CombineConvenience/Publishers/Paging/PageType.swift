//
//  PageType.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 24/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation

/// An object the represent a single page of data in a paging request.
public protocol PageType {
    
    /// The type of elements this page contains
    associatedtype Element
    
    /// The elements of this page
    var items: [Element] { get }
    
    /// Flag for whether there is another page after the elements this page contains.
    var hasNextPage: Bool { get }
}
