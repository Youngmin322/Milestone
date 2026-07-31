//
//  ProjectListViewModel.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/10/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ProjectListViewModel {
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addItem() {
        withAnimation {
            let newProject = Project(
                title: "New Project",
                projectDescription: "",
                techStack: ["Swift", "SwiftUI"],
                startDate: Date(),
                endDate: nil
            )
            modelContext.insert(newProject)
        }
    }
    
    func deleteItems(projects: [Project], offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(projects[index])
            }
        }
    }
}
