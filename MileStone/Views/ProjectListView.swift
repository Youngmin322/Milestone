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
                NavigationLink {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(project.projectDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("시작일: \(project.startDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } label: {
                    VStack(alignment: .leading) {
                        Text(project.title)
                            .font(.headline)
                        Text(project.techStack.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
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
