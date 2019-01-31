//
//  Response.swift
//  Transmit
//
//  Created by Kyle Begeman on 1/25/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// Basic JSON object that wraps serialization and error handling
public struct JSON {
    private var val: Any?
    private var err: Error?

    public var value: Any? { return self.val }
    public var error: Error? { return self.err }

    /// Initialize by passing in a data object and JSON options
    ///
    /// - Parameters:
    ///   - data: data to be serialized
    ///   - options: JSON reading options
    public init(data: Data, options: JSONSerialization.ReadingOptions = []) {
        do {
            self.val = try JSONSerialization.jsonObject(with: data, options: options)
        } catch let error {
            self.err = error
        }
    }
}

/// Custom response object
public enum Response {
    case json(_: Status, _: JSON)
    case data(_: Status, _: Data)
    case error(_: Status, _: Error?)

    /// Custom init for our Response object that pulls data from a URLResponse
    ///
    /// - Parameters:
    ///   - response: a tuple representing the response object, data and an error
    ///   - request: the request object that made the request
    public init(_ response: (r: HTTPURLResponse?, data: Data?, error: Error?), for request: Request) {
        guard let statusCode = response.r?.statusCode, let status = Status(rawValue: statusCode) else {
            self = .error(.unknown, NSError(domain: "Missing status code.", code: 0, userInfo: nil))
            return
        }

        guard statusCode >= 200, statusCode < 300 else {
            self = .error(status, response.error)
            return
        }

        guard let data = response.data else {
            self = .error(status, ServiceError.noData(request: request))
            return
        }

        switch request.dataType {
        case .Data: self = .data(status, data)
        case .JSON: self = .json(status, JSON(data: data))
        }
    }
}
