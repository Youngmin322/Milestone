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
                ForEach(Array(sortedProjects.enumerated()), id: \.element.id) { index, project in
                    TimeLineItemView(
                        project: project,
                        isFirst: index == 0,
                        isLast: index == sortedProjects.count - 1
                    )
                }
                .padding(.top, 20)
            }
        }
        
        struct TimeLineItemView: View {
            let project: Project
            let isFirst: Bool
            let isLast: Bool
            
            @State private var isExpanded = false
            
            private var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "M월 d일"
                
                return formatter
            }
            
            private var durationText: String {
                let start = project.startDate
                let end = project.endDate ?? Date()
                let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                
                if days == 0 {
                    return "당일"
                } else if days < 30 {
                    return "\(days)일"
                } else if days < 365 {
                    let months = days / 30
                    return "\(months)개월"
                } else {
                    let years = days / 365
                    let remainingMonths = (days % 365) / 30
                    if remainingMonths > 0 {
                        return "\(years)년 \(remainingMonths)개월"
                    }
                    return "\(years)년"
                }
            }
            
            var body: some View {
                HStack(alignment: .top, spacing: 16) {
                    // 왼쪽 날짜
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(dateFormatter.string(from: project.startDate))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if project.endDate != nil {
                            Text(durationText)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(width: 70)
                    
                    // 타임라인 라인, 점
                    VStack(spacing: 0) {
                        // 위쪽 라인
                        if !isFirst {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 2)
                                .frame(height: 20)
                        }
                        
                        // 프로젝트 상태 색상
                        Circle()
                            .fill(circleColor)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            )
                            .shadow(color: circleColor.opacity(0.3), radius: 4)
                        
                        // 아래쪽 라인
                        if !isLast {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 2)
                                .frame(minHeight: isExpanded ? 100 : 60)
                        }
                    }
                    
                    // 오른쪽 콘텐츠
                    VStack(alignment: .leading, spacing: 8) {
                        // 제목과 상태
                        HStack {
                            Text(project.title)
                                .font(.headline)
                            
                            Spacer()
                            
                            StatusBadge(status: project.status)
                        }
                        
                        if !project.tagline.isEmpty {
                            Text(project.tagline)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        
                        // 기술 스택
                        if !project.techStack.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(project.techStack, id: \.self) { tech in
                                        Text(tech)
                                            .font(.caption2)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        
                        // 확장 가능한 상세 정보
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 8) {
                                if !project.projectDescription.isEmpty {
                                    Text(project.projectDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                                
                                HStack(spacing: 16) {
                                    if !project.role.isEmpty {
                                        Label(project.role, systemImage: "person.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if !project.teamSize.isEmpty {
                                        Label(project.teamSize, systemImage: "person.3.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        
                        // 더보기 버튼
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(isExpanded ? "접기" : "더보기")
                                    .font(.caption)
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                            }
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    
                    Spacer(minLength: 0)
                }
            }
            
            private var circleColor: Color {
                switch project.status {
                case .inProgress:
                    return .orange
                case .completed:
                    return .green
                case .launched:
                    return .blue
                }
            }
        }
        
        struct StatusBadge: View {
            let status: ProjectStatus
            
            private var color: Color {
                switch status {
                case .inProgress:
                    return .orange
                case .completed:
                    return .green
                case .launched:
                    return .blue
                }
            }
            
            var body: some View {
                Text(status.rawValue)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .clipShape(Capsule())
            }
        }
        
        struct FlowLayout: Layout {
            var spacing: CGFloat = 8
            
            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
                let result = FlowResult(
                    in: proposal.replacingUnspecifiedDimensions().width,
                    subviews: subviews,
                    spacing: spacing
                )
                return result.size
            }
            
            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
                let result = FlowResult(
                    in: bounds.width,
                    subviews: subviews,
                    spacing: spacing
                )
                for row in result.rows {
                    for item in row.items {
                        let x = item.x + bounds.minX
                        let y = row.y + bounds.minY
                        item.subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                    }
                }
            }
            
            struct FlowResult {
                var size: CGSize
                var rows: [Row]
                
                init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
                    var rows: [Row] = []
                    var currentRow = Row()
                    var y: CGFloat = 0
                    
                    for subview in subviews {
                        let size = subview.sizeThatFits(.unspecified)
                        if currentRow.width + size.width + (currentRow.items.isEmpty ? 0 : spacing) > width,
                           !currentRow.items.isEmpty {
                            currentRow.y = y
                            rows.append(currentRow)
                            y += currentRow.height + spacing
                            currentRow = Row()
                        }
                        currentRow.add(subview: subview, size: size, spacing: spacing)
                    }
                    if !currentRow.items.isEmpty {
                        currentRow.y = y
                        rows.append(currentRow)
                    }
                    
                    self.rows = rows
                    self.size = CGSize(
                        width: width,
                        height: rows.last?.y ?? 0 + (rows.last?.height ?? 0)
                    )
                }
                
                struct Row {
                    var items: [Item] = []
                    var width: CGFloat = 0
                    var height: CGFloat = 0
                    var y: CGFloat = 0
                    
                    mutating func add(subview: LayoutSubview, size: CGSize, spacing: CGFloat) {
                        let x = width + (items.isEmpty ? 0 : spacing)
                        items.append(Item(subview: subview, x: x))
                        width = x + size.width
                        height = max(height, size.height)
                    }
                    
                    struct Item {
                        var subview: LayoutSubview
                        var x: CGFloat
                    }
                }
            }
        }
    }
}

#Preview {
    TimeLineView()
        .modelContainer(for: Project.self, inMemory: true)
}
