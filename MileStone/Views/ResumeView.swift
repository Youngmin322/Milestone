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
    
    @AppStorage("resumePDFData") private var resumePDFData: Data?
    
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
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("이력서")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if pdfDocument != nil {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [.pdf]
            ) { result in
                switch result {
                case .success(let url):
                    loadPDF(from: url)
                case .failure(let error):
                    print("파일 선택 에러: \(error.localizedDescription)")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = resumePDFData {
                    ShareSheet(activityItems: [pdfData])
                }
            }
        }
        .onAppear {
            loadStoredPDF()
        }
    }
 
    private func loadPDF(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let pdfData = try Data(contentsOf: url)
            resumePDFData = pdfData
            
            if let document = PDFDocument(data: pdfData) {
                pdfDocument = document
            }
        } catch {
            print("Error loading PDF: \(error.localizedDescription)")
        }
    }
    
    private func loadStoredPDF() {
        if let pdfData = resumePDFData,
           let document = PDFDocument(data: pdfData) {
            pdfDocument = document
        }
    }
}

// PDFKit 뷰를 SwiftUI에서 사용하기 위한 UIViewRepresentable
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

// 공유 시트를 위한 UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResumeView()
}
