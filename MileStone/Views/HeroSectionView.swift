//
//  HeroSectionView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI

struct HeroSectionView: View {
    @Bindable var viewModel: ProjectDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            thumbnailView
            titleAndStatusView
            dateRangeView
        }
    }
    
    private var thumbnailView: some View {
        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
            if let thumbnailData = viewModel.project.thumbnail,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("대표 이미지 추가")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
        .disabled(!viewModel.isEditMode)
    }
    
    private var titleAndStatusView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if viewModel.isEditMode {
                    TextField("프로젝트 제목", text: $viewModel.project.title)
                        .font(.title.bold())
                } else {
                    Text(viewModel.project.title)
                        .font(.title.bold())
                }
                
                if viewModel.isEditMode {
                    TextField("한 줄 설명", text: $viewModel.project.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if !viewModel.project.tagline.isEmpty {
                    Text(viewModel.project.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            StatusBadgeView(viewModel: viewModel)
        }
    }
    
    private var dateRangeView: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundStyle(.secondary)
            Text(viewModel.dateRangeText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct StatusBadgeView: View {
    @Bindable var viewModel: ProjectDetailViewModel
    
    var body: some View {
        Group {
            if viewModel.isEditMode {
                Picker("", selection: $viewModel.project.status) {
                    Text("진행중").tag(ProjectStatus.inProgress)
                    Text("완료").tag(ProjectStatus.completed)
                    Text("런칭됨").tag(ProjectStatus.launched)
                }
                .pickerStyle(.menu)
            } else {
                Text(viewModel.project.status.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.statusColor.opacity(0.2))
                    .foregroundColor(viewModel.statusColor)
                    .clipShape(Capsule())
            }
        }
    }
}
