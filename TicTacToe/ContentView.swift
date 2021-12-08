//
//  ContentView.swift
//  TicTacToe
//
//  Created by Richmond Walker Browne on 05/19/2021.
//  Copyright © 2021 REV
import SwiftUI
import Combine
    
enum SquareStatus {
    case empty
    case comp
    case user
}

struct Square {
    var status: SquareStatus
}

class ModelBoard: ObservableObject {
    @Published var squares = [Square]()
    init() {
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }

    func resetGame() {
        for i in 0...8 {
            squares[i].status = .empty
        }
    }

    var gameOver: (SquareStatus, Bool) {
        get {
            if thereIsAWinner != .empty {
                return (thereIsAWinner, true)
            } else {
                for i in 0...8 {
                    if squares[i].status == .empty {
                        return (.empty, false)
                    }
                }
                return (.empty, true)
            }
        }
    }

    private var thereIsAWinner:SquareStatus {
        get {
            if let check = self.checkIndexes([0, 1, 2]) {
                return check
            } else  if let check = self.checkIndexes([3, 4, 5]) {
                return check
            }  else  if let check = self.checkIndexes([6, 7, 8]) {
                return check
            }  else  if let check = self.checkIndexes([0, 3, 6]) {
                return check
            }  else  if let check = self.checkIndexes([1, 4, 7]) {
                return check
            }  else  if let check = self.checkIndexes([2, 5, 8]) {
                return check
            }  else  if let check = self.checkIndexes([0, 4, 8]) {
                return check
            }  else  if let check = self.checkIndexes([2, 4, 6]) {
                return check
            }
            return .empty
        }
    }

    private func checkIndexes(_ indexes: [Int]) -> SquareStatus? {
        var homeCounter:Int = 0
        var visitorCounter:Int = 0
        for anIndex in indexes {
            let aSquare = squares[anIndex]
            if aSquare.status == .user {
                homeCounter = homeCounter + 1
            } else if aSquare.status == .comp {
                visitorCounter = visitorCounter + 1
            }
        }
        if homeCounter == 3 {
            return .user
        } else if visitorCounter == 3 {
            return .comp
        }
        return nil
    }

    private func aiMove() {
        var anIndex = Int.random(in: 0 ... 8)
        while (makeMove(index: anIndex, player: .comp) == false && gameOver.1 == false) {
            anIndex = Int.random(in: 0 ... 8)
        }
    }

    func makeMove(index: Int, player:SquareStatus) -> Bool {
        if squares[index].status == .empty {
            var square = squares[index]
            square.status = player
            squares[index] = square
            if player == .user { aiMove() }
            return true
        }
        return false
    }
}



struct SquareView: View {
    var dataSource: Square
    var action: () -> Void
    var body: some View {
        Button(action: {
            print(self.dataSource.status)
            self.action()
        }) {
            Text((dataSource.status != .empty) ?
                (dataSource.status != .comp) ? "X" : "O"
                : " ")
                .font(.largeTitle)
                .foregroundColor(Color.black)
                .frame(minWidth: 60, minHeight: 60)
                .background(Color.blue)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        }
    }
}

struct MainBoard: View {
    @ObservedObject var checker = ModelBoard()
    @State private var isGameOver = false

    func buttonAction(_ index: Int) {
        _ = self.checker.makeMove(index: index, player: .user)
        self.isGameOver = self.checker.gameOver.1
    }
    var body: some View {
        VStack {
            Text("Tic Tac Toe")
                .bold()
            HStack {
                SquareView(dataSource: checker.squares[0]) { self.buttonAction(0) }
                SquareView(dataSource: checker.squares[1]) { self.buttonAction(1) }
                SquareView(dataSource: checker.squares[2]) { self.buttonAction(2) }
            }
            HStack {
                SquareView(dataSource: checker.squares[3]) { self.buttonAction(3) }
                SquareView(dataSource: checker.squares[4]) { self.buttonAction(4) }
                SquareView(dataSource: checker.squares[5]) { self.buttonAction(5) }
            }
            HStack {
                SquareView(dataSource: checker.squares[6]) { self.buttonAction(6) }
                SquareView(dataSource: checker.squares[7]) { self.buttonAction(7) }
                SquareView(dataSource: checker.squares[8]) { self.buttonAction(8) }
            }
            }
        .alert(isPresented: $isGameOver) {
                Alert(title: Text("Game Over"),
                      message: Text(self.checker.gameOver.0 != .empty ?
                        (self.checker.gameOver.0 == .user) ? "You Win!" : "iPhone Wins!"
                        : "Draw"), dismissButton: Alert.Button.destructive(Text("New Game"), action: {
                            self.checker.resetGame()
                        }) )
        }
    }
}



