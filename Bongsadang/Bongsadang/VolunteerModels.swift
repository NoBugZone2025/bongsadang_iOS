import Foundation
import CoreLocation

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
    
    var formattedStartDate: String {
        formatDate(startDateTime)
    }
    
    var formattedTimeRange: String {
        let start = formatTime(startDateTime)
        let end = formatTime(endDateTime)
        return "\(start)-\(end)"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd"
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return displayFormatter.string(from: date)
    }
    
    private func formatTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        displayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return displayFormatter.string(from: date)
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
