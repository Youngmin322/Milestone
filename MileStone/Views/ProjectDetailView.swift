//
//  ProjectDetailView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI

struct ProjectDetailView: View {
    @State private var viewModel: ProjectDetailViewModel
    
    init(project: Project) {
        _viewModel = State(initialValue: ProjectDetailViewModel(project: project))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                infoCard
                
                ForEach(viewModel.activeSections) { section in
                    sectionView(for: section)
                }
            }
            .padding()
        }
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
                    }
                    .padding(.vertical, 8)
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
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.overview) } : nil
            ) {
                overviewSection
            }
        case .details:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.details) } : nil
            ) {
                detailsSection
            }
        case .visuals:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.visuals) } : nil
            ) {
                visualsSection
            }
        case .links:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.links) } : nil
            ) {
                linksSection
            }
        case .notes:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.notes) } : nil
            ) {
                notesSection
            }
        case .tags:
            expandableSection(
                id: section.rawValue,
                title: section.rawValue,
                onDelete: viewModel.isEditMode ? { viewModel.deleteSection(.tags) } : nil
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
                    if viewModel.isEditMode {
                        TextField("프로젝트 제목", text: $viewModel.project.title)
                            .font(.title.bold())
                    } else {
                        Text(viewModel.project.title)
                            .font(.title.bold())
                    }
                    
                    if viewModel.isEditMode {
                        TextField("한 줄 설명", text: $viewModel.project.tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if !viewModel.project.tagline.isEmpty {
                        Text(viewModel.project.tagline)
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
                Text(viewModel.dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            thumbnailPicker
        }
    }
    
    private var thumbnailPicker: some View {
        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
            if let thumbnailData = viewModel.project.thumbnail,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if viewModel.isEditMode {
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
        .disabled(!viewModel.isEditMode)
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(spacing: 12) {
            infoRow(icon: "person.fill", title: "역할", value: $viewModel.project.role)
            infoRow(icon: "person.3.fill", title: "팀 규모", value: $viewModel.project.teamSize)
            
            HStack {
                Label("프로젝트 유형", systemImage: "folder.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.isEditMode {
                    Picker("", selection: $viewModel.project.projectType) {
                        Text("개인").tag(ProjectType.personal)
                        Text("팀").tag(ProjectType.team)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                } else {
                    Text(viewModel.project.projectType.rawValue)
                        .font(.subheadline)
                }
            }
            
            techStackSection
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var techStackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("기술 스택", systemImage: "hammer.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if viewModel.isEditMode {
                    Button {
                        viewModel.addTechStack()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            FlowLayout(spacing: 8) {
                ForEach(Array(viewModel.project.techStack.enumerated()), id: \.offset) { index, tech in
                    if viewModel.isEditMode {
                        HStack(spacing: 4) {
                            TextField("기술", text: Binding(
                                get: { viewModel.project.techStack.indices.contains(index) ? viewModel.project.techStack[index] : "" },
                                set: { viewModel.updateTechStack(at: index, with: $0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            
                            Button {
                                viewModel.removeTechStack(at: index)
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
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isEditMode || viewModel.hasOverviewContent {
                subsectionView(title: "문제 정의", text: $viewModel.project.problem, placeholder: "어떤 문제를 해결하고자 했나요?")
                subsectionView(title: "솔루션", text: $viewModel.project.solution, placeholder: "어떻게 해결했나요?")
                subsectionView(title: "목표 및 결과", text: $viewModel.project.goals, placeholder: "목표와 달성한 결과는?")
            } else {
                Text("프로젝트 개요를 추가해보세요.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isEditMode || viewModel.hasDetailsContent {
                keyFeaturesSection
                subsectionView(title: "도전 과제", text: $viewModel.project.challenges, placeholder: "개발 과정에서 겪은 어려움")
            } else {
                Text("상세 내용을 추가해보세요.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
    }
    
    private var keyFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("주요 기능")
                    .font(.headline)
                Spacer()
                if viewModel.isEditMode {
                    Button {
                        viewModel.addKeyFeature()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
            ForEach(Array(viewModel.project.keyFeatures.enumerated()), id: \.offset) { index, feature in
                HStack {
                    if viewModel.isEditMode {
                        TextField("기능", text: Binding(
                            get: { viewModel.project.keyFeatures.indices.contains(index) ? viewModel.project.keyFeatures[index] : "" },
                            set: { viewModel.updateKeyFeature(at: index, with: $0) }
                        ))
                        Button {
                            viewModel.removeKeyFeature(at: index)
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
    
    // MARK: - Visuals Section
    private var visualsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditMode {
                PhotosPicker(selection: $viewModel.selectedImages, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                            .foregroundColor(.blue)
                        Text("이미지 추가")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    if viewModel.isEditMode {
                                        Button {
                                            viewModel.removeImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundStyle(.red)
                                                .background(Color.white, in: Circle())
                                        }
                                        .offset(x: 8, y: -8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            } else if !viewModel.isEditMode {
                Text("추가된 이미지가 없습니다.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
    }
    
    // MARK: - Links Section
    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isEditMode {
                urlField(title: "GitHub", binding: Binding(
                    get: { viewModel.project.githubURL ?? "" },
                    set: { viewModel.updateGithubURL($0) }
                ))
                urlField(title: "Live Site", binding: Binding(
                    get: { viewModel.project.liveURL ?? "" },
                    set: { viewModel.updateLiveURL($0) }
                ))
                urlField(title: "Figma", binding: Binding(
                    get: { viewModel.project.figmaURL ?? "" },
                    set: { viewModel.updateFigmaURL($0) }
                ))
            } else {
                if let githubURL = viewModel.project.githubURL, !githubURL.isEmpty {
                    LinkRow(title: "GitHub", url: githubURL)
                }
                if let liveURL = viewModel.project.liveURL, !liveURL.isEmpty {
                    LinkRow(title: "Live Site", url: liveURL)
                }
                if let figmaURL = viewModel.project.figmaURL, !figmaURL.isEmpty {
                    LinkRow(title: "Figma", url: figmaURL)
                }
                
                if !viewModel.hasLinksContent {
                    Text("링크를 추가해보세요.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    private func urlField(title: String, binding: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            TextField("\(title) URL", text: binding)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isEditMode {
                TextEditor(text: $viewModel.project.notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                if !viewModel.project.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(viewModel.project.notes)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("메모나 회고를 추가해보세요.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isEditMode {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("태그")
                            .font(.headline)
                        Spacer()
                        Button {
                            viewModel.addTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    ForEach(Array(viewModel.project.tags.enumerated()), id: \.offset) { index, tag in
                        HStack {
                            TextField("태그", text: Binding(
                                get: { viewModel.project.tags.indices.contains(index) ? viewModel.project.tags[index] : "" },
                                set: { viewModel.updateTag(at: index, with: $0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                            
                            Button {
                                viewModel.removeTag(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.project.tags.enumerated()), id: \.offset) { index, tag in
                        if !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                
                if viewModel.project.tags.isEmpty || viewModel.project.tags.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    Text("태그를 추가해보세요.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            }
        }
    }
    
    // MARK: - Expandable Section
    private func expandableSection<Content: View>(
        id: String,
        title: String,
        onDelete: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Button {
                    viewModel.toggleSection(id)
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
                
                Button {
                    viewModel.toggleSection(id)
                } label: {
                    Image(systemName: viewModel.isSectionExpanded(id) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)
            
            if viewModel.isSectionExpanded(id) {
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
    
    // MARK: - Subsection View
    private func subsectionView(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            if viewModel.isEditMode {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            if viewModel.isEditMode {
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
        Text(viewModel.project.status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(viewModel.statusColor.opacity(0.1))
            .foregroundColor(viewModel.statusColor)
            .clipShape(Capsule())
    }
}

// MARK: - Link Row
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
