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
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("프로젝트 이미지")
                        .font(.headline)
                }
            }
        }
    }
}
