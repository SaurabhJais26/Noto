//
//  Home.swift
//  Noto
//
//  Created by Saurabh Jaiswal on 26/03/25.
//

import SwiftUI

struct Home: View {
    @State private var searchText: String = ""
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                SearchBar()
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                    ForEach(mockNotes) { note in
                        CardView(note)
                            .frame(height: 160)
                    }
                }
            }
        }
        .safeAreaPadding(15)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar()
        }
    }
    
    /// Custom Search Bar With Some Basic Components
    
    @ViewBuilder
    func SearchBar() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
            
            TextField("Search", text: $searchText)
                
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.primary.opacity(0.06), in: .rect(cornerRadius: 10))
    }
    
    @ViewBuilder
    func CardView(_ note: Note) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(note.color.gradient)
    }
    @ViewBuilder
    func BottomBar() -> some View {
        HStack(spacing: 15) {
            Button {
                
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.primary)
            }
            Spacer(minLength: 0)
        }
        .overlay {
            Text("Notes")
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(15)
        .background(.bar)
    }
}

#Preview {
    ContentView()
}
