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
    @State private var viewModel: ProjectListViewModel?
    
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
                .onDelete { offsets in
                    viewModel?.deleteItems(projects: projects, offsets: offsets)
                }
            }
            .navigationTitle("My Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        viewModel?.addItem()
                    }) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("프로젝트를 선택하세요")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProjectListView()
        .modelContainer(for: Project.self, inMemory: true)
}
