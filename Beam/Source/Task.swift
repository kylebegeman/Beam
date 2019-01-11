//
//  Operation.swift
//  Transmit
//
//  Created by Kyle Begeman on 1/31/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// Defines a basic operation, requiring a request and a method to fetch from a service.
public protocol Task {
    /// Request to execute.
    var request: Request { get }

    /// Basic initializer
    init(request: Request)

    /// Run the operation with the supplied service.
    ///
    /// - Parameters:
    ///   - service: the web service object to manage the API call.
    ///   - completion: WebService response callback.
    @discardableResult
    func request(with service: Service, completion: @escaping ServiceCallback) -> Token?
}

/// The base class object to be subclassed for special needs. Works as is with no additions needed.
///
/// Ex:
///
///     NetworkTask(request: someRequest).request(with: someService, completion: { respone in
///         // Handle response
///     })
open class NetworkTask: Task {
    /// Local reference to the request object.
    public var request: Request

    /// Basic initializer.
    public required init(request: Request) {
        self.request = request
    }

    /// Generic (default) implementation of request:with:completion
    @discardableResult
    open func request(with service: Service, completion: @escaping ServiceCallback) -> Token? {
        // Subclass for custom behavior.
        return service.execute(request: request, callback: completion)
    }
}
