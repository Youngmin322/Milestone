//
//  ProjectDetailView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI

struct ProjectDetailView: View {
    @Bindable var project: Project
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var isEditMode = false
    @State private var expandedSections: Set<String> = []
    @State private var showingAddSectionSheet = false
    
    // 사용 가능한 섹션 타입
    enum OptionalSection: String, CaseIterable, Identifiable {
        case overview = "프로젝트 개요"
        case details = "상세 내용"
        case visuals = "비주얼 자료"
        case links = "링크"
        case notes = "메모 & 회고"
        case tags = "태그"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .overview: return "doc.text"
            case .details: return "list.bullet"
            case .visuals: return "photo.on.rectangle"
            case .links: return "link"
            case .notes: return "note.text"
            case .tags: return "tag"
            }
        }
    }
    
    // 현재 활성화된 섹션들을 확인
    private var activeSections: [OptionalSection] {
        var sections: [OptionalSection] = []
        
        if hasOverviewContent {
            sections.append(.overview)
        }
        if hasDetailsContent {
            sections.append(.details)
        }
        if !project.images.isEmpty {
            sections.append(.visuals)
        }
        if hasLinksContent {
            sections.append(.links)
        }
        if !project.notes.isEmpty {
            sections.append(.notes)
        }
        if !project.tags.isEmpty {
            sections.append(.tags)
        }
        
        return sections
    }
    
    private var hasOverviewContent: Bool {
        !project.problem.isEmpty || !project.solution.isEmpty || !project.goals.isEmpty
    }
    
    private var hasDetailsContent: Bool {
        !project.keyFeatures.isEmpty || !project.challenges.isEmpty
    }
    
    private var hasLinksContent: Bool {
        project.githubURL != nil || project.liveURL != nil || project.figmaURL != nil
    }
    
    // 추가 가능한 섹션들
    private var availableSectionsToAdd: [OptionalSection] {
        OptionalSection.allCases.filter { section in
            switch section {
            case .overview:
                return !hasOverviewContent
            case .details:
                return !hasDetailsContent
            case .visuals:
                return project.images.isEmpty
            case .links:
                return !hasLinksContent
            case .notes:
                return project.notes.isEmpty
            case .tags:
                return project.tags.isEmpty
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Hero Section (항상 표시)
                heroSection
                
                // MARK: - 핵심 정보 카드 (항상 표시)
                infoCard
                
                // MARK: - 동적 섹션들
                ForEach(activeSections) { section in
                    sectionView(for: section)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        project.isFavorite.toggle()
                    } label: {
                        Image(systemName: project.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(project.isFavorite ? .yellow : .gray)
                    }
                    
                    // 편집 모드일 때만 + 버튼 표시
                    if isEditMode && !availableSectionsToAdd.isEmpty {
                        Button {
                            showingAddSectionSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    Button {
                        isEditMode.toggle()
                    } label: {
                        Text(isEditMode ? "완료" : "편집")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSectionSheet) {
            addSectionSheet
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    project.thumbnail = data
                }
            }
        }
        .onChange(of: selectedImages) { oldValue, newValue in
            Task {
                var newImagesData: [Data] = []
                for item in newValue {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        newImagesData.append(data)
                    }
                }
                project.images.append(contentsOf: newImagesData)
            }
        }
    }
    
    // MARK: - 섹션 추가 시트
    private var addSectionSheet: some View {
        NavigationStack {
            List(availableSectionsToAdd) { section in
                Button {
                    addSection(section)
                    showingAddSectionSheet = false
                } label: {
                    HStack {
                        Image(systemName: section.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(section.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("섹션 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showingAddSectionSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - 섹션 추가 로직
    private func addSection(_ section: OptionalSection) {
        withAnimation {
            switch section {
            case .overview:
                if project.problem.isEmpty {
                    project.problem = ""
                }
            case .details:
                if project.keyFeatures.isEmpty {
                    project.keyFeatures = [""]
                }
            case .visuals:
                // 이미지 피커 트리거는 섹션 생성 후 사용자가 직접
                break
            case .links:
                if project.githubURL == nil {
                    project.githubURL = ""
                }
            case .notes:
                project.notes = ""
            case .tags:
                project.tags = [""]
            }
            expandedSections.insert(section.rawValue)
        }
    }
    
    // MARK: - 섹션 뷰 생성
    @ViewBuilder
    private func sectionView(for section: OptionalSection) -> some View {
        switch section {
        case .overview:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.problem = ""
                        project.solution = ""
                        project.goals = ""
                    }
                } : nil
            ) {
                overviewSection
            }
        case .details:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.keyFeatures = []
                        project.challenges = ""
                    }
                } : nil
            ) {
                detailsSection
            }
        case .visuals:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.images = []
                    }
                } : nil
            ) {
                visualsSection
            }
        case .links:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.githubURL = nil
                        project.liveURL = nil
                        project.figmaURL = nil
                    }
                } : nil
            ) {
                linksSection
            }
        case .notes:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.notes = ""
                    }
                } : nil
            ) {
                notesSection
            }
        case .tags:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                icon: section.icon,
                onDelete: isEditMode ? {
                    withAnimation {
                        project.tags = []
                    }
                } : nil
            ) {
                tagsSection
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if isEditMode {
                        TextField("프로젝트 제목", text: $project.title)
                            .font(.title.bold())
                    } else {
                        Text(project.title)
                            .font(.title.bold())
                    }
                    
                    if isEditMode {
                        TextField("한 줄 설명", text: $project.tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if !project.tagline.isEmpty {
                        Text(project.tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                statusBadge
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                if let thumbnailData = project.thumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("대표 이미지 추가")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            .disabled(!isEditMode)
        }
    }
    
    // MARK: - 핵심 정보 카드
    private var infoCard: some View {
        VStack(spacing: 12) {
            infoRow(icon: "person.fill", title: "역할", value: $project.role)
            infoRow(icon: "person.3.fill", title: "팀 규모", value: $project.teamSize)
            
            HStack {
                Label("프로젝트 유형", systemImage: "folder.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if isEditMode {
                    Picker("", selection: $project.projectType) {
                        Text("개인").tag(ProjectType.personal)
                        Text("팀").tag(ProjectType.team)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                } else {
                    Text(project.projectType.rawValue)
                        .font(.subheadline)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("기술 스택", systemImage: "hammer.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if isEditMode {
                        Button {
                            project.techStack.append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                
                FlowLayout(spacing: 8) {
                    ForEach(project.techStack.indices, id: \.self) { index in
                        if isEditMode {
                            HStack(spacing: 4) {
                                TextField("기술", text: $project.techStack[index])
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                Button {
                                    project.techStack.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        } else {
                            Text(project.techStack[index])
                                .font(.caption)
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
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 프로젝트 개요
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            subsectionView(title: "문제 정의", text: $project.problem, placeholder: "어떤 문제를 해결하고자 했나요?")
            subsectionView(title: "솔루션", text: $project.solution, placeholder: "어떻게 해결했나요?")
            subsectionView(title: "목표 및 결과", text: $project.goals, placeholder: "목표와 달성한 결과는?")
        }
    }
    
    // MARK: - 상세 내용
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("주요 기능")
                        .font(.headline)
                    Spacer()
                    if isEditMode {
                        Button {
                            project.keyFeatures.append("")
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                
                ForEach(project.keyFeatures.indices, id: \.self) { index in
                    HStack {
                        if isEditMode {
                            TextField("기능", text: $project.keyFeatures[index])
                                .textFieldStyle(.roundedBorder)
                            Button {
                                project.keyFeatures.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        } else {
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(project.keyFeatures[index])
                            }
                        }
                    }
                }
            }
            
            subsectionView(title: "기술적 챌린지 & 해결방법", text: $project.challenges, placeholder: "어떤 어려움이 있었고, 어떻게 극복했나요?")
        }
    }
    
    // MARK: - 비주얼 자료
    private var visualsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("스크린샷 & 이미지")
                    .font(.headline)
                Spacer()
                if isEditMode {
                    PhotosPicker(selection: $selectedImages, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(project.images.indices, id: \.self) { index in
                        if let uiImage = UIImage(data: project.images[index]) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                if isEditMode {
                                    Button {
                                        project.images.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .red)
                                            .font(.title3)
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 링크
    private var linksSection: some View {
        VStack(spacing: 12) {
            linkRow(icon: "link", title: "GitHub", url: $project.githubURL)
            linkRow(icon: "globe", title: "Live Demo", url: $project.liveURL)
            linkRow(icon: "paintbrush", title: "Figma", url: $project.figmaURL)
        }
    }
    
    // MARK: - 메모/회고
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditMode {
                TextEditor(text: $project.notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if !project.notes.isEmpty {
                Text(project.notes)
                    .font(.body)
            } else {
                Text("배운 점, 개선 사항 등을 기록해보세요")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 태그
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("태그")
                    .font(.headline)
                Spacer()
                if isEditMode {
                    Button {
                        project.tags.append("")
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            FlowLayout(spacing: 8) {
                ForEach(project.tags.indices, id: \.self) { index in
                    if isEditMode {
                        HStack(spacing: 4) {
                            TextField("태그", text: $project.tags[index])
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Button {
                                project.tags.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    } else {
                        Text("#\(project.tags[index])")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private var statusBadge: some View {
        Group {
            if isEditMode {
                Picker("", selection: $project.status) {
                    Text("진행중").tag(ProjectStatus.inProgress)
                    Text("완료").tag(ProjectStatus.completed)
                    Text("런칭됨").tag(ProjectStatus.launched)
                }
                .pickerStyle(.menu)
            } else {
                Text(project.status.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var statusColor: Color {
        switch project.status {
        case .inProgress: return .orange
        case .completed: return .green
        case .launched: return .blue
        }
    }
    
    private var dateRangeText: String {
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
    
    private func expandableSection<Content: View>(
        id: String,
        title: String,
        icon: String,
        onDelete: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    if expandedSections.contains(id) {
                        expandedSections.remove(id)
                    } else {
                        expandedSections.insert(id)
                    }
                }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                    Spacer()
                    if let onDelete = onDelete {
                        Button {
                            onDelete()
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        .padding(.trailing, 8)
                    }
                    Image(systemName: expandedSections.contains(id) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(.primary)
            }
            
            if expandedSections.contains(id) {
                content()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func infoRow(icon: String, title: String, value: Binding<String>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if isEditMode {
                TextField(title, text: value)
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline)
            } else {
                Text(value.wrappedValue.isEmpty ? "-" : value.wrappedValue)
                    .font(.subheadline)
            }
        }
    }
    
    private func subsectionView(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            if isEditMode {
                TextEditor(text: text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if !text.wrappedValue.isEmpty {
                Text(text.wrappedValue)
                    .font(.body)
            } else {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func linkRow(icon: String, title: String, url: Binding<String?>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
            Spacer()
            if isEditMode {
                TextField("URL", text: Binding(
                    get: { url.wrappedValue ?? "" },
                    set: { url.wrappedValue = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .font(.caption)
            } else if let urlString = url.wrappedValue, !urlString.isEmpty, let validURL = URL(string: urlString) {
                Link(destination: validURL) {
                    Text("열기")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            } else {
                Text("-")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let sampleProject = Project(
        title: "MileStone 앱",
        projectDescription: "개인 프로젝트 관리 앱",
        techStack: ["SwiftUI", "SwiftData", "CoreML"],
        startDate: .now,
        thumbnail: nil
    )
    
    return ProjectDetailView(project: sampleProject)
}
