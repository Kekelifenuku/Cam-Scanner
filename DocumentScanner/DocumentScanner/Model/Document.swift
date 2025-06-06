//
//  Document.swift
//  DocumentScanner
//
//  Created by Fenuku kekeli on 5/23/25.
//

import SwiftUI
import SwiftData

@Model
class Document {
    var name: String
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \DocumentPage.document)
    var pages: [DocumentPage]?
    var isLocked: Bool = false
    /// For Zoom Transition
    var uniqueViewID: String = UUID().uuidString
    
    init(name: String, pages: [DocumentPage]? = nil) {
        self.name = name
        self.pages = pages
    }
}
