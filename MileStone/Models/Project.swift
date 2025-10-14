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
    // 기본 정보
    var title: String
    var tagline: String // 한 줄 설명
    var projectDescription: String
    var techStack: [String]
    var startDate: Date
    var endDate: Date?
    var status: ProjectStatus // 진행중/완료 등
    
    // 이미지
    var thumbnail: Data?
    var images: [Data] // 추가 이미지들
    
    // 핵심 정보
    var role: String
    var teamSize: String
    var projectType: ProjectType
    
    // 프로젝트 상세
    var problem: String
    var solution: String
    var goals: String
    var keyFeatures: [String]
    var challenges: String
    
    // 링크
    var githubURL: String?
    var liveURL: String?
    var figmaURL: String?
    
    // 메타
    var notes: String // 메모 및 회고
    var tags: [String]
    var isFavorite: Bool
    
    var enabledSections: Set<String> = []
    
    init(
        title: String,
        tagline: String = "",
        projectDescription: String,
        techStack: [String],
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
        isFavorite: Bool = false
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
    }
}

enum ProjectStatus: String, Codable {
    case inProgress = "진행중"
    case completed = "완료"
    case launched = "런칭됨"
}

enum ProjectType: String, Codable {
    case personal = "개인"
    case team = "팀"
}
