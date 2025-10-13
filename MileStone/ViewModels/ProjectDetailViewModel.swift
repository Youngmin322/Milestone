//
//  ProjectDetailViewModel.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI

@Observable
class ProjectDetailViewModel {
    var project: Project
     var isEditMode = false
     var expandedSections: Set<String> = ["overview", "details", "links"]
     var selectedPhoto: PhotosPickerItem?
     var selectedImages: [PhotosPickerItem] = []
    
    init(project: Project) {
        self.project = project
    }
    
    var statusColor: Color {
        switch project.status {
        case .inProgress: return .orange
        case .completed: return .green
        case .launched: return .blue
        }
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        let start = formatter.string(from: project.startDate)
        if let end = project.endDate {
            let endStr = formatter.string(from: end)
            return "\(start) - \(endStr)"
        } else {
            return "\(start) - 현재"
        }
    }
    
    func toggleEditMode() {
        
    }
    
    func toggleFavorite() {
        
    }
    
    func toggleSection() {
        
    }
    
    func isSectionExpanded() {
        
    }
    
    func addTechStack() {
        
    }
    
    func removeTechStack() {
        
    }
    
    func addKeyFeature() {
        
    }
}
