//
//  Home.swift
//  DocumentScanner
//
//  Created by Fenuku kekeli on 5/23/25.
//

import SwiftUI
import SwiftData
import VisionKit

struct Home: View {
    // MARK: - View Properties
    @State private var showScannerView: Bool = false
    @State private var scanDocument: VNDocumentCameraScan?
    @State private var documentName: String = "New Document"
    @State private var askDocumentName: Bool = false
    @State private var isLoading: Bool = false
    @State private var lastOpened: String = ""
    @Query(sort: [.init(\Document.createdAt, order: .reverse)], animation: .smooth)
    private var documents: [Document]
    
    // MARK: - Environment
    @Namespace private var animationID
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Group {
                if documents.isEmpty {
                    emptyStateView
                } else {
                    documentGridView
                }
            }
            .safeAreaInset(edge: .bottom) {
                scanButton
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
                
                ToolbarItem(placement: .principal) {
                    lastOpenedView
                }
            }
//            .navigationTitle("Documents")
        }
        .onAppear(perform: updateLastOpened)
        .fullScreenCover(isPresented: $showScannerView) {
            documentScannerView
        }
        .alert("Document Name", isPresented: $askDocumentName) {
            documentNameAlert
        }
        .overlay {
            if isLoading {
                LoadingView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Documents Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap the scan button below to create your first document")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var documentGridView: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2), spacing: 15) {
                ForEach(documents) { document in
                    NavigationLink {
                        DocumentDetailView(document: document)
                            .navigationTransition(.zoom(sourceID: document.uniqueViewID, in: animationID))
                    } label: {
                        DocumentCardView(document: document, animationID: animationID)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .padding(15)
        }
    }
    
    private var scanButton: some View {
        Button {
            HapticFeedback.trigger(.mediumImpact)
            showScannerView.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "doc.viewfinder.fill")
                    .font(.title)
                    .bold()
                Text("Scan Document")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(.blue.gradient, in: .capsule)
            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0),
                                    .white.opacity(0.5),
                                    .white,
                                    .white
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .ignoresSafeArea()
        }
    }
    
    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape")
                .imageScale(.large)
        }
    }

    
    private var lastOpenedView: some View {
        VStack(spacing: 2) {
            Text("Last opened")
                .font(.caption)
                .foregroundColor(.gray)
                .bold()
            Text(lastOpened)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var documentScannerView: some View {
        DocumentScannerView(
            onError: { error in
                showScannerView = false
                print("Scan failed:", error.localizedDescription)
            },
            onCancel: {
                showScannerView = false
            },
            onSuccess: { scan in
                scanDocument = scan
                showScannerView = false
                askDocumentName = true
            }
        )
        .ignoresSafeArea()
    }
    
    private var documentNameAlert: some View {
        Group {
            TextField("New Document", text: $documentName)
                .submitLabel(.done)
                .autocorrectionDisabled()
            
            Button("Cancel", role: .cancel) {
                documentName = "New Document"
            }
            
            Button("Save") {
                createDocument()
            }
            .disabled(documentName.isEmpty)
        }
    }
    
    // MARK: - Document Methods
    
    private func createDocument() {
        guard let scanDocument else { return }
        isLoading = true
        
        Task.detached(priority: .high) { [documentName] in
            do {
                let document = Document(name: documentName)
                var pages: [DocumentPage] = []
                
                for pageIndex in 0..<scanDocument.pageCount {
                    let pageImage = scanDocument.imageOfPage(at: pageIndex)
                    guard let pageData = pageImage.jpegData(compressionQuality: 0.65) else {
                        throw DocumentError.imageProcessingFailed
                    }
                    
                    let documentPage = DocumentPage(
                        document: document,
                        pageIndex: pageIndex,
                        pageData: pageData
                    )
                    pages.append(documentPage)
                }
                
                document.pages = pages
                
                try await MainActor.run {
                    context.insert(document)
                    try context.save()
                    resetDocumentState()
                    HapticFeedback.trigger(.success)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Error saving document:", error.localizedDescription)
                }
            }
        }
    }
    
    private func resetDocumentState() {
        scanDocument = nil
        documentName = "New Document"
        askDocumentName = false
        isLoading = false
    }
    
    private func updateLastOpened() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        lastOpened = formatter.string(from: Date())
    }
}

// MARK: - Supporting Types

enum DocumentError: LocalizedError {
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process scanned images"
        }
    }
}

struct HapticFeedback {
    enum FeedbackType {
        case success, warning, error, lightImpact, mediumImpact, heavyImpact
        
        func trigger() {
            switch self {
            case .success, .warning, .error:
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(notificationType)
            case .lightImpact, .mediumImpact, .heavyImpact:
                let generator = UIImpactFeedbackGenerator(style: impactStyle)
                generator.impactOccurred()
            }
        }
        
        private var notificationType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            default: return .success
            }
        }
        
        private var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .lightImpact: return .light
            case .mediumImpact: return .medium
            case .heavyImpact: return .heavy
            default: return .medium
            }
        }
    }
    
    static func trigger(_ type: FeedbackType) {
        type.trigger()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - Preview

#Preview {
    Home()
        .modelContainer(for: [Document.self, DocumentPage.self], inMemory: true)
}
