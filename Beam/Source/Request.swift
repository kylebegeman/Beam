//
//  Requestable.swift
//  Transmit
//
//  Created by Kyle Begeman on 1/23/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// HTTP request method type
public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

/// Define the type of data we expect as a response
public enum DataType: String {
    case JSON
    case Data
}

/// Define parameters to pass along with the request and how
/// they are encapsulated into the http request itself.
///
/// - body: part of the body stream
/// - url: as url parameters
public enum RequestParameters {
    case body(_ : [String: Any]?)
    case url(_ : [String: Any]?)
}

/// Typealias for standard parameter format
public typealias Parameters = RequestParameters

/// Typealias for standard header format
public typealias Headers = [String: String]

// MARK: - Protocol implementation

/// Defines the required attributes for making a network request
public protocol Request {
    /// API version specific to the request
    var version: String? { get }

    // The constructed path based on paramters specific to each request.
    var path: String { get }

    // The HTTP medthod for each request (Ex: GET, PUSH)
    var method: HTTPMethod { get }

    // Expected data type for the response
    var dataType: DataType { get }

    // Required parameters for each request, if any.
    var parameters: Parameters? { get }

    // Authorization headers; accepts basic(user, pw) or bearer(token).
    var authentication: Authentication { get }

    // Required headers for each request, if any.
    var headers: Headers? { get }

    // The timeout interval defined per request.
    var timeoutInterval: TimeInterval { get }

    // Description for output
    var description: String { get }
}

/// Default values for non-required or common properties
public extension Request {
    var dataType: DataType { return .JSON }
    var parameters: Parameters? { return nil }
    var headers: Headers? { return nil }
    var timeoutInterval: TimeInterval { return 10.0 }
    var authentication: Authentication { return .none }

    /* Deprecated: Authorization = \(self.authentication.description) */
    var description: String {
        return """
        Headers = \(self.headers != nil ? String(describing: self.headers) : "none")
        Method = \(self.method.rawValue)
        Data Type = \(self.dataType.rawValue)
        Path = \(self.path)
        Parameters = \(self.parameters != nil ? String(describing: self.parameters) : "none")
        Authorization = \(self.authentication.description)
        """
    }
}
