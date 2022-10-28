//
//  ContentView.swift
//  TheWordGame
//
//  Created by Shayne Torres on 10/28/22.
//

import SwiftUI
import CoreData

struct WordsView: View {
    enum Sort {
        case alpha
        case created
        case seen
    }
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State var newWordName = ""
    @State var sort = Sort.created

    var sortedWords: [Word] {
        switch sort {
        case .alpha:
            return words.sorted { $0.name ?? "" < $1.name ?? "" }
        case .created:
            return words.sorted { $0.timestamp ?? Date() < $1.timestamp ?? Date() }
        case .seen:
            return words.sorted { first, sec in first.wasSeen }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("New Word Name", text: $newWordName)
                }
                Section {
                    Text("Total Words: \(words.count)")
                    Text("Seen Words: \(words.filter { $0.wasSeen }.count)")
                    Text("Words Left: \(words.filter { !$0.wasSeen }.count)")
                }
                Picker("Sort by", selection: $sort) {
                    Image(systemName: "calendar").tag(Sort.created)
                    Image(systemName: "abc").tag(Sort.alpha)
                    Image(systemName: "eye").tag(Sort.seen)
                }
                ForEach(sortedWords) { word in
                    Button(action: {
                        onTap(word)
                    }, label: {
                        HStack {
                            Text(word.name!)
                                .strikethrough(word.wasSeen)
                            Spacer()
                            Image(systemName: word.wasSeen ? "eye" : "")
                        }
                        .foregroundColor(word.wasSeen ? .gray : .accentColor)
                    })
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: { hideKeyboard() }) {
                        Text("Done")
                            .bold()
                    }
                    Button(action: addWord) {
                        Text("Add")
                            .bold()
                    }
                }
            }
        }
    }
    
    private func onTap(_ word: Word) {
        withAnimation {
            word.wasSeen.toggle()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addWord() {
        guard !self.newWordName.isEmpty else { return }
        withAnimation {
            let newWord = Word(context: viewContext)
            newWord.id = UUID().uuidString
            newWord.timestamp = Date()
            newWord.name = newWordName
            newWord.wasSeen = false

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            newWordName = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { words[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct WordsView_Previews: PreviewProvider {
    static var previews: some View {
        WordsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
