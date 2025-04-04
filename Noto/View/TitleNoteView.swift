//
//  TitleNoteView.swift
//  Noto
//
//  Created by Saurabh Jaiswal on 04/04/25.
//

import SwiftUI

struct TitleNoteView: View {
    var size: CGSize
    var note: Note
    var body: some View {
        Text(note.title)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .padding(15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(width: size.width, height: size.height)
    }
}
