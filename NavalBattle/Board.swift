//
//  Board.swift
//  NavalBattle
//
//  Created by SERGEY SHLYAKHIN on 25.03.2021.
//

import Foundation

struct Board {
    private let nColumns: Int
    private let nRows: Int
    private (set) var cells: [[Int]]
    
    init(nColumns: Int, nRows: Int) {
        self.nColumns = nColumns
        self.nRows = nRows
        cells = Array(repeating: Array(repeating: Helper.startBadge, count: nColumns), count: nRows)
    }
    
    func getStateOfCell(by coordinate: (Int, Int)) -> Int {
        return cells[coordinate.1][coordinate.0]
    }
    
    mutating func setStateForCell(by coordinate: (Int, Int), state: Int) {
        cells[coordinate.1][coordinate.0] = state
    }
    
    func showBoard() {
        guard !cells.isEmpty else {
            return
        }
        
        print("    " + Helper.headerForColumns())
        for row in cells.indices {
            let prefix = (row < 9 ? " " : "") + "\(row + 1)  "
            let output = prefix + Helper.stringBadgesFromIntArray(for: cells[row]) + "  " + prefix
            print(output)
        }
        print("    " + Helper.headerForColumns())
        print("=======" + Helper.roundSeparator())
    }
    
    static func showTwoBoards(cells: [[Int]]...) {
        guard !cells.isEmpty, cells.count == 2, (cells[0].count == cells[1].count) else {
            return
        }
        
        print("    " + Helper.headerForColumns() + "      " + Helper.headerForColumns())
        for row in cells[0].indices {
            let prefix = (row < 9 ? " " : "") + "\(row + 1)  "
            let output = prefix + Helper.stringBadgesFromIntArray(for: cells[0][row]) + "  " +
                         prefix + Helper.stringBadgesFromIntArray(for: cells[1][row])
            print(output)
        }
        print("    " + Helper.headerForColumns() + "      " + Helper.headerForColumns())
        print("===" + Helper.roundSeparator() + "=====" + Helper.roundSeparator())
    }
}
