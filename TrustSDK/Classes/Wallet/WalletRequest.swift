// Copyright DApps Platform Inc. All rights reserved.
//
// This file is part of TrustSDK. The full TrustSDK copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public extension WalletSDK {
    struct Request: Equatable {
        enum Keys: String {
            case app, callback, id
        }

        public let command: TrustSDK.Command
        public let app: String
        public let callback: String
        public let id: String

        public init?(command name: String, params: [String: String]) {
            guard
                let command = TrustSDK.Command(name: name, params: params),
                let app = params[Keys.app.rawValue],
                let callback = params[Keys.callback.rawValue],
                let id = params[Keys.id.rawValue] else {
                    return nil
            }

            self.command = command
            self.app = app
            self.callback = callback
            self.id = id
        }

        public init?(components: URLComponents) {
            guard let name = components.host else { return nil }
            self.init(command: name, params: components.queryItemsDictionary())
        }

        func callbackUrl(response: Response) -> URL? {
            guard
            let baseUrl = URL(string: "\(app)://\(callback)"),
            var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
            else { return nil }

            var params = response.params
            params[Keys.id.rawValue] = id

            components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }

            return components.url
        }
    }
}
