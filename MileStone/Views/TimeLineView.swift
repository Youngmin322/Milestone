//
//  TimeLineView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/21/25.
//

import SwiftUI
import SwiftData

struct TimeLineView: View {
    @Query(sort: \Project.startDate, order: .reverse) private var projects: [Project]
    
    private var projectByYear: [Int: [Project]] {
        Dictionary(grouping: projects) { project in
            Calendar.current.component(.year, from: project.startDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if projects.isEmpty {
                    ContentUnavailableView {
                        Label("프로젝트가 없습니다.", systemImage: "tray.fill")
                    } description: {
                        Text("프로젝트를 추가해보세요.")
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            TimelineContentView(projects: projects)
                                .padding(.horizontal)
                                .padding(.bottom, 100)
                        }
                    }
                }
            }
        }
    }
    
    struct TimelineContentView: View {
        let projects: [Project]
        
        private var sortedProjects: [Project] {
            projects.sorted { p1, p2 in
                p1.startDate < p2.startDate
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(Array(sortedProjects.enumerated()), id: \.element.id) { index, projects in
                }
            }
        }
    }
}

#Preview {
    TimeLineView()
}
