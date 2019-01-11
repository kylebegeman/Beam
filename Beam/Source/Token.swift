//
//  Token.swift
//  Transmit
//
//  Created by Kyle Begeman on 5/4/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// Simple token for invalidating async requests at will.
public class Token {
    /// A private reference to the data task
    private weak var request: URLSessionDataTask?

    /// Custom initializer for Service objects
    ///
    /// - Parameter request: URLRequest object to be tracked.
    public init(request: URLSessionDataTask) {
        self.request = request
    }

    /// Cancel the request.
    public func cancel() {
        request?.cancel()
    }
}
