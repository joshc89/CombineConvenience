//
//  File.swift
//  
//
//  Created by Joshua Campion on 31/03/2020.
//

import Foundation

/// A type that has `Combine` extensions.
///
/// Default implementations are given for each property.
/// `NSObject` is extended to have these defaults.
public protocol CombineCompatible {
    
    /// Extended type
    associatedtype CombineBase

    /// Reactive extensions.
    static var cmb: Combinable<CombineBase>.Type { get set }

    /// Reactive extensions.
    var cmb: Combinable<CombineBase> { get set }
}

extension CombineCompatible {
    /// `Combinable` extensions.
    public static var cmb: Combinable<Self>.Type {
        get {
            return Combinable<Self>.self
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using `Combinable` to "mutate" base type
        }
    }

    /// `Combinable` extensions.
    public var cmb: Combinable<Self> {
        get {
            return Combinable(base: self)
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using `Combinable` to "mutate" base object
        }
    }
}

public extension NSObject: CombineCompatible { }
