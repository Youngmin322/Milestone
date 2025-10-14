//
//  ProjectListView_Proper.swift - 실무 권장 방식
//  MileStone
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

struct ProjectListView_Proper: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var selectedProject: Project?
    
    var body: some View {
        List {
            ForEach(projects) { project in
                ProjectRowView(project: project)
                    .onTapGesture {
                        selectedProject = project
                    }
                    .listRowSeparator(.automatic)
                    .listRowBackground(Color(.systemBackground))
            }
            .onDelete { offsets in
                for index in offsets {
                    modelContext.delete(projects[index])
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("My Projects")
        .navigationDestination(item: $selectedProject) { project in
            ProjectDetailView(project: project)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button("Add") {
                    let newProject = Project(
                        title: "New Project",
                        projectDescription: "프로젝트 설명을 입력하세요",
                        techStack: [],
                        startDate: Date()
                    )
                    modelContext.insert(newProject)
                }
            }
        }
    }
}

// 별도 View로 분리 - 재사용성과 가독성 향상
struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)
                
                if !project.techStack.isEmpty {
                    let displayStack = project.techStack.prefix(3)
                    let stackText = displayStack.joined(separator: ", ")
                    
                    Text(stackText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let thumbnailData = project.thumbnail,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // 전체 영역 탭 가능
    }
}