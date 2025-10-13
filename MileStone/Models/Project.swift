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
    var title: String
    var projectDescription: String
    var techStack: [String]
    var startDate: Date
    var endDate: Date?
    var thumbnail: Data?
    
    init(title: String, projectDescription: String, techStack: [String], startDate: Date, endDate: Date? = nil, thumbnail: Data? = nil) {
        self.title = title
        self.projectDescription = projectDescription
        self.techStack = techStack
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnail = thumbnail
    }
}

