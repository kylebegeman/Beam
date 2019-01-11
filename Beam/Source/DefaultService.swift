//
//  Services.swift
//  Transmit
//
//  Created by Kyle Begeman on 5/5/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

/// A NetworkService based on URLSession; the default service layer.
public class DefaultService: Service {

    /// URLSession to be used for this service.
    private(set) var session: URLSession

    /// The environment
    public var environment: Environment

    /// Initializer for setting properties and initializing the URLSession
    public required init(environment: Environment) {
        self.session = URLSession(configuration: .default)
        self.environment = environment

        self.session.configuration.requestCachePolicy = environment.cachePolicy
        self.session.configuration.httpAdditionalHeaders = environment.headers
    }

    /// Implementation of the Service protocol method execute.
    public func execute(request: Request, callback: @escaping ServiceCallback) -> Token? {
        do {
            let r = try prepareNetworkRequest(for: request)

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

    /// Implementation of the Service protocol method prepareNetworkRequest.
    ///
    /// - Parameter request: request object to be prepped.
    /// - Returns: URLRequest object with all properties.
    /// - Throws: throws NetworkServerError object.
    public func prepareNetworkRequest(for request: Request) throws -> URLRequest {
        guard let url = URL(string: path(for: request)) else {
            throw ServiceError.badInput(request: request)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest = try prepareParameters(for: request, withUrlRequest: &urlRequest)
        urlRequest = prepareHeaders(for: request, withUrlRequest: &urlRequest)
        urlRequest.timeoutInterval = request.timeoutInterval

        return urlRequest
    }

    /// Configure the URLRequest with the request parameters, if applicable.
    ///
    /// - Parameters:
    ///   - request: the Request object that provides the parameters.
    ///   - urlRequest: the URLRequet object to be modified.
    /// - Returns: URLRequest with updated parameters.
    /// - Throws: NetworkServiceError
    private func prepareParameters(for request: Request, withUrlRequest urlRequest: inout URLRequest) throws -> URLRequest {
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
    ///
    /// - Parameters:
    ///   - request: the Request object that provides the headers.
    ///   - urlRequest: the URLRequet object to be modified.
    /// - Returns: URLRequest with updated headers.
    private func prepareHeaders(for request: Request, withUrlRequest urlRequest: inout URLRequest) -> URLRequest {
        guard let headers = request.headers else {
            for (header, value) in environment.headers { urlRequest.addValue(value, forHTTPHeaderField: header) }
            return urlRequest
        }

        //var newRequest = urlRequest
        var newHeaders = environment.headers

        for (header, value) in headers {
            newHeaders[header] = value
        }

        newHeaders.forEach { (header, value) in
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        return urlRequest
    }
}

// MARK: - Helpers

extension DefaultService {

    /// Generates a full request path based on the enviroment and request.
    ///
    /// - Parameter request: the request object.
    /// - Returns: a string with the full path including base, version and API path.
    private func path(for request: Request) -> String {
        var fullPath = "\(environment.baseUrl)/"

        if let version = request.version {
            fullPath += "\(version)/"
        }

        return fullPath + request.path
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
        guard let components = URLComponents(string: path(for: request)) else {
            throw ServiceError.badInput(request: request)
        }

        return components
    }

}
