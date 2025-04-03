//
//  Home.swift
//  Noto
//
//  Created by Saurabh Jaiswal on 26/03/25.
//

import SwiftUI
import SwiftData

struct Home: View {
    @State private var searchText: String = ""
    @State private var selectedNote: Note?
    @State private var animateView: Bool = false
    @Namespace private var animation
    @Query(sort: [.init(\Note.dateCreated, order: .reverse)], animation: .snappy)
    private var notes: [Note]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                SearchBar()
                
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                    ForEach(notes) { note in
                        CardView(note)
                            .frame(height: 160)
                            .onTapGesture {
                                guard selectedNote == nil else { return }
                                selectedNote = note
                                note.allowsHitTesting = true
                                withAnimation(noteAnimation) {
                                    animateView = true
                                }
                            }
                    }
                }
            }
        }
        .safeAreaPadding(15)
        .overlay {
            GeometryReader { _ in
                ForEach(notes) { note in
                    if note.id == selectedNote?.id && animateView {
                        DetailView(animation: animation, note: note)
                            .ignoresSafeArea(.container, edges: .top)
                    }
                }
            }
        }
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
        ZStack {
            if selectedNote?.id == note.id && animateView {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(note.color.gradient)
                    .matchedGeometryEffect(id: note.id, in: animation)
            }
        }
    }
    @ViewBuilder
    func BottomBar() -> some View {
        HStack(spacing: 15) {
            Button {
                if selectedNote == nil {
                    createEmptyNote()
                }
            } label: {
                Image(systemName: selectedNote == nil ? "plus.circle.fill" : "trash.fill")
                    .font(.title2)
                    .foregroundStyle(selectedNote == nil ? Color.primary : .red)
                    .contentShape(.rect)
                    .contentTransition(.symbolEffect(.replace))
            }
            Spacer(minLength: 0)
            
            if selectedNote != nil {
                Button {
                    if let firstIndex = notes.firstIndex(where: { $0.id == selectedNote?.id }) {
                        notes[firstIndex].allowsHitTesting = false
                    }
                    
                    withAnimation(noteAnimation) {
                        animateView = false
                        selectedNote = nil
                    }
                } label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                        .contentShape(.rect)
                }
                .transition(.opacity)
            }
        }
        .overlay {
            Text("Notes")
                .font(.callout)
                .fontWeight(.semibold)
                .opacity(selectedNote != nil ? 0 : 1)
        }
        .overlay {
            if selectedNote != nil {
                CardColorPicker()
                    .transition(.blurReplace)
            }
        }
        .padding(15)
        .background(.bar)
        .animation(noteAnimation, value: selectedNote != nil)
    }
    
    @ViewBuilder
    func CardColorPicker() -> some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(Color("Note \(index)"))
                    .frame(width: 20, height: 20)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(noteAnimation) {
                            selectedNote?.colorString = "Note \(index)"
                        }
                    }
            }
        }
    }
    
    func createEmptyNote() {
        let colors: [String] = (1...5).compactMap({ "Note \($0)" })
        let randomColor = colors.randomElement()!
        let note = Note(colorString: randomColor, title: "", content: "")
        
        context.insert(note)
        
        Task {
            try? await Task.sleep(for: .seconds(0))
            selectedNote = note
            selectedNote?.allowsHitTesting = true
            
            withAnimation(noteAnimation) {
                animateView = true
            }
        }
    }
}

struct DetailView: View {
    var animation: Namespace.ID
    var note: Note
    /// View Properties
    @State private var animateLayers: Bool = false // using this property to remove the corner radius in the detail view
    
    var body: some View {
        RoundedRectangle(cornerRadius: animateLayers ? 0 : 10)
            .fill(note.color.gradient)
            .matchedGeometryEffect(id: note.id, in: animation)
            .transition(.offset(y: 1))
            .allowsHitTesting(note.allowsHitTesting)
            .onChange(of: note.allowsHitTesting, initial: true) { oldValue, newValue in
                withAnimation(noteAnimation) {
                    animateLayers = newValue
                }
            }
    }
}

extension View {
    var noteAnimation: Animation {
        .smooth(duration: 0.3, extraBounce: 0)
    }
}

#Preview {
    ContentView()
}
