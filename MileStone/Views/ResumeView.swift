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
    @AppStorage("resumePDFData") private var resumePDFData: Data?
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State private var pdfDocument: PDFDocument?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let pdfDocument = pdfDocument {
                    // PDF가 있을 때
                    PDFKitView(pdfDocument: pdfDocument)
                        .edgesIgnoringSafeArea(.bottom) // top 제외
                } else {
                    // PDF가 없을 때
                    ContentUnavailableView {
                        Label("이력서가 없습니다", systemImage: "doc.text")
                    } description: {
                        Text("PDF 파일을 업로드하여 이력서를 등록하세요")
                    } actions: {
                        Button("PDF 업로드") {
                            showingDocumentPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("이력서")
            .navigationBarTitleDisplayMode(.inline) // large 대신 inline 사용
            .toolbar {
                if pdfDocument != nil {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button {
                            showingDocumentPicker = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
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
                    print("Error selecting file: \(error.localizedDescription)")
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
        
        // 배경색 설정
        pdfView.backgroundColor = UIColor.systemBackground
        
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

// ContentView에서 사용할 수 있도록 Preview
#Preview {
    ResumeView()
}
