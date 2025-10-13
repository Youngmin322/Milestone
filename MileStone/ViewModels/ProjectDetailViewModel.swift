//
//  ProjectDetailViewModel.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/13/25.
//

import SwiftUI
import PhotosUI

@Observable
class ProjectDetailViewModel {
    var project: Project
     var isEditMode = false
     var expandedSections: Set<String> = ["overview", "details", "links"]
     var selectedPhoto: PhotosPickerItem?
     var selectedImages: [PhotosPickerItem] = []
    
    init(project: Project) {
        self.project = project
    }
}
