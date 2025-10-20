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
    var body: some View {
        NavigationStack {
            ZStack {
                if let pdfDocument = pdfDocument {
                    PDFKitView(pdfDocument: pdfDocument)
                        .ignoresSafeArea()
                } else {
                    
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
