//
//  Service.swift
//  Transmit
//
//  Created by Kyle Begeman on 2/1/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// Custom errors for our network throwing methods
public enum ServiceError: Error {
    case badInput(request: Request)
    case noData(request: Request)
}

/// Simple callback that returns a response object.
public typealias ServiceCallback = (Response) -> Void

public protocol Service {
    /// A local reference to the service environment
    var environment: Environment { get }

    /// Execute the given Request object.
    ///
    /// - Parameters:
    ///   - request: request object to be executed.
    ///   - callback: ServiceCallback return a Reponse object or Error object.
    /// - Returns: RequestToken object to store a reference to a request.
    @discardableResult
    func execute(request: Request, callback: @escaping ServiceCallback) -> Token?
}
