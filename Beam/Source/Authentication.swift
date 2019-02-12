//
//  Authorization.swift
//  Transmit
//
//  Created by Kyle Begeman on 2/5/18.
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
