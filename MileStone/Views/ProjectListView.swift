//
//  ProjectListView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/10/25.
//

import SwiftUI
import SwiftData

struct ProjectListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    
    var body: some View {
        List {
            ForEach(projects) { project in
                NavigationLink(destination: ProjectDetailView(project: project)) {
                    VStack(alignment: .leading) {
                        Text(project.title)
                            .font(.headline)
                        Text(project.techStack.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            if let thumbnailData = project.thumbnail,
                               let uiImage = UIImage(data: thumbnailData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            .onDelete { offsets in
                // 직접 삭제 처리
                for index in offsets {
                    modelContext.delete(projects[index])
                }
            }
        }
        .navigationTitle("My Projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: {
                    let newProject = Project(
                        title: "New Project",
                        projectDescription: "프로젝트 설명을 입력하세요",
                        techStack: ["Swift", "SwiftUI"],
                        startDate: Date()
                    )
                    modelContext.insert(newProject)
                }) {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
    }
}

#Preview {
    ProjectListView()
        .modelContainer(for: Project.self, inMemory: true)
}
