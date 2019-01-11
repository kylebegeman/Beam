//
//  Authorization.swift
//  Transmit
//
//  Created by Kyle Begeman on 2/5/18.
//  Copyright © 2018 Kyle Begeman. All rights reserved.
//

import UIKit

public enum Authentication {
    case none
    case basic(user: String, password: String)
    case bearer(token: String)
    case custom(String)

    var description: String {
        switch self {
        case .none:                 return "No authorization"
        case .basic(let user, _):   return "Standard - user=\(user)"
        case .bearer(let token):    return "Bearer - token=\(token)"
        case .custom(let value):    return "Custom - value=\(value)"
        }
    }
}

extension Authentication: Equatable {
    public static func == (lhs: Authentication, rhs: Authentication) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Authentication: RawRepresentable {
    private struct StringValue {
        static let basic = "Basic "
        static let bearer = "Bearer "
    }

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        self = .none

        if rawValue.hasPrefix(StringValue.basic) {
            let base64EncodedString = "\(rawValue[StringValue.basic.endIndex...])"
            if let authorizationData = Data(base64Encoded: base64EncodedString) {
                let authorizationComponents = String(data: authorizationData, encoding: .utf8)?.components(separatedBy: ":")
                if let user: String = authorizationComponents?.first, let password: String = authorizationComponents?.last {
                    self = .basic(user: user, password: password)
                }
            }
        } else if rawValue.hasPrefix(StringValue.bearer) {
            self = .bearer(token: "\(rawValue[StringValue.bearer.endIndex...])")
        } else if !rawValue.isEmpty {
            self = .custom(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .basic(let user, let password):
            let data = "\(user):\(password)".data(using: .utf8)!
            return "\(StringValue.basic)\(data.base64EncodedString())"

        case .bearer(let token):
            return "\(StringValue.bearer)\(token)"

        case .custom(let authorization):
            return authorization
            
        default:
            return ""
        }
    }
}
