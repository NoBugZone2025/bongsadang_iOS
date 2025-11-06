import Foundation
import CoreLocation
import SwiftUI

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let status: String
    let message: String
    let data: T
    let timestamp: String
}

struct NearbyVolunteersRequest: Codable {
    let latitude: Double
    let longitude: Double
    let radiusKm: Double
}

// MARK: - Create Volunteer Request
struct CreateVolunteerRequest: Codable {
    let title: String
    let description: String
    let latitude: Double
    let longitude: Double
    let startDateTime: String  // ISO8601 format
    let endDateTime: String    // ISO8601 format
    let maxParticipants: Int
    let visibilityType: String  // "PUBLIC" or "PRIVATE"
    let volunteerType: String   // "PLOGGING", "DELIVERY", etc.
}

struct VolunteerData: Codable, Identifiable, Equatable {
    let id: Int
    let organizerId: Int
    let organizerName: String
    let title: String
    let description: String
    let latitude: Double
    let longitude: Double
    let startDateTime: String
    let endDateTime: String
    let maxParticipants: Int
    let currentParticipants: Int
    let visibilityType: String
    let volunteerType: String
    let status: String
    let createdAt: String
    let updatedAt: String
    
    static func == (lhs: VolunteerData, rhs: VolunteerData) -> Bool {
        lhs.id == rhs.id
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // ✅ 날짜만 표시 (2025.11.07)
    var formattedStartDate: String {
        return formatDateOnly(startDateTime)
    }
    
    // ✅ 시간 범위 표시 (14:00-16:00)
    var formattedTimeRange: String {
        let start = formatTimeOnly(startDateTime)
        let end = formatTimeOnly(endDateTime)
        return "\(start)-\(end)"
    }
    
    // 날짜만 추출 (2025.11.07)
    private func formatDateOnly(_ dateString: String) -> String {
        // "2025-11-07T02:41:06" 형식에서 날짜 부분만 추출
        let components = dateString.split(separator: "T")
        guard let datePart = components.first else { return dateString }
        
        let dateComponents = datePart.split(separator: "-")
        guard dateComponents.count == 3 else { return dateString }
        
        return "\(dateComponents[0]).\(dateComponents[1]).\(dateComponents[2])"
    }
    
    // 시간만 추출 (14:00)
    private func formatTimeOnly(_ dateString: String) -> String {
        // "2025-11-07T02:41:06" 형식에서 시간 부분만 추출
        let components = dateString.split(separator: "T")
        guard components.count == 2 else { return dateString }
        
        let timePart = String(components[1])
        let timeComponents = timePart.split(separator: ":")
        guard timeComponents.count >= 2 else { return dateString }
        
        // 시간 변환 (UTC+0 → UTC+9)
        if let hour = Int(timeComponents[0]) {
            let kstHour = (hour + 9) % 24
            return String(format: "%02d:%@", kstHour, timeComponents[1] as CVarArg)
        }
        
        return "\(timeComponents[0]):\(timeComponents[1])"
    }
}

// MARK: - VolunteerLocation for Map Annotation
struct VolunteerLocation: Identifiable, Equatable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let volunteerData: VolunteerData
    
    static func == (lhs: VolunteerLocation, rhs: VolunteerLocation) -> Bool {
        lhs.id == rhs.id && lhs.coordinate == rhs.coordinate
    }
}

// MARK: - Ranking Models
struct RankingUser: Codable, Identifiable {
    let rank: Int
    let userId: Int
    let userName: String
    let totalPoints: Int
    let currentTitle: String?
    
    var id: Int { userId }
    
    var rankColor: Color {
        switch rank {
        case 1:
            return .gold
        case 2:
            return .silver
        case 3:
            return .bronze
        default:
            return .black
        }
    }
    
    var formattedPoints: String {
        return "\(totalPoints)P"
    }
}

// MARK: - Helper Extensions
extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // 한국 시간대 사용 (KST: UTC+9)
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
}
