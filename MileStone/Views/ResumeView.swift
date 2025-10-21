//
//  ResumeView.swift
//  MileStone
//
//  Created by Youngmin Cho on 10/20/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ResumeView: View {
    @State private var pdfDocument: PDFDocument?
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let pdfDocument = pdfDocument {
                    PDFKitView(pdfDocument: pdfDocument)
                        .ignoresSafeArea()
                } else {
                    ContentUnavailableView {
                        Label("이력서가 없습니다.", systemImage: "doc.text")
                    } description: {
                        Text("PDF 파일을 업로드하여 이력서를 등록하세요.")
                    } actions: {
                        Button("PDF 업로드") {
                            showingDocumentPicker = true
                        }
                    }
                }
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

#Preview {
    ResumeView()
}
