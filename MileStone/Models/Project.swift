//
//  Project.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/10/25.
//

import Foundation
import SwiftData

@Model
final class Project {
    // MARK: - Basic Information
    var title: String
    var tagline: String
    var projectDescription: String
    var techStack: [String]
    var startDate: Date
    var endDate: Date?
    var status: ProjectStatus
    
    // MARK: - Media
    var thumbnail: Data?
    var images: [Data]
    
    // MARK: - Project Details
    var role: String
    var teamSize: String
    var projectType: ProjectType
    
    // MARK: - Extended Information
    var problem: String
    var solution: String
    var goals: String
    var keyFeatures: [String]
    var challenges: String
    
    // MARK: - External Links
    var githubURL: String?
    var liveURL: String?
    var figmaURL: String?
    
    // MARK: - Metadata
    var notes: String
    var tags: [String]
    var isFavorite: Bool
    var enabledSections: Set<String>
    
    // MARK: - Computed Properties
    var duration: String {
        let end = endDate ?? Date()
        let days = Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
        
        if days == 0 {
            return "당일"
        } else if days < 30 {
            return "\(days)일"
        } else if days < 365 {
            let months = days / 30
            return "\(months)개월"
        } else {
            let years = days / 365
            let remainingMonths = (days % 365) / 30
            return remainingMonths > 0 ? "\(years)년 \(remainingMonths)개월" : "\(years)년"
        }
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate ?? Date())
        return "\(start) - \(end)"
    }
    
    // MARK: - Initialization
    init(
        title: String,
        tagline: String = "",
        projectDescription: String,
        techStack: [String] = [],
        startDate: Date,
        endDate: Date? = nil,
        status: ProjectStatus = .inProgress,
        thumbnail: Data? = nil,
        images: [Data] = [],
        role: String = "",
        teamSize: String = "",
        projectType: ProjectType = .personal,
        problem: String = "",
        solution: String = "",
        goals: String = "",
        keyFeatures: [String] = [],
        challenges: String = "",
        githubURL: String? = nil,
        liveURL: String? = nil,
        figmaURL: String? = nil,
        notes: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        enabledSections: Set<String> = []
    ) {
        self.title = title
        self.tagline = tagline
        self.projectDescription = projectDescription
        self.techStack = techStack
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.thumbnail = thumbnail
        self.images = images
        self.role = role
        self.teamSize = teamSize
        self.projectType = projectType
        self.problem = problem
        self.solution = solution
        self.goals = goals
        self.keyFeatures = keyFeatures
        self.challenges = challenges
        self.githubURL = githubURL
        self.liveURL = liveURL
        self.figmaURL = figmaURL
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.enabledSections = enabledSections
    }
}

// MARK: - Enums
enum ProjectStatus: String, Codable, CaseIterable {
    case inProgress = "진행중"
    case completed = "완료"
    case launched = "런칭됨"
    
    var color: String {
        switch self {
        case .inProgress: return "orange"
        case .completed: return "green"
        case .launched: return "blue"
        }
    }
}

enum ProjectType: String, Codable, CaseIterable {
    case personal = "개인"
    case team = "팀"
}
