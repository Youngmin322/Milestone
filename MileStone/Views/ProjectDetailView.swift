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
    
    // MARK: - 섹션 삭제 로직
    private func deleteSection(_ section: OptionalSection) {
        withAnimation {
            expandedSections.remove(section.rawValue)
            
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
    
    // MARK: - 섹션 뷰 생성
    @ViewBuilder
    private func sectionView(for section: OptionalSection) -> some View {
        switch section {
        case .overview:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.overview) } : nil
            ) {
                overviewSection
            }
        case .details:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.details) } : nil
            ) {
                detailsSection
            }
        case .visuals:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.visuals) } : nil
            ) {
                visualsSection
            }
        case .links:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.links) } : nil
            ) {
                linksSection
            }
        case .notes:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.notes) } : nil
            ) {
                notesSection
            }
        case .tags:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: isEditMode ? { deleteSection(.tags) } : nil
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
                } else if isEditMode {
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
                    ForEach(Array(project.techStack.enumerated()), id: \.offset) { index, tech in
                        if index < project.techStack.count {
                            if isEditMode {
                                HStack(spacing: 4) {
                                    TextField("기술", text: Binding(
                                        get: { project.techStack.indices.contains(index) ? project.techStack[index] : "" },
                                        set: {
                                            if project.techStack.indices.contains(index) {
                                                project.techStack[index] = $0
                                            }
                                        }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                    Button {
                                        if project.techStack.indices.contains(index) {
                                            project.techStack.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                            } else {
                                Text(tech)
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
                
                ForEach(Array(project.keyFeatures.enumerated()), id: \.offset) { index, feature in
                    if index < project.keyFeatures.count {
                        HStack {
                            if isEditMode {
                                TextField("기능", text: Binding(
                                    get: { project.keyFeatures.indices.contains(index) ? project.keyFeatures[index] : "" },
                                    set: {
                                        if project.keyFeatures.indices.contains(index) {
                                            project.keyFeatures[index] = $0
                                        }
                                    }
                                ))
                                Button {
                                    if project.keyFeatures.indices.contains(index) {
                                        project.keyFeatures.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            } else {
                                Text("• \(feature)")
                            }
                        }
                    }
                }
            }
            
            subsectionView(title: "도전 과제", text: $project.challenges, placeholder: "개발 과정에서 겪은 어려움")
        }
    }
    
    // MARK: - 비주얼 자료
    private var visualsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(project.images.enumerated()), id: \.offset) { index, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    // MARK: - 링크
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let githubURL = project.githubURL, !githubURL.isEmpty {
                LinkRow(title: "GitHub", url: githubURL)
            }
            if let liveURL = project.liveURL, !liveURL.isEmpty {
                LinkRow(title: "Live Site", url: liveURL)
            }
            if let figmaURL = project.figmaURL, !figmaURL.isEmpty {
                LinkRow(title: "Figma", url: figmaURL)
            }
        }
    }
    
    // MARK: - 메모 & 회고
    private var notesSection: some View {
        TextEditor(text: $project.notes)
            .frame(minHeight: 100)
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 태그
    private var tagsSection: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(project.tags.enumerated()), id: \.offset) { index, tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
        }
    }
    
    // MARK: - 섹션 공통 UI (아이콘 제거)
    private func expandableSection<Content: View>(
        id: String,
        title: String,
        onDelete: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack(alignment: .center, spacing: 8) {
                Button {
                    withAnimation {
                        if expandedSections.contains(id) {
                            expandedSections.remove(id)
                        } else {
                            expandedSections.insert(id)
                        }
                    }
                } label: {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if let onDelete = onDelete {
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(.trailing, 4)
                }
                
                Button(action: {
                    withAnimation {
                        if expandedSections.contains(id) {
                            expandedSections.remove(id)
                        } else {
                            expandedSections.insert(id)
                        }
                    }
                }) {
                    Image(systemName: expandedSections.contains(id) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)
            
            if expandedSections.contains(id) {
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - 서브섹션 텍스트 편집
    private func subsectionView(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            if isEditMode {
                TextEditor(text: text)
                    .frame(minHeight: 80)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Group {
                            if text.wrappedValue.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.gray)
                                    .padding(8)
                            }
                        }, alignment: .topLeading
                    )
            } else {
                if !text.wrappedValue.isEmpty {
                    Text(text.wrappedValue)
                        .font(.body)
                        .foregroundStyle(.primary)
                } else {
                    Text("-")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Info Row
    private func infoRow(icon: String, title: String, value: Binding<String>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            if isEditMode {
                TextField(title, text: value)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(value.wrappedValue)
                    .font(.subheadline)
            }
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        Text(project.status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .clipShape(Capsule())
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let start = project.startDate // nil이면 현재 날짜 사용
        let end = project.endDate ?? Date() // nil이면 현재 날짜 사용
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

// MARK: - 링크 row
struct LinkRow: View {
    let title: String
    let url: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Link(destination: URL(string: url)!) {
                Text(url)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}
