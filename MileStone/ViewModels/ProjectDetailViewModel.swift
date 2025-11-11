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
    var expandedSections: Set<String> = []
    var selectedPhoto: PhotosPickerItem?
    var selectedImages: [PhotosPickerItem] = []
    var showingAddSectionSheet = false
    
    // MARK: - Section Types
    enum OptionalSection: String, CaseIterable, Identifiable {
        case overview = "프로젝트 개요"
        case details = "상세 내용"
        case visuals = "비주얼 자료"
        case links = "링크"
        case notes = "메모 & 회고"
        case tags = "태그"
        
        var id: String { rawValue }
    }
    
    init(project: Project) {
        self.project = project
    }
    
    // MARK: - Computed Properties
    var statusColor: Color {
        switch project.status {
        case .inProgress: return .orange
        case .completed: return .green
        case .launched: return .blue
        }
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = project.startDate
        let end = project.endDate ?? Date()
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    var activeSections: [OptionalSection] {
        var sections: [OptionalSection] = []
        
        if hasOverviewContent {
            sections.append(.overview)
        }
        if hasDetailsContent {
            sections.append(.details)
        }
        if hasVisualsContent {
            sections.append(.visuals)
        }
        if hasLinksContent {
            sections.append(.links)
        }
        if hasNotesContent {
            sections.append(.notes)
        }
        if hasTagsContent {
            sections.append(.tags)
        }
        
        return sections
    }
    
    var availableSectionsToAdd: [OptionalSection] {
        OptionalSection.allCases.filter { section in
            switch section {
            case .overview: return !hasOverviewContent
            case .details: return !hasDetailsContent
            case .visuals: return !hasVisualsContent
            case .links: return !hasLinksContent
            case .notes: return !hasNotesContent
            case .tags: return !hasTagsContent
            }
        }
    }
    
    // MARK: - Content Checks
    var hasOverviewContent: Bool {
        !project.problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !project.solution.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !project.goals.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        project.enabledSections.contains("프로젝트 개요")
    }
    
    var hasDetailsContent: Bool {
        !project.keyFeatures.isEmpty ||
        !project.challenges.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        project.enabledSections.contains("상세 내용")
    }
    
    var hasVisualsContent: Bool {
        !project.images.isEmpty ||
        project.enabledSections.contains("비주얼 자료")
    }
    
    var hasLinksContent: Bool {
        (project.githubURL != nil && !project.githubURL!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ||
        (project.liveURL != nil && !project.liveURL!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ||
        (project.figmaURL != nil && !project.figmaURL!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ||
        project.enabledSections.contains("링크")
    }
    
    var hasNotesContent: Bool {
        !project.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        project.enabledSections.contains("메모 & 회고")
    }
    
    var hasTagsContent: Bool {
        !project.tags.isEmpty ||
        project.enabledSections.contains("태그")
    }
    
    // MARK: - Actions
    func toggleEditMode() {
        isEditMode.toggle()
        
        if !isEditMode {
            cleanUpEmptyValues()
        }
    }
    
    func toggleFavorite() {
        project.isFavorite.toggle()
    }
    
    func toggleSection(_ sectionId: String) {
        withAnimation {
            if expandedSections.contains(sectionId) {
                expandedSections.remove(sectionId)
            } else {
                expandedSections.insert(sectionId)
            }
        }
    }
    
    func isSectionExpanded(_ sectionId: String) -> Bool {
        expandedSections.contains(sectionId)
    }
    
    func addSection(_ section: OptionalSection) {
        withAnimation {
            expandedSections.insert(section.rawValue)
            
            // enabledSections에 추가하여 영구 저장 (Set이므로 insert 사용)
            project.enabledSections.insert(section.rawValue)
            
            switch section {
            case .overview:
                break
            case .details:
                if project.keyFeatures.isEmpty {
                    project.keyFeatures = [""]
                }
            case .visuals:
                break
            case .links:
                break
            case .notes:
                break
            case .tags:
                if project.tags.isEmpty {
                    project.tags = [""]
                }
            }
        }
        showingAddSectionSheet = false
    }

    func deleteSection(_ section: OptionalSection) {
        withAnimation {
            expandedSections.remove(section.rawValue)
            
            // enabledSections에서 제거
            project.enabledSections.remove(section.rawValue)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                switch section {
                case .overview:
                    self.project.problem = ""
                    self.project.solution = ""
                    self.project.goals = ""
                case .details:
                    self.project.keyFeatures = []
                    self.project.challenges = ""
                case .visuals:
                    self.project.images = []
                case .links:
                    self.project.githubURL = nil
                    self.project.liveURL = nil
                    self.project.figmaURL = nil
                case .notes:
                    self.project.notes = ""
                case .tags:
                    self.project.tags = []
                }
            }
        }
    }
    
    // MARK: - Tech Stack Management
    func addTechStack() {
        project.techStack.append("")
    }
    
    func removeTechStack(at index: Int) {
        guard project.techStack.indices.contains(index) else { return }
        project.techStack.remove(at: index)
    }
    
    func updateTechStack(at index: Int, with value: String) {
        guard project.techStack.indices.contains(index) else { return }
        project.techStack[index] = value
    }
    
    // MARK: - Key Features Management
    func addKeyFeature() {
        project.keyFeatures.append("")
    }
    
    func removeKeyFeature(at index: Int) {
        guard project.keyFeatures.indices.contains(index) else { return }
        project.keyFeatures.remove(at: index)
    }
    
    func updateKeyFeature(at index: Int, with value: String) {
        guard project.keyFeatures.indices.contains(index) else { return }
        project.keyFeatures[index] = value
    }
    
    // MARK: - Tags Management
    func addTag() {
        project.tags.append("")
    }
    
    func removeTag(at index: Int) {
        guard project.tags.indices.contains(index) else { return }
        project.tags.remove(at: index)
    }
    
    func updateTag(at index: Int, with value: String) {
        guard project.tags.indices.contains(index) else { return }
        project.tags[index] = value
    }
    
    // MARK: - Image Management
    func removeImage(at index: Int) {
        guard project.images.indices.contains(index) else { return }
        project.images.remove(at: index)
    }
    
    func handleThumbnailSelection() async {
        guard let selectedPhoto else { return }
        if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
            project.thumbnail = data
        }
    }
    
    func handleImagesSelection() async {
        var newImagesData: [Data] = []
        for item in selectedImages {
            if let data = try? await item.loadTransferable(type: Data.self) {
                newImagesData.append(data)
            }
        }
        project.images.append(contentsOf: newImagesData)
        selectedImages.removeAll()
    }
    
    // MARK: - URL Management
    func updateGithubURL(_ value: String) {
        project.githubURL = value.isEmpty ? nil : value
    }
    
    func updateLiveURL(_ value: String) {
        project.liveURL = value.isEmpty ? nil : value
    }
    
    func updateFigmaURL(_ value: String) {
        project.figmaURL = value.isEmpty ? nil : value
    }
    
    private func cleanUpEmptyValues() {
        project.techStack.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        project.keyFeatures.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        project.tags.removeAll { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
