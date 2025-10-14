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
            ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
                HStack(spacing: 12) {
                    
                    // 텍스트 정보
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.title)
                            .font(.headline)
                        
                        // techStack이 비어있지 않을 때만 표시
                        if !project.techStack.isEmpty {
                            let displayStack = project.techStack.prefix(3)
                            let stackText = displayStack.joined(separator: ", ")
                            
                            Text(stackText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    // 이미지를 오른쪽 끝으로 밀어내는 Spacer
                    Spacer()
                    
                    // 썸네일 이미지
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
                .contentShape(Rectangle())
                .background(
                    NavigationLink("", destination: ProjectDetailView(project: project))
                        .opacity(0)
                )
                .listRowSeparator(.automatic) // 자동으로 적절한 구분선 처리
                .listRowBackground(Color(.systemBackground))
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .onDelete { offsets in
                // 직접 삭제 처리
                for index in offsets {
                    modelContext.delete(projects[index])
                }
            }
        }
        .listStyle(.insetGrouped) // 메모 앱 스타일로 변경
        .listSectionSeparator(.hidden) // 섹션 구분선 숨기기
        .background(Color(.systemGroupedBackground))
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
                        techStack: [],
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, configurations: config)
    
    // 샘플 프로젝트 추가
    let project1 = Project(
        title: "iOS 날씨 앱",
        projectDescription: "SwiftUI로 만든 날씨 예보 앱",
        techStack: ["SwiftUI", "Combine", "WeatherKit", "SwiftData"],
        startDate: Date()
    )
    
    let project2 = Project(
        title: "투두 리스트",
        projectDescription: "할 일 관리 앱",
        techStack: ["Swift", "CoreData"],
        startDate: Date().addingTimeInterval(-86400 * 30)
    )
    
    let project3 = Project(
        title: "포트폴리오 웹사이트",
        projectDescription: "개인 포트폴리오",
        techStack: [],
        startDate: Date().addingTimeInterval(-86400 * 60)
    )
    
    container.mainContext.insert(project1)
    container.mainContext.insert(project2)
    container.mainContext.insert(project3)
    
    return ProjectListView()
        .modelContainer(container)
}
