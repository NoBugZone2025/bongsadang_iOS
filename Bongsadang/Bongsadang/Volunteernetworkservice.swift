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
    private let accessToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiZW1haWwiOiJhc2RmIiwicm9sZSI6IlVTRVIiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzYyNDAzOTA2LCJleHAiOjM3NzYyNDAzOTA2fQ.VmZqX_n5kNOHyXKSXTN1rlDDR6ct7fxOgzTDj2Ku8FnuhVtuvTq-5cBlVf9Fju7y-ggkmgOlnlW_egCm0qPhLQ"
    
    @Published var volunteers: [VolunteerData] = []
    @Published var rankings: [RankingUser] = []
    @Published var userInfo: UserInfo?
    @Published var completedVolunteers: [VolunteerData] = []
    @Published var myVolunteers: [VolunteerData] = []
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
    
    // MARK: - Fetch User Info
    func fetchUserInfo() async throws -> UserInfo {
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        logResponse(response, data: data, error: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 Error Response: \(errorString)")
                throw NetworkError.serverError(errorString)
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(APIResponse<UserInfo>.self, from: data)
            print("✅ Successfully fetched user info: \(apiResponse.data.name)")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    @MainActor
    func loadUserInfo() async {
        isLoading = true
        errorMessage = nil
        
        print("👤 Loading user info...")
        
        do {
            let fetchedUserInfo = try await fetchUserInfo()
            self.userInfo = fetchedUserInfo
            print("✅ Loaded user info successfully: \(fetchedUserInfo.name)")
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
    
    // MARK: - Fetch Rankings
    func fetchRankings() async throws -> [RankingUser] {
        guard let url = URL(string: "\(baseURL)/ranking") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        logResponse(response, data: data, error: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 Error Response: \(errorString)")
                throw NetworkError.serverError(errorString)
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(APIResponse<[RankingUser]>.self, from: data)
            print("✅ Successfully decoded \(apiResponse.data.count) rankings")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    @MainActor
    func loadRankings() async {
        isLoading = true
        errorMessage = nil
        
        print("🏆 Loading rankings...")
        
        do {
            let fetchedRankings = try await fetchRankings()
            self.rankings = fetchedRankings
            print("✅ Loaded \(fetchedRankings.count) rankings successfully")
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
    
    // MARK: - Participate in Volunteer
    func participateInVolunteer(volunteerId: Int) async throws -> VolunteerData {
        guard let url = URL(string: "\(baseURL)/volunteers/\(volunteerId)/participate") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        logResponse(response, data: data, error: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 Error Response: \(errorString)")
                throw NetworkError.serverError(errorString)
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let apiResponse = try JSONDecoder().decode(APIResponse<VolunteerData>.self, from: data)
            print("✅ Successfully participated in volunteer activity: \(apiResponse.data.title)")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }

    @MainActor
    func participateAndStartActivity(volunteerId: Int) async -> VolunteerData? {
        isLoading = true
        errorMessage = nil
        
        print("🎯 Participating in volunteer activity ID: \(volunteerId)")
        
        do {
            let participatedVolunteer = try await participateInVolunteer(volunteerId: volunteerId)
            print("✅ Participation successful: \(participatedVolunteer.title)")
            isLoading = false
            return participatedVolunteer
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                self.errorMessage = "잘못된 URL입니다."
            case .invalidResponse:
                self.errorMessage = "서버 응답이 올바르지 않습니다."
            case .decodingError:
                self.errorMessage = "데이터 처리 중 오류가 발생했습니다."
            case .serverError(let message):
                self.errorMessage = "서버 오류: \(message)"
            case .unauthorized:
                self.errorMessage = "인증에 실패했습니다."
            }
        } catch {
            self.errorMessage = "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
        return nil
    }
    
    // MARK: - Fetch Nearby Volunteers
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
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
    
    // MARK: - Fetch Completed Volunteers
    func fetchCompletedVolunteers() async throws -> [VolunteerData] {
        guard let url = URL(string: "\(baseURL)/volunteers/completed") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
            print("✅ Successfully decoded \(apiResponse.data.count) completed volunteers")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            logResponse(response, data: data, error: error)
            throw NetworkError.decodingError
        }
    }
    
    @MainActor
    func loadCompletedVolunteers() async {
        isLoading = true
        errorMessage = nil
        
        print("✅ Loading completed volunteers...")
        
        do {
            let fetchedVolunteers = try await fetchCompletedVolunteers()
            self.completedVolunteers = fetchedVolunteers
            print("✅ Loaded \(fetchedVolunteers.count) completed volunteers successfully")
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

    // MARK: - Fetch My Volunteers
    func fetchMyVolunteers() async throws -> [VolunteerData] {
        guard let url = URL(string: "\(baseURL)/volunteers/my") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        logRequest(request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
            print("✅ Successfully decoded \(apiResponse.data.count) my volunteers")
            return apiResponse.data
        } catch {
            print("🔴 Decoding error: \(error)")
            logResponse(response, data: data, error: error)
            throw NetworkError.decodingError
        }
    }
    
    @MainActor
    func loadMyVolunteers() async {
        isLoading = true
        errorMessage = nil
        
        print("✅ Loading my volunteers...")
        
        do {
            let fetchedVolunteers = try await fetchMyVolunteers()
            self.myVolunteers = fetchedVolunteers
            print("✅ Loaded \(fetchedVolunteers.count) my volunteers successfully")
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

    // MARK: - Create Volunteer
    func createVolunteer(request: CreateVolunteerRequest) async throws -> VolunteerData {
        guard let url = URL(string: "\(baseURL)/volunteers") else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        urlRequest.httpBody = try encoder.encode(request)
        
        logRequest(urlRequest)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        logResponse(response, data: data, error: nil)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Handle different status codes with more specific errors
        switch httpResponse.statusCode {
        case 200, 201:
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse<VolunteerData>.self, from: data)
                print("✅ Successfully created volunteer activity with ID: \(apiResponse.data.id)")
                return apiResponse.data
            } catch {
                print("🔴 Decoding error: \(error)")
                if let errorString = String(data: data, encoding: .utf8) {
                    print("🔴 Raw response: \(errorString)")
                }
                throw NetworkError.decodingError
            }
        case 400:
            // Parse error message from response
            if let errorString = String(data: data, encoding: .utf8) {
                print("🔴 400 Bad Request - Response: \(errorString)")
                throw NetworkError.serverError("잘못된 요청: \(errorString)")
            }
            throw NetworkError.serverError("잘못된 요청 (400)")
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.serverError("접근 권한이 없습니다 (403)")
        case 404:
            throw NetworkError.serverError("요청한 리소스를 찾을 수 없습니다 (404)")
        case 500...599:
            throw NetworkError.serverError("서버 오류 (\(httpResponse.statusCode))")
        default:
            throw NetworkError.serverError("알 수 없는 오류 (Status code: \(httpResponse.statusCode))")
        }
    }
    
    @MainActor
    func createAndLoadVolunteer(request: CreateVolunteerRequest) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        print("📝 Creating volunteer activity: \(request.title)")
        
        do {
            let createdVolunteer = try await createVolunteer(request: request)
            print("✅ Created volunteer successfully: \(createdVolunteer.title)")
            
            await loadNearbyVolunteers(
                latitude: request.latitude,
                longitude: request.longitude,
                radiusKm: 10.0
            )
            
            isLoading = false
            return true
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
        return false
    }
}
