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
        NavigationSplitView {
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
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("프로젝트를 선택하세요")
                .foregroundColor(.secondary)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newProject = Project(
                title: "New Project",
                projectDescription: "프로젝트 설명을 입력하세요",
                techStack: ["Swift", "SwiftUI"],
                startDate: Date(),
                endDate: nil
            )
            modelContext.insert(newProject)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(projects[index])
            }
        }
    }
}

#Preview {
    ProjectListView()
        .modelContainer(for: Project.self, inMemory: true)
}
