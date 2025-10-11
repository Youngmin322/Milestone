//
//  ContentView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house.fill") {
                NavigationStack {
                    Text("테스트")
                }
            }
            
            Tab("통계", systemImage: "chart.bar.fill") {
                NavigationStack {
                    EmptyView()
                }
            }
            
            Tab("이력서", systemImage: "person.circle.fill") {
                NavigationStack {
                    EmptyView()
                }
            }
        }
    }
}
