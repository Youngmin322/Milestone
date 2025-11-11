//
//  ProjectDetailView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ProjectDetailView: View {
    @State private var viewModel: ProjectDetailViewModel
    
    init(project: Project) {
        _viewModel = State(initialValue: ProjectDetailViewModel(project: project))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 13) {
                HeroSectionView(viewModel: viewModel)
                infoCard
                
                ForEach(viewModel.activeSections) { section in
                    sectionView(for: section)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                toolbarButtons
            }
        }
        .sheet(isPresented: $viewModel.showingAddSectionSheet) {
            addSectionSheet
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task {
                await viewModel.handleThumbnailSelection()
            }
        }
        .onChange(of: viewModel.selectedImages) { _, _ in
            Task {
                await viewModel.handleImagesSelection()
            }
        }
    }
    
    // MARK: - Toolbar
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.project.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(viewModel.project.isFavorite ? .yellow : .gray)
            }
            
            if viewModel.isEditMode && !viewModel.availableSectionsToAdd.isEmpty {
                Button {
                    viewModel.showingAddSectionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            Button {
                viewModel.toggleEditMode()
            } label: {
                Text(viewModel.isEditMode ? "완료" : "편집")
                    .fontWeight(.medium)
            }
        }
    }
    
    // MARK: - Add Section Sheet
    private var addSectionSheet: some View {
        NavigationStack {
            List(viewModel.availableSectionsToAdd) { section in
                Button {
                    viewModel.addSection(section)
                } label: {
                    HStack {
                        Text(section.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("섹션 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        viewModel.showingAddSectionSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Section View Builder
    @ViewBuilder
    private func sectionView(for section: ProjectDetailViewModel.OptionalSection) -> some View {
        switch section {
        case .overview:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.overview) } : nil
            ) {
                overviewSection
            }
        case .details:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.details) } : nil
            ) {
                detailsSection
            }
        case .visuals:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.visuals) } : nil
            ) {
                visualsSection
            }
        case .links:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.links) } : nil
            ) {
                linksSection
            }
        case .notes:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.notes) } : nil
            ) {
                notesSection
            }
        case .tags:
            ExpandableSection(
                id: section.rawValue,
                title: section.rawValue,
                isExpanded: viewModel.isSectionExpanded(section.rawValue),
                onToggle: { viewModel.toggleSection(section.rawValue) },
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.tags) } : nil
            ) {
                tagsSection
            }
        }
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "person.fill", title: "역할", value: $viewModel.project.role)
            Divider().padding(.leading, 44)
            
            infoRow(icon: "person.3.fill", title: "팀 규모", value: $viewModel.project.teamSize)
            Divider().padding(.leading, 44)
            
            HStack(spacing: 16) {
                Label("프로젝트 유형", systemImage: "folder.fill")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 140, alignment: .leading)
                
                if viewModel.isEditMode {
                    Picker("", selection: $viewModel.project.projectType) {
                        Text("개인").tag(ProjectType.personal)
                        Text("팀").tag(ProjectType.team)
                    }
                    .pickerStyle(.segmented)
                } else {
                    Spacer()
                    Text(viewModel.project.projectType.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider().padding(.leading, 44)
            
            techStackSection
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("기술 스택", systemImage: "hammer.fill")
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if viewModel.isEditMode {
                    Button {
                        viewModel.addTechStack()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
            }
            
            if viewModel.project.techStack.isEmpty && !viewModel.isEditMode {
                Text("기술 스택을 추가해보세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.project.techStack.enumerated()), id: \.offset) { index, tech in
                        if viewModel.isEditMode {
                            HStack(spacing: 4) {
                                TextField("기술", text: Binding(
                                    get: { viewModel.project.techStack.indices.contains(index) ? viewModel.project.techStack[index] : "" },
                                    set: { newValue in
                                        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            viewModel.removeTechStack(at: index)
                                        } else {
                                            viewModel.updateTechStack(at: index, with: newValue)
                                        }
                                    }
                                ))
                                .textFieldStyle(.plain)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .frame(minWidth: 60)
                                
                                Button {
                                    viewModel.removeTechStack(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.callout)
                                }
                            }
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(Capsule())
                        } else {
                            Text(tech)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.isEditMode || viewModel.hasOverviewContent {
                AppleStyleTextEditor(
                    title: "문제 정의",
                    text: $viewModel.project.problem,
                    isEditing: viewModel.isEditMode
                )
                
                AppleStyleTextEditor(
                    title: "솔루션",
                    text: $viewModel.project.solution,
                    isEditing: viewModel.isEditMode
                )
                
                AppleStyleTextEditor(
                    title: "목표 및 결과",
                    text: $viewModel.project.goals,
                    isEditing: viewModel.isEditMode
                )
            } else {
                EmptyStateView(
                    icon: "doc.text",
                    message: "프로젝트 개요를 추가해보세요"
                )
            }
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.isEditMode || viewModel.hasDetailsContent {
                keyFeaturesSection
                
                AppleStyleTextEditor(
                    title: "도전 과제",
                    text: $viewModel.project.challenges,
                    isEditing: viewModel.isEditMode,
                    minHeight: 100
                )
            } else {
                EmptyStateView(
                    icon: "list.bullet.clipboard",
                    message: "상세 내용을 추가해보세요"
                )
            }
        }
    }
    
    private var keyFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("주요 기능")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if viewModel.isEditMode {
                    Button {
                        viewModel.addKeyFeature()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
            }
            
            if viewModel.project.keyFeatures.isEmpty && !viewModel.isEditMode {
                Text("주요 기능을 추가해보세요")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.project.keyFeatures.enumerated()), id: \.offset) { index, feature in
                        HStack(alignment: .center, spacing: 12) {
                            if !viewModel.isEditMode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.body)
                            }
                            
                            if viewModel.isEditMode {
                                TextField("기능", text: Binding(
                                    get: { viewModel.project.keyFeatures.indices.contains(index) ? viewModel.project.keyFeatures[index] : "" },
                                    set: { viewModel.updateKeyFeature(at: index, with: $0) }
                                ), axis: .vertical)
                                .textFieldStyle(.plain)
                                .font(.body)
                                
                                Button {
                                    viewModel.removeKeyFeature(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.body)
                                }
                            } else {
                                Text(feature)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        
                        if index < viewModel.project.keyFeatures.count - 1 {
                            Divider()
                                .padding(.leading, viewModel.isEditMode ? 16 : 52)
                        }
                    }
                }
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    // MARK: - Visuals Section
    private var visualsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isEditMode {
                PhotosPicker(selection: $viewModel.selectedImages, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .font(.title3)
                        Text("이미지 추가")
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .foregroundColor(.blue)
                    .padding(16)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            if !viewModel.project.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.project.images.enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 160, height: 160)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    if viewModel.isEditMode {
                                        Button {
                                            viewModel.removeImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.white, .black.opacity(0.4))
                                                .background(
                                                    Circle()
                                                        .fill(.ultraThinMaterial)
                                                        .frame(width: 28, height: 28)
                                                )
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                        }
                    }
                }
            } else if !viewModel.isEditMode {
                EmptyStateView(
                    icon: "photo",
                    message: "추가된 이미지가 없습니다"
                )
            }
        }
    }
    
    // MARK: - Links Section
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditMode {
                VStack(spacing: 0) {
                    AppleStyleURLField(
                        title: "GitHub",
                        icon: "link.circle.fill",
                        url: Binding(
                            get: { viewModel.project.githubURL ?? "" },
                            set: { viewModel.updateGithubURL($0) }
                        )
                    )
                    
                    Divider().padding(.leading, 44)
                    
                    AppleStyleURLField(
                        title: "Live Site",
                        icon: "globe",
                        url: Binding(
                            get: { viewModel.project.liveURL ?? "" },
                            set: { viewModel.updateLiveURL($0) }
                        )
                    )
                    
                    Divider().padding(.leading, 44)
                    
                    AppleStyleURLField(
                        title: "Figma",
                        icon: "pencil.and.outline",
                        url: Binding(
                            get: { viewModel.project.figmaURL ?? "" },
                            set: { viewModel.updateFigmaURL($0) }
                        )
                    )
                }
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                VStack(spacing: 8) {
                    if let githubURL = viewModel.project.githubURL, !githubURL.isEmpty {
                        LinkRow(title: "GitHub", url: githubURL, icon: "link.circle.fill")
                    }
                    if let liveURL = viewModel.project.liveURL, !liveURL.isEmpty {
                        LinkRow(title: "Live Site", url: liveURL, icon: "globe")
                    }
                    if let figmaURL = viewModel.project.figmaURL, !figmaURL.isEmpty {
                        LinkRow(title: "Figma", url: figmaURL, icon: "pencil.and.outline")
                    }
                }
                
                if !viewModel.hasLinksContent {
                    EmptyStateView(
                        icon: "link",
                        message: "링크를 추가해보세요"
                    )
                }
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditMode {
                AppleStyleTextEditor(
                    title: "메모 & 회고",
                    text: $viewModel.project.notes,
                    isEditing: true,
                    minHeight: 120
                )
            } else {
                if !viewModel.project.notes.isEmpty {
                    Text(viewModel.project.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    EmptyStateView(
                        icon: "note.text",
                        message: "메모를 추가해보세요"
                    )
                }
            }
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditMode {
                HStack {
                    Text("태그")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Button {
                        viewModel.addTag()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
                
                if viewModel.project.tags.isEmpty {
                    Text("태그를 추가해보세요")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.project.tags.enumerated()), id: \.offset) { index, tag in
                            HStack(spacing: 12) {
                                TextField("태그", text: Binding(
                                    get: { viewModel.project.tags.indices.contains(index) ? viewModel.project.tags[index] : "" },
                                    set: { viewModel.updateTag(at: index, with: $0) }
                                ))
                                .textFieldStyle(.plain)
                                .font(.body)
                                
                                Button {
                                    viewModel.removeTag(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.body)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            
                            if index < viewModel.project.tags.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.project.tags.enumerated()), id: \.offset) { index, tag in
                        if !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(tag)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                if viewModel.project.tags.isEmpty || viewModel.project.tags.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    EmptyStateView(
                        icon: "tag",
                        message: "태그를 추가해보세요"
                    )
                }
            }
        }
    }
    
    // MARK: - Info Row
    private func infoRow(icon: String, title: String, value: Binding<String>) -> some View {
        HStack(spacing: 16) {
            Label(title, systemImage: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 140, alignment: .leading)
            
            if viewModel.isEditMode {
                TextField(title, text: value)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .font(.body)
                    .foregroundStyle(.primary)
            } else {
                Spacer()
                Text(value.wrappedValue.isEmpty ? "-" : value.wrappedValue)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Apple Style Components

struct AppleStyleTextEditor: View {
    let title: String
    @Binding var text: String
    var isEditing: Bool
    var minHeight: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("내용을 입력하세요")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: minHeight)
                        .font(.body)
                }
                .padding(12)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                if !text.isEmpty {
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("-")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

struct AppleStyleURLField: View {
    let title: String
    let icon: String
    @Binding var url: String
    
    var body: some View {
        HStack(spacing: 16) {
            Label(title, systemImage: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 140, alignment: .leading)
            
            TextField("URL 입력", text: $url)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundStyle(.primary)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textContentType(.URL)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.quaternary)
                .font(.title3)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Expandable Section
struct ExpandableSection<Content: View>: View {
    let id: String
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let onDelete: (() -> Void)?
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .center, spacing: 12) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "minus.circle.fill")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: isExpanded ? 0 : 12,
                        bottomTrailingRadius: isExpanded ? 0 : 12,
                        topTrailingRadius: 12
                    )
                )
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    content
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 0
                    )
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

// MARK: - Link Row
struct LinkRow: View {
    let title: String
    let url: String
    let icon: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .font(.title3)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: sampleProject)
            .modelContainer(for: Project.self, inMemory: true)
    }
}

// MARK: - Sample Data
private let sampleProject: Project = {
    let project = Project(
        title: "AI 기반 할일 관리 앱",
        tagline: "머신러닝으로 우선순위를 자동 정렬하는 스마트 투두 앱",
        projectDescription: "사용자의 패턴을 학습하여 할일의 우선순위를 자동으로 정렬하고, 최적의 일정을 제안하는 iOS 앱입니다.",
        techStack: ["Swift", "SwiftUI", "Core ML", "CloudKit", "Combine"],
        startDate: Date().addingTimeInterval(-90 * 24 * 60 * 60),
        endDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
        status: .launched,
        thumbnail: nil,
        images: [],
        role: "iOS 개발 리드",
        teamSize: "4명 (디자이너 1, 백엔드 1, iOS 2)",
        projectType: .team,
        problem: "기존 할일 관리 앱들은 사용자가 직접 우선순위를 설정해야 하고, 일정 관리가 번거로워 많은 사용자가 중도 포기하는 문제가 있었습니다.",
        solution: "Core ML을 활용하여 사용자의 할일 완료 패턴을 학습하고, 시간대별 생산성을 분석하여 자동으로 우선순위를 조정하는 시스템을 구현했습니다.",
        goals: "월 활성 사용자(MAU) 10,000명 달성, 앱스토어 생산성 카테고리 Top 100 진입. 실제로 3개월 만에 MAU 15,000명을 달성하고 카테고리 42위까지 올랐습니다.",
        keyFeatures: [
            "ML 기반 우선순위 자동 정렬",
            "시간대별 생산성 분석 대시보드",
            "자연어 처리를 통한 빠른 할일 입력",
            "팀 협업을 위한 공유 프로젝트 기능",
            "위젯 및 시리 단축어 지원"
        ],
        challenges: "Core ML 모델의 정확도를 높이는 과정에서 어려움이 있었습니다. 초기에는 단순한 규칙 기반 알고리즘을 사용했지만, 사용자 피드백을 바탕으로 개인화된 학습 모델로 전환했습니다.",
        githubURL: "https://github.com/username/smart-todo-app",
        liveURL: "https://apps.apple.com/app/smart-todo",
        figmaURL: "https://figma.com/file/abc123/smart-todo-design",
        notes: "이 프로젝트를 통해 머신러닝을 실제 제품에 적용하는 경험을 쌓을 수 있었습니다. 특히 사용자 피드백을 빠르게 반영하여 제품을 개선하는 애자일 개발 프로세스의 중요성을 깨달았습니다.",
        tags: ["iOS", "머신러닝", "생산성", "SwiftUI", "Core ML"],
        isFavorite: true
    )
    
    project.enabledSections = ["프로젝트 개요", "상세 내용", "링크", "메모 & 회고", "태그"]
    
    return project
}()

// MARK: - Multiple Projects Preview
#Preview("여러 상태") {
    TabView {
        NavigationStack {
            ProjectDetailView(project: sampleProject)
        }
        .tabItem { Label("완성된 프로젝트", systemImage: "checkmark.circle.fill") }
        
        NavigationStack {
            ProjectDetailView(project: emptyProject)
        }
        .tabItem { Label("새 프로젝트", systemImage: "plus.circle") }
        
        NavigationStack {
            ProjectDetailView(project: inProgressProject)
        }
        .tabItem { Label("진행중", systemImage: "clock.fill") }
    }
    .modelContainer(for: Project.self, inMemory: true)
}

private let emptyProject = Project(
    title: "새 프로젝트",
    projectDescription: "프로젝트 설명을 입력하세요",
    techStack: [],
    startDate: Date()
)

private let inProgressProject: Project = {
    let project = Project(
        title: "날씨 위젯 앱",
        tagline: "미니멀한 디자인의 iOS 날씨 위젯",
        projectDescription: "간단하고 아름다운 날씨 정보를 제공하는 위젯 앱",
        techStack: ["SwiftUI", "WidgetKit", "WeatherKit"],
        startDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
        status: .inProgress,
        role: "개인 개발",
        teamSize: "1명",
        projectType: .personal,
        keyFeatures: ["실시간 날씨 업데이트", "다양한 위젯 크기 지원"]
    )
    project.enabledSections = ["상세 내용"]
    return project
}()
