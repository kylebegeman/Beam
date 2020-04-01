//
//  Response.swift
//  Beam
//
//  Created by Kyle Begeman on 1/25/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
