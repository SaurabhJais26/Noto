//
//  Note.swift
//  Noto
//
//  Created by Saurabh Jaiswal on 26/03/25.
//

import SwiftUI

struct Note: Identifiable {
    var id: String = UUID().uuidString
    var color: Color
    /// View Properties
    var allowsHitTesting: Bool = false
}

var mockNotes: [Note] = [
    .init(color: .red),
    .init(color: .blue),
    .init(color: .green),
    .init(color: .yellow),
    .init(color: .purple),
]
