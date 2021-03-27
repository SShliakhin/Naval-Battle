//
//  Game.swift
//  NavalBattle
//
//  Created by SERGEY SHLYAKHIN on 26.03.2021.
//

import Foundation

struct Game {
    
    private var fleets = [Fleet]()
    private var fComp: Fleet {
        fleets[0]
    }
    private var fUser: Fleet {
        fleets[1]
    }
    
    private let nRows: Int
    private let ships: [Int]
    
    private let nPlayers = 2
    private var round = 0
    private var isBonus = false
    private var message = ""
    
    private var isGameOver: Bool {
        fleets.filter{$0.noShips}.count > 0
    }
    private var isCompWinner: Bool {
        fUser.noShips
    }
    
    init(nColums: Int, nRows: Int, ships: [Int]) {
        self.nRows = nRows
        self.ships = ships
        for _ in 0..<nPlayers {
            fleets.append(Fleet(columns: nColums, rows: nRows, ships: ships))
        }
        fleets[1].arrangeShipsOnBoard()
    }
    
    // MARK: - Input
    private func askCoordinate(rangeForRows: ClosedRange<Int>) -> (isOk: Bool, (Int, Int), String) {
        
        print("[column row]: >> ", terminator: "")
        
        guard let response = readLine() else {
            return (false, (-1, -1), "")
        }
        
        let responseArray = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
        if responseArray.count >= 2,
           let x = Helper.columnToDigit[responseArray[0]],
           let y = Int(responseArray[1]),
           rangeForRows.contains(y) {
            return (true, (x, y - 1), responseArray.joined(separator: ""))
        }
        return (false, (-1, -1), "")
    }
    
    private func askYesNo(message: String) -> (isOk: Bool, result: Bool) {
        
        print(message)
        print("Y/N (y/n): >> ", terminator: "")
        
        guard let response = readLine() else {
            return (false, false)
        }
        
        let answer = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch answer {
        case "Y", "y":
            return (true, true)
        case "N", "n":
            return (true, false)
        default:
            return (false, false)
        }
    }
    
    // MARK: - Output
    private func headerForNewRound() {
        print()
        print("***")
        print("--> Round \(round) left ships for target (your & comp): \(fComp.shipsLeft) & \(fUser.shipsLeft) ")
        print()
        Board.showTwoBoards(cells: fComp.cells, fUser.cells)
        print()
    }
    
    private func greetingWinner() {
        print()
        print("********* " + (isCompWinner ? "COMP" : "YOU ") + " W I N !"  + " *********")
        print()
        Board.showTwoBoards(cells: fComp.cells, fUser.cells)
        print()
    }

    // MARK: - Game
    mutating func rearrangeShipsOnBoard() {
        fUser.showBoard()
        print()
        message = "Do you want to rearrange ships on your board?"
        var (isOk, result) = askYesNo(message: message)
        while !isOk {
            (isOk, result) = askYesNo(message: message)
        }
        if result {
            fleets[1].resetShips()
            
            for ship in ships {
                print()
                print("Input coordinate for \(ship)-parts ship: ")
                var (isOk, (x, y), _) = askCoordinate(rangeForRows: 1...nRows)
                while !isOk {
                    (isOk, (x, y), _) = askCoordinate(rangeForRows: 1...nRows)
                }
                
                var isCreated = fleets[1].setShip(ship, about: (x, y))
                while !isCreated {
                    print("used random ... sorry!")
                    isCreated = fleets[1].setShip(ship, about: fUser.randomCoordinate)
                }
                
                fleets[1].arrangeShipsOnBoard()
                fUser.showBoard()
            }
            
            fleets[1].addIndexesForShipsToMap()
            fleets[1].resetUsedCoordinates()
        }
    }
    
    mutating func gameCycle () {
        
        start: while !isGameOver {
            round += 1
            headerForNewRound()
            
            var (isOk, (x, y), userInput) = askCoordinate(rangeForRows: 1...nRows)
            while !isOk {
                (isOk, (x, y), userInput) = askCoordinate(rangeForRows: 1...nRows)
            }
            
            (isBonus, message) = fleets[0].shot(by: (x, y), userInput: userInput)
            print(message)
            
            while isBonus {
                if isGameOver { break start }
                
                fleets[0].showBoard()
                
                var (isOk, (x, y), userInput) = askCoordinate(rangeForRows: 1...nRows)
                while !isOk {
                    (isOk, (x, y), userInput) = askCoordinate(rangeForRows: 1...nRows)
                }
                
                (isBonus, message) = fleets[0].shot(by: (x, y), userInput: userInput)
                print(message)
            }
            
            (isBonus, message) = fleets[1].compShot()
            print("COMP: " + message)
            
            while isBonus {
                if isGameOver { break start }
                
                (isBonus, message) = fleets[1].compShot()
                print("COMP: " + message)
            }

        }
        
        fleets[0].arrangeShipsOnBoard() //show left ships maybe
        greetingWinner()
        
    }
    
}





