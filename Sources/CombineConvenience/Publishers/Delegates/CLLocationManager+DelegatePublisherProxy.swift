//
//  DelegateProxy.swift
//  CombineConvenience
//
//  Created by Joshua Campion on 25/06/2019.
//  Copyright © 2019 Josh Campion. All rights reserved.
//

import Foundation
import Combine
import CoreLocation


/*
 
// partial implementation to be completed when necessary
 
/// Type for publishers that produce non-completing errors e.g. location manager sends `.locationUnknown` update
public typealias ResultFailurePublisher<Output, Failure: Error> = AnyPublisher<Result<Output, Failure>, Never>

extension PassthroughSubject where Failure == Never {
    
    func sendSuccess<Wrapped, Error>(_ value: Wrapped) where Output == Result<Wrapped, Error> {
        send(.success(value))
    }
    
    func sendError<Wrapped, Error>(_ error: Error) where Output == Result<Wrapped, Error> {
        send(.failure(error))
    }
}

extension CLLocationManager {
    
    public enum LocationError: Error {
        
        case locationUnknown // location is currently unknown, but CL will keep trying
        
        case denied // Access to location or ranging has been denied by the user
        
        case network // general, network-related error
    }
    
    public enum RangingError: Error {
        
        case denied
        
        case rangingUnavailable // Ranging cannot be performed
        
        case rangingFailure // General ranging failure
    }
    
    public enum HeadingError: Error {
        
        case denied // Access to location or ranging has been denied by the user
        
        case headingFailure // heading could not be determined
    }
    
    public enum RegionError: Error {
        
        case regionMonitoringDenied // Location region monitoring has been denied by the user
        
        case regionMonitoringFailure // A registered region cannot be monitored
        
        case regionMonitoringSetupDelayed // CL could not immediately initialize region monitoring
        
        case regionMonitoringResponseDelayed // While events for this fence will be delivered, delivery will not occur immediately
    }
    
    public enum GeocodingError: Error {
        
        case denied
        
        case geocodeFoundNoResult // A geocode request yielded no result
        
        case geocodeFoundPartialResult // A geocode request yielded a partial result
        
        case geocodeCanceled // A geocode request was cancelled
    }
    
    public enum OperationState {
        case notStarted
        case running
        case paused
    }
    
    open class DelegatePublisherProxy: NSObject, CLLocationManagerDelegate {
        
        
        private weak var manager: CLLocationManager?
        
        private var forwardingDelegate: CLLocationManagerDelegate?
        
        let locationsSubject = PassthroughSubject<Result<[CLLocation], LocationError>, Never>()
        let authorizationSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
        let stateSubject = CurrentValueSubject<OperationState, Never>(.notStarted)
        let headingsSubject = PassthroughSubject<Result<CLHeading, HeadingError>, Never>()
        
        
        init(base: CLLocationManager) {
            manager = base
            forwardingDelegate = base.delegate
            base.delegate = self
        }
        
        // MARK: - Delegate
        
        // MARK: Locations
        
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            locationsSubject.sendSuccess(locations)
            forwardingDelegate?.locationManager?(manager, didUpdateLocations: locations)
        }
        
        public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            headingsSubject.sendSuccess(newHeading)
            forwardingDelegate?.locationManager?(manager, didUpdateHeading: newHeading)
        }
        
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            
            guard let clError = error as? CLError else {
                assertionFailure("Unknown error type received: \(error)")
                return
            }
            
            switch clError.code {
                
            case .headingFailure:
                headingsSubject.sendError(.headingFailure)
            default:
                fatalError("Error unhandled: \(clError)")
            }
        }
        
        static var _customDelegateKey: Int = 0
        
        // MARK: State
        
        public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
            stateSubject.send(.paused)
            forwardingDelegate?.locationManagerDidPauseLocationUpdates?(manager)
        }
        
        public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
            stateSubject.send(.running)
            forwardingDelegate?.locationManagerDidResumeLocationUpdates?(manager)
        }
        
        // MARK: Authorization
        
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            authorizationSubject.send(status)
            forwardingDelegate?.locationManager?(manager, didChangeAuthorization: status)
        }
    }
    
    private var customDelegate: DelegatePublisherProxy {
        get {
            let cached = objc_getAssociatedObject(self, &DelegatePublisherProxy._customDelegateKey)
            if let found = cached as? DelegatePublisherProxy {
                return found
            }
            
            let newProxy = DelegatePublisherProxy(base: self)
            objc_setAssociatedObject(self, &DelegatePublisherProxy._customDelegateKey, newProxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newProxy
        }
    }
    
    public var locationPublisher: ResultPublisher<[CLLocation], LocationError> {
        return customDelegate.locationsSubject.eraseToAnyPublisher()
    }
    
}
*/
