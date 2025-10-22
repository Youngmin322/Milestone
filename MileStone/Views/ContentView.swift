//
//  ContentView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var searchText = ""
    
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house.fill") {
                NavigationStack {
                    ProjectListView()
                }
            }
            
            Tab("통계", systemImage: "chart.bar.fill") {
                NavigationStack {
                    TimeLineView()
                }
            }
            
            Tab("이력서", systemImage: "person.circle.fill") {
                NavigationStack {
                    ResumeView()
                }
            }
            
            Tab(role: .search) {
                NavigationStack {
                    ProjectListView(searchText: searchText)
                }
                .searchable(text: $searchText, prompt: "프로젝트 이름 검색")
            }
        }
    }
}
