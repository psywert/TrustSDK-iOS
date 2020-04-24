// Copyright Trust Wallet. All rights reserved.
//
// This file is part of TrustSDK. The full TrustSDK copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation
import TrustWalletCore

enum CommandName: String {
    case getAccounts = "sdk_get_accounts"
    case sign = "sdk_sign"
    case signAndSend = "sdk_sign_send"
}

enum SignMetadataName: String {
    case dApp = "dapp"
}

public extension TrustSDK {
    enum SignMetadata {
        case dApp(name: String, url: URL?)

        init?(params: [String: Any]) {
            guard
                let nameParam = params["__name"] as? String,
                let name = SignMetadataName(rawValue: nameParam)
            else { return nil }

            switch name {
            case .dApp:
                let name = params["name"] as? String
                let url = params["url"] as? String
                self = .dApp(name: name ?? "", url: URL(string: url ?? ""))
            }
        }

        var name: String {
            let name = { () -> SignMetadataName in
                switch self {
                case .dApp:
                    return .dApp
                }
            }()

            return name.rawValue
        }

        var params: [String: Any] {
            var params = { () -> [String: Any] in
                switch self {
                case .dApp(let name, let url):
                    return [
                        "name": name,
                        "url": url?.absoluteString ?? "",
                    ]
                }
            }()

            params["__name"] = self.name
            return params
        }
    }

    enum Command {
        case sign(coin: CoinType, input: Data, submittable: Bool, metadata: SignMetadata?)
        case signAndSend(coin: CoinType, input: Data, metadata: SignMetadata?)
        case getAccounts(coins: [CoinType])

        public var name: String {
            let name = { () -> CommandName in
                switch self {
                case .getAccounts:
                    return .getAccounts
                case .sign, .signAndSend:
                    return .sign
                }
            }()

            return name.rawValue
        }

        public var params: [String: Any] {
            switch self {
            case .getAccounts(let coins):
                return [
                    "coins": coins.map { $0.rawValue },
                ]
            case .sign(let coin, let input, let submittable, let meta):
                return [
                    "coin": coin.rawValue.description,
                    "data": input.base64UrlEncodedString(),
                    "send": false,
                    "submittable": submittable,
                    "meta": meta?.params ?? [:],
                ]
            case .signAndSend(let coin, let input, let meta):
                return [
                    "coin": coin.rawValue.description,
                    "data": input.base64UrlEncodedString(),
                    "send": true,
                    "submittable": true,
                    "meta": meta?.params ?? [:],
                ]
            }
        }

        public init?(name: String, params: [String: Any]) {
            switch CommandName(rawValue: name) {
            case .getAccounts:
                guard let coinsParam = params["coins"] as? [String: String] else {
                    return nil
                }

                self = .getAccounts(
                    coins: coinsParam
                        .mapKeys { UInt32($0) }
                        .sorted { $0.key < $1.key }
                        .compactMap { $0.value.toCoin() }
                )
            case .sign:
                guard
                    let coinParam = params["coin"] as? String,
                    let dataParam = params["data"] as? String,
                    let coin = coinParam.toCoin(),
                    let data = dataParam.toBase64Data()
                else {
                    return nil
                }
                let metaParam = params["meta"] as? [String: Any]
                let sendParam = params["send"] as? String
                let submittable = (params["submittable"] as? String)?.toBool()
                if let send = sendParam, send.toBool() {
                    self = .signAndSend(
                        coin: coin,
                        input: data,
                        metadata: SignMetadata(params: metaParam ?? [:])
                    )
                } else {
                    self = .sign(
                        coin: coin,
                        input: data,
                        submittable: submittable ?? false,
                        metadata: SignMetadata(params: metaParam ?? [:])
                    )
                }

            default:
                return nil
            }
        }

        public init?(components: URLComponents) {
            guard let name = components.host else { return nil }
            self.init(name: name, params: Dictionary(queryItems: components.queryItems ?? []))
        }
    }
}

extension TrustSDK.SignMetadata: Equatable {}
extension TrustSDK.Command: Equatable {}
