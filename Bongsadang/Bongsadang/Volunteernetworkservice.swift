import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
}

class VolunteerNetworkService: ObservableObject {
    static let shared = VolunteerNetworkService()
    
    private let baseURL = "https://mouse-loud-muscle-advanced.trycloudflare.com"
    private let accessToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzIiwiZW1haWwiOiJ0ZXN0MyIsInJvbGUiOiJVU0VSIiwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc2MjM5MzI1NywiZXhwIjozNzc2MjM5MzI1N30._REdzmHO709wnl5blidGHLfx8EnKaJmPOBz0THpr5zw_HETq2ox2sEFvp6VALJPCLiBhDU9HLj_ilHKpW4VylQ"
    
    @Published var volunteers: [VolunteerData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Network Logging
    private func logRequest(_ request: URLRequest) {
        print("🌐 ========== REQUEST ==========")
        print("🔵 URL: \(request.url?.absoluteString ?? "nil")")
        print("🔵 Method: \(request.httpMethod ?? "nil")")
        print("🔵 Headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            // Token을 마스킹해서 출력
            if key == "Authorization" {
                let maskedToken = maskToken(value)
                print("   \(key): \(maskedToken)")
            } else {
                print("   \(key): \(value)")
            }
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("🔵 Body:")
            if let jsonData = bodyString.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            } else {
                print(bodyString)
            }
        }
        print("================================\n")
    }
    
    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        print("🌐 ========== RESPONSE ==========")
        
        if let error = error {
            print("🔴 Error: \(error.localizedDescription)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 ? "✅" : "❌"
            print("\(statusEmoji) Status Code: \(httpResponse.statusCode)")
            print("🔵 URL: \(httpResponse.url?.absoluteString ?? "nil")")
            print("🔵 Headers:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("   \(key): \(value)")
            }
        }
        
        if let data = data {
            print("🔵 Response Data (\(data.count) bytes):")
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print(prettyString)
            } else if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
        }
        
        print("================================\n")
    }
    
    private func maskToken(_ token: String) -> String {
        guard token.count > 20 else { return "***" }
        let prefix = token.prefix(10)
        let suffix = token.suffix(10)
        return "\(prefix)...\(suffix)"
    }
    
    // Fetch nearby volunteers
    func fetchNearbyVolunteers(latitude: Double, longitude: Double, radiusKm: Double = 10.0) async throws -> [VolunteerData] {
        guard let url = URL(string: "\(baseURL)/volunteers/nearby") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let requestBody = NearbyVolunteersRequest(
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        // Log request
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Log response
        logResponse(response, data: data, error: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(APIResponse<[VolunteerData]>.self, from: data)
            print("✅ Successfully decoded \(apiResponse.data.count) volunteers")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            logResponse(response, data: data, error: error)
            throw NetworkError.decodingError
        }
    }
    
    // Fetch nearby volunteers with published state update
    @MainActor
    func loadNearbyVolunteers(latitude: Double, longitude: Double, radiusKm: Double = 10.0) async {
        isLoading = true
        errorMessage = nil
        
        print("📍 Loading volunteers near: lat=\(latitude), lon=\(longitude), radius=\(radiusKm)km")
        
        do {
            let fetchedVolunteers = try await fetchNearbyVolunteers(
                latitude: latitude,
                longitude: longitude,
                radiusKm: radiusKm
            )
            self.volunteers = fetchedVolunteers
            print("✅ Loaded \(fetchedVolunteers.count) volunteers successfully")
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                self.errorMessage = "잘못된 URL입니다."
                print("🔴 Invalid URL")
            case .invalidResponse:
                self.errorMessage = "서버 응답이 올바르지 않습니다."
                print("🔴 Invalid Response")
            case .decodingError:
                self.errorMessage = "데이터 처리 중 오류가 발생했습니다."
                print("🔴 Decoding Error")
            case .serverError(let message):
                self.errorMessage = "서버 오류: \(message)"
                print("🔴 Server Error: \(message)")
            case .unauthorized:
                self.errorMessage = "인증에 실패했습니다."
                print("🔴 Unauthorized")
            }
        } catch {
            self.errorMessage = "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
            print("🔴 Unknown Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
