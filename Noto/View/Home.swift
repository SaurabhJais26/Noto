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
    @State private var deleteNote: Note?
    @State private var animateView: Bool = false
    @FocusState private var isKeyboardActive: Bool
    @State private var titleNoteSize: CGSize = .zero
    @Namespace private var animation
    @Environment(\.modelContext) private var context
    
    var body: some View {
        SearchQueryView(searchText: searchText) { notes in
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    SearchBar()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
                        ForEach(notes) { note in
                            CardView(note)
                                .frame(height: 160)
                                .onTapGesture {
                                    guard selectedNote == nil else { return }
                                    isKeyboardActive = false
                                    
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
                GeometryReader {
                    let size = $0.size
                    ForEach(notes) { note in
                        if note.id == selectedNote?.id && animateView {
                            DetailView(size: size, titleNoteSize: titleNoteSize, animation: animation, note: note)
                                .ignoresSafeArea(.container, edges: .top)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomBar()
            }
            .focused($isKeyboardActive)
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
                    .overlay {
                        TitleNoteView(size: titleNoteSize, note: note)
                    }
                    .matchedGeometryEffect(id: note.id, in: animation)
            }
        }
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { newValue in
            titleNoteSize = newValue
        }
    }
    
    @ViewBuilder
    func BottomBar() -> some View {
        HStack(spacing: 15) {
            Group {
                if !isKeyboardActive {
                    Button {
                        if selectedNote == nil {
                            createEmptyNote()
                        } else {
                            selectedNote?.allowsHitTesting = false
                            deleteNote = selectedNote
                            withAnimation(noteAnimation.logicallyComplete(after: 0.1), completionCriteria: .logicallyComplete) {
                                selectedNote = nil
                                animateView = false
                            } completion: {
                                deleteNoteFromContext()
                            }
                        }
                    } label: {
                        Image(systemName: selectedNote == nil ? "plus.circle.fill" : "trash.fill")
                            .font(.title2)
                            .foregroundStyle(selectedNote == nil ? Color.primary : .red)
                            .contentShape(.rect)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            ZStack {
                if isKeyboardActive {
                    Button("Done") {
                        isKeyboardActive = false
                    }
                    .font(.title3)
                    .foregroundStyle(Color.primary)
                    .transition(.blurReplace)
                }
                if selectedNote != nil && !isKeyboardActive {
                    Button {
                        selectedNote?.allowsHitTesting = false
                        
                        if let selectedNote, (selectedNote.title.isEmpty && selectedNote.content.isEmpty) {
                            deleteNote = selectedNote
                        }
                        
                        withAnimation(noteAnimation.logicallyComplete(after: 0.1), completionCriteria: .logicallyComplete) {
                            animateView = false
                            selectedNote = nil
                        } completion: {
                            deleteNoteFromContext()
                        }
                    } label: {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                            .contentShape(.rect)
                    }
                    .transition(.blurReplace)
                }
            }
        }
        .overlay {
            Text("Notes")
                .font(.callout)
                .fontWeight(.semibold)
                .opacity(selectedNote != nil ? 0 : 1)
        }
        .overlay {
            if selectedNote != nil && !isKeyboardActive {
                CardColorPicker()
                    .transition(.blurReplace)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, isKeyboardActive ? 8 : 15)
        .background(.bar)
        .animation(noteAnimation, value: selectedNote != nil)
        .animation(noteAnimation, value: isKeyboardActive)
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
    
    func deleteNoteFromContext() {
        if let deleteNote {
            context.delete(deleteNote)
            try? context.save()
            self.deleteNote = nil
        }
    }
}

#Preview {
    ContentView()
}
