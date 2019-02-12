//
//  Service.swift
//  Transmit
//
//  Created by Kyle Begeman on 2/1/18.
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

/// Custom errors for our network throwing methods
public enum ServiceError: Error {
    case badInput(request: Request)
    case noData(request: Request)
}

/// Simple callback that returns a response object.
public typealias ServiceCallback = (Response) -> Void

public protocol Service {
    /// Execute the given Request object.
    ///
    /// - Parameters:
    ///   - request: request object to be executed.
    ///   - callback: ServiceCallback return a Reponse object or Error object.
    /// - Returns: RequestToken object to store a reference to a request.
    @discardableResult
    func execute(request: Request, callback: @escaping ServiceCallback) -> Token?

    /// Configure the network request based on need for each endpoint.
    ///
    /// - Parameter request: request object to be prepped.
    /// - Returns: URLRequest object with all properties.
    /// - Throws: throws NetworkServerError object.
    func configureNetworkRequest(for request: Request) throws -> URLRequest

    /// Configure the URLRequest with the request headers, if applicable.
    ///
    /// - Parameters:
    ///   - request: the Request object that provides the headers.
    ///   - urlRequest: the URLRequet object to be modified.
    /// - Returns: URLRequest with updated headers.
    func configureHeaders(for request: Request, withUrlRequest urlRequest: inout URLRequest) -> URLRequest

    /// Configure the URLRequest with the request parameters, if applicable.
    ///
    /// - Parameters:
    ///   - request: the Request object that provides the parameters.
    ///   - urlRequest: the URLRequet object to be modified.
    /// - Returns: URLRequest with updated parameters.
    /// - Throws: NetworkServiceError
    func configureParameters(for request: Request, withUrlRequest urlRequest: inout URLRequest) throws -> URLRequest

}

// MARK: - Defaults

public extension Service {

    /// Implementation of the Service protocol method prepareNetworkRequest.
    public func configureNetworkRequest(for request: Request) throws -> URLRequest {
        guard let url = URL(string: request.path) else {
            throw ServiceError.badInput(request: request)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest = try configureParameters(for: request, withUrlRequest: &urlRequest)
        urlRequest = configureHeaders(for: request, withUrlRequest: &urlRequest)
        urlRequest.timeoutInterval = request.timeoutInterval

        return urlRequest
    }

    /// Configure the URLRequest with the request parameters, if applicable.
    public func configureParameters(for request: Request, withUrlRequest urlRequest: inout URLRequest) throws -> URLRequest {
        guard let parameters = request.parameters else { return urlRequest }

        switch parameters {
        case .body(let params):
            guard let p = params as? [String: String] else {
                throw ServiceError.badInput(request: request)
            }

            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: p, options: .init(rawValue: 0))
            return urlRequest

        case .url(let params):
            guard let p = params as? [String: String] else {
                throw ServiceError.badInput(request: request)
            }

            var components = try urlComponents(for: request)
            components.queryItems = queryParameters(for: p)
            urlRequest.url = components.url

            return urlRequest
        }
    }

    /// Configure the URLRequest with the request headers, if applicable.
    public func configureHeaders(for request: Request, withUrlRequest urlRequest: inout URLRequest) -> URLRequest {
        request.allHeaders.forEach { header, value in
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        return urlRequest
    }

    /// Exctract the query items from the request parameters.
    ///
    /// - Parameter parameters: parameters pass by the Request object.
    /// - Returns: an array of URLQuery items.
    private func queryParameters(for parameters: [String: String]) -> [URLQueryItem] {
        return parameters.map({ (element) -> URLQueryItem in
            return URLQueryItem(name: element.key, value: element.value)
        })
    }

    /// Extract the URL components from the full path.
    ///
    /// - Parameter request: request object containing the path information.
    /// - Returns: URLComponents object.
    /// - Throws: NetworkErrors
    ///
    ///         NetworkErrors.badInput(request: Request)
    ///         NetworkErrors.noData(request: Request)
    ///
    private func urlComponents(for request: Request) throws -> URLComponents {
        guard let components = URLComponents(string: request.path) else {
            throw ServiceError.badInput(request: request)
        }

        return components
    }
}

/************************************************************************************/

// MARK: - Default service object available for use; can create your own.

/************************************************************************************/

public class URLSessionService: Service {

    /// URLSession to be used for this service.
    private(set) var session: URLSession

    /// Initializer for setting properties and initializing the URLSession
    public required init() {
        self.session = URLSession(configuration: .default)
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    }

    public func execute(request: Request, callback: @escaping ServiceCallback) -> Token? {
        do {
            let r = try configureNetworkRequest(for: request)

            let task = self.session.dataTask(with: r, completionHandler: { (data, response, error) in
                let successResponse = Response( (response as? HTTPURLResponse, data, error), for: request)
                callback(successResponse)
            })
            task.resume()

            return Token(request: task)

        } catch {
            let errorResponse = Response((nil, nil, error), for: request)
            callback(errorResponse)
            return nil
        }
    }
    
}
