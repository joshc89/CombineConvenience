//
//  CancellationBuilder.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 09/07/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Combine

@_functionBuilder
public struct CancellationBuilder {
    
    public static func buildBlock(c1: AnyCancellable) -> [AnyCancellable] {
        return [c1]
    }
    
    public static func buildBlock(c1: AnyCancellable, c2: AnyCancellable) -> [AnyCancellable] {
        return [c1, c2]
    }
    
    public static func buildBlock(c1: AnyCancellable, c2: AnyCancellable, c3: AnyCancellable) -> [AnyCancellable] {
        return [c1, c2, c3]
    }
    
    public static func buildBlock(c1: AnyCancellable, c2: AnyCancellable, c3: AnyCancellable,  c4: AnyCancellable) -> [AnyCancellable] {
        return [c1, c2, c3, c4]
    }
    
    public static func buildBlock(c1: AnyCancellable, c2: AnyCancellable, c3: AnyCancellable,  c4: AnyCancellable,  c5: AnyCancellable) -> [AnyCancellable] {
        return [c1, c2, c3, c4, c5]
    }
    
    public static func buildBlock(c1: AnyCancellable, c2: AnyCancellable, c3: AnyCancellable,  c4: AnyCancellable,  c5: AnyCancellable,  c6: AnyCancellable) -> [AnyCancellable] {
        return [c1, c2, c3, c4, c5, c6]
    }
    
}

