//
//  PushSubscriptionNetworkDataSource.swift
//  MagicBell
//
//  Created by Javi on 18/11/21.
//

import Foundation
import Harmony

class PushSubscriptionNetworkDataSource: PutDataSource, DeleteDataSource {
    typealias T = PushSubscription

    private let httpClient: HttpClient
    private let mapper: Mapper<Data, PushSubscription>

    init(
        httpClient: HttpClient,
        mapper: Mapper<Data, PushSubscription>
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func put(_ value: PushSubscription?, in query: Query) -> Future<PushSubscription> {
        switch query {
        case let pushSubscriptionQuery as RegisterPushSubscriptionQuery:
            guard let value = value else {
                return Future(NetworkError(message: "Value cannot be nil"))
            }
            var urlRequest = httpClient.prepareURLRequest(
                path: "/push_subscriptions",
                externalId: pushSubscriptionQuery.user.externalId,
                email: pushSubscriptionQuery.user.email
            )
            urlRequest.httpMethod = "POST"
            do {
                urlRequest.httpBody = try JSONEncoder().encode(value)
            } catch {
                return Future(MappingError(className: "\(T.self)"))
            }

            return self.httpClient
                .performRequest(urlRequest)
                .map { try self.mapper.map($0) }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func putAll(_ array: [PushSubscription], in query: Query) -> Future<[PushSubscription]> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }

    func delete(_ query: Query) -> Future<Void> {
        switch query {
        case let deletePushSubscriptionQuery as DeletePushSubscriptionQuery:
            var urlRequest = self.httpClient.prepareURLRequest(
                path: "/push_subscriptions/\(deletePushSubscriptionQuery.deviceToken)",
                externalId: deletePushSubscriptionQuery.user.externalId,
                email: deletePushSubscriptionQuery.user.email
            )
            urlRequest.httpMethod = "DELETE"

            return self.httpClient
                .performRequest(urlRequest)
                .map { _ in Void() }
        default:
            assertionFailure("Should never happen")
            return Future(CoreError.NotImplemented())
        }
    }

    func deleteAll(_ query: Query) -> Future<Void> {
        assertionFailure("Should never happen")
        return Future(CoreError.NotImplemented())
    }
}
