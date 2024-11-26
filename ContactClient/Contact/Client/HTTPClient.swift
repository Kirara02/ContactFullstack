//
//  HTTPClient.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum HTTPError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int, String)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The response from the server is invalid."
        case .statusCode(let code, let message):
            return "Request failed with status code \(code). Error: \(message)"
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}


class HTTPClient {
    private let urlSession = URLSession.shared
    
    // Request method
    func request<T: Codable>(url: URL, method: HTTPMethod, body: T? = nil) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        // Check if the response is valid
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        
        // Handle non-2xx HTTP status codes
        if (200...299).contains(httpResponse.statusCode) {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } else {
            // Attempt to decode the error message from the response body (if any)
            var errorMessage: String = "Error to parse message"
            do {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorResponse["message"] {
                    errorMessage = message
                } else {
                    errorMessage = "Unknown error occurred"
                }
            }
            throw HTTPError.statusCode(httpResponse.statusCode, errorMessage)
        }
    }
    
    func requestWithoutBody(url: URL, method: HTTPMethod, headers: [String: String] = [:]) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to decode the error message from the response body (if any)
            var errorMessage: String = "Unknown error occurred"
            do {
                // Decode error response from the 'data' object (response body)
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorResponse["message"] {
                    errorMessage = message
                }
            }
            
            throw HTTPError.statusCode(httpResponse.statusCode, errorMessage)
        }
    }

}
