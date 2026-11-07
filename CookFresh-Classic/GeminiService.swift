//
//  GeminiService.swift
//  CookFresh-Classic
//

import Foundation

struct GeminiMessage: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiRequest: Codable {
    let contents: [GeminiMessage]
    let generationConfig: GeminiGenerationConfig?
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
    let error: GeminiError?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]?
    let role: String?
}

struct GeminiError: Codable {
    let message: String?
}

enum GeminiServiceError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Gemini API key is missing. Set it in Settings."
        case .invalidResponse: return "Invalid response from Gemini."
        case .apiError(let m): return m
        case .emptyResponse: return "Gemini returned an empty response."
        }
    }
}

actor GeminiService {
    static let shared = GeminiService()

    private let session = URLSession.shared

    func send(messages: [(role: String, content: String)], apiKey: String, model: String = "gemini-1.5-flash") async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiServiceError.missingAPIKey }

        let contents = messages.map { GeminiMessage(role: $0.role == "assistant" ? "model" : "user", parts: [GeminiPart(text: $0.content)]) }
        let body = GeminiRequest(contents: contents, generationConfig: GeminiGenerationConfig(temperature: 0.7))
        let data = try JSONEncoder().encode(body)

        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else { throw GeminiServiceError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw GeminiServiceError.invalidResponse }
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
        if let err = decoded.error?.message, !err.isEmpty {
            throw GeminiServiceError.apiError(err)
        }
        if http.statusCode >= 400 {
            throw GeminiServiceError.apiError("HTTP \(http.statusCode)")
        }
        guard let text = decoded.candidates?.first?.content?.parts?.first?.text, !text.isEmpty else {
            throw GeminiServiceError.emptyResponse
        }
        return text
    }
}