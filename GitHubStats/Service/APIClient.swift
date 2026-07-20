//
//  APIClient.swift
//  GitHubStats
//
//  Created by João Pedro Volponi on 19/07/26.
//

import Foundation

enum APIError: LocalizedError {
    case notFound
    case rateLimited
    case network
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notFound:
            "Usuário não encontrado. Verifique o nome e tente novamente."
        case .rateLimited:
            "Limite de requisições do GitHub atingido. Aguarde alguns minutos e tente novamente."
        case .network:
            "Falha de conexão. Verifique sua internet e tente novamente."
        case .invalidResponse:
            "Resposta inesperada do servidor. Tente novamente."
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.timeoutIntervalForRequest = 25
        session = URLSession(configuration: configuration)

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            break
        case 404:
            throw APIError.notFound
        case 403, 429:
            throw APIError.rateLimited
        default:
            throw APIError.invalidResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.invalidResponse
        }
    }
}
