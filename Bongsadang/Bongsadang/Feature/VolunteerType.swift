//
//  VolunteerType.swift
//  Bongsadang
//
//  Created by 박정우 on 11/6/25.
//
import Foundation

enum VolunteerType: String, CaseIterable, Identifiable, Codable {
    case ENVIRONMENTAL
    case ELDERLY_CARE
    case CHILDREN_CARE
    case DISABLED_CARE
    case EDUCATION
    case COMMUNITY
    case MEDICAL
    case ANIMAL
    case DISASTER_RELIEF
    case CULTURAL
    case SPORTS
    case PLOGGING
    case OTHER

    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .ENVIRONMENTAL: return "환경"
        case .ELDERLY_CARE: return "노인 돌봄"
        case .CHILDREN_CARE: return "아동 돌봄"
        case .DISABLED_CARE: return "장애인 돌봄"
        case .EDUCATION: return "교육"
        case .COMMUNITY: return "지역사회"
        case .MEDICAL: return "의료"
        case .ANIMAL: return "동물"
        case .DISASTER_RELIEF: return "재난 구호"
        case .CULTURAL: return "문화"
        case .SPORTS: return "스포츠"
        case .PLOGGING: return "플로깅"
        case .OTHER: return "기타"
        }
    }
}

