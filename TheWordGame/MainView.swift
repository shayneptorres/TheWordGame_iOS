//
//  MainView.swift
//  TheWordGame
//
//  Created by Shayne Torres on 10/28/22.
//

import SwiftUI
import Combine

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Word.timestamp, ascending: true)],
        animation: .default)
    private var words: FetchedResults<Word>
    
    @State var showPlayGameView = false
    @State var currText: String = ""
    @State var gameWords: [Word] = []
    @State var currentWordIndex = 0
    @State var correctCount = 0
    @State var time = 30
    @State var prevTime = 45
    @State var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Button(action: {
                onPlay()
            }, label: {
                Label("Play Game", systemImage: "play.fill")
                    .font(.system(size: 64))
            })
            .padding(.bottom)
            HStack {
                Text("Previous Round: ")
                Label("\(correctCount)", systemImage: "hand.thumbsup.circle.fill")
                    .foregroundColor(.green)
            }
            .font(.system(size: 32))
            Picker("Time", selection: $time) {
                ForEach(Array(0...60), id: \.self) {
                    Text("\($0) sec").tag($0)
                }
            }
        }
        .fullScreenCover(isPresented: $showPlayGameView) {
            NavigationStack {
                ZStack {
                    HStack {
                    }
                    VStack {
                        Label("\(correctCount)", systemImage: "hand.thumbsup.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.green)
                        Label("\(time)", systemImage: "hourglass")
                            .foregroundColor(.orange)
                            .font(.system(size: 64))
                        Text(currText)
                            .transition(.slide)
                            .font(.system(size: 80))
                            .padding(.top, 100)
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: onPrev, label: {
                                Image(systemName: "arrow.backward.circle.fill")
                                    .font(.system(size: 80))
                            })
                            Spacer()
                            Button(action: onSkip, label: {
                                Image(systemName: "arrowshape.bounce.forward.fill")
                                    .font(.system(size: 80))
                            })
                            Spacer()
                            Button(action: onNext, label: {
                                Image(systemName: "hand.thumbsup.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                            })
                            Spacer()
                        }
                    }
                }
                .onTapGesture {
                    
                }
                .toolbar {
                    Button(action: {
                        showPlayGameView = false
                    }, label: {
                        Text("Dismiss")
                            .bold()
                    })
                }
            }
            .onReceive(timer) { input in
                time -= 1
                if time == 0 {
                    showPlayGameView = false
                }
            }
            .onAppear {
                correctCount = 0
                currentWordIndex = 0
                gameWords = Array(words.filter { !$0.wasSeen }).shuffled()
                updateCurrWord()
                timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            }
            .onDisappear {
                self.timer.upstream.connect().cancel()
                time = prevTime
            }
        }
    }
}

extension MainView {
    func onPlay() {
        prevTime = time
        showPlayGameView = true
    }
    
    func onNext() {
        withAnimation {
            gameWords[currentWordIndex].wasSeen.toggle()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            currentWordIndex += 1
            correctCount += 1
            updateCurrWord()
        }
    }
    
    func onPrev() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
        }
        withAnimation {
            updateCurrWord()
        }
    }
    
    func onSkip() {
        withAnimation {
            currentWordIndex += 1
            updateCurrWord()
        }
    }
    
    func updateCurrWord() {
        guard !gameWords.isEmpty else {
            showPlayGameView = false
            return
        }
        if currentWordIndex >= 0 && currentWordIndex < gameWords.count {
            let text = gameWords[currentWordIndex].name ?? ""
            print("set: \(text)")
            currText = text
        } else {
            print("finish")
            currentWordIndex = 0
            showPlayGameView = false
            return
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
