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
    var additionalHeaders: Headers? { get }

    // The timeout interval defined per request.
    var timeoutInterval: TimeInterval { get }

    // Description for output
    var description: String { get }
}

/// Default values for non-required or common properties
public extension Request {
    var dataType: DataType { return .JSON }
    var parameters: Parameters? { return nil }
    var timeoutInterval: TimeInterval { return 10.0 }
    var authentication: Authentication { return .none }
    var additonalHeaders: Headers? { return nil }

    /// Default headers
    internal var defaultHeaders: Headers {
        // Accept-Encoding HTTP header
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"

        // Accept-Language HTTP header
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")

        // User-Agent header.
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                return getUserAgent(for: info)
            }

            return "Beam-Default"
        }()

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent,
            "Content-Type": "application/json"
        ]
    }

    /// Combines the default headers with any available additional headers.
    var allHeaders: Headers {
        var allHeaders: Headers = self.defaultHeaders

        if let newHeaders = self.additonalHeaders {
            for (header, value) in newHeaders {
                allHeaders[header] = value
            }
        }

        return allHeaders
    }

    /// A string description of the request.
    var description: String {
        return """
        Headers = \(String(describing: self.allHeaders))
        Method = \(self.method.rawValue)
        Data Type = \(self.dataType.rawValue)
        Path = \(self.path)
        Parameters = \(self.parameters != nil ? String(describing: self.parameters) : "none")
        Authorization = \(self.authentication.description)
        """
    }
}

// MARK: - Helpers

extension Request {

    /// Construct the user again string to be passed into the request header.
    ///
    /// - Parameter info: info dictionary pulled from the main bundle.
    /// - Returns: a string representing the use agent header field value.
    private func getUserAgent(for info: [String: Any]) -> String {
        let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
        let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
        let osNameVersion: String = getOsNameVersion()

        return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
    }

    /// Get the correct osNameVersion property for the user agent header.
    ///
    /// - Returns: the os name in string form.
    private func getOsNameVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        let osName: String = {
            #if os(iOS)
                return "iOS"
            #elseif os(watchOS)
                return "watchOS"
            #elseif os(tvOS)
                return "tvOS"
            #else
                return "Unknown"
            #endif
        }()

        return "\(osName) \(versionString)"
    }

}
