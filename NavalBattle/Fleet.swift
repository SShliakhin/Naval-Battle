//
//  Fleet.swift
//  NavalBattle
//
//  Created by SERGEY SHLYAKHIN on 26.03.2021.
//

import Foundation

struct Fleet {
    
    private var board: Board
    private let nColumns: Int
    private let nRows: Int
    var cells: [[Int]] {
        board.cells
    }
    
    private var usedCoordinates = [[Int]]() // массив используется для фильтрации возможных координат для кораблей и потом чтобы комп не повторял ходы - после создания возможности пользователю самому расставлять корабли, создал публичную функцию по его обнулению - по хорошему надо добавить новое хранилище и разделить по ним эти функции
    var randomCoordinate: (x: Int, y: Int) {
        var x = Int.random(in: 0..<nColumns)
        var y = Int.random(in: 0..<nRows)
        while usedCoordinates.contains([x,y]) {
            x = Int.random(in: 0..<nColumns)
            y = Int.random(in: 0..<nRows)
        }
        return (x, y)
    }
    
    private var lastResultMoves = [[Int]]() //фиксируем результативные ходы до очередного потопления коробля
    private var posibleMoves = [[Int]]() // готовые возможные ходы, корректируются в зависимости от очередного попадания
    
    private var ships = [Ship]()
    private var shipsMap = [String: Int]()
    
    var shipsLeft: Int {
        ships.filter{!($0.isKilled ?? false)}.count
    }
    var noShips: Bool {
        shipsLeft == 0
    }
    
    private struct Ship {
        var hits = 0
        let coordinates: [[Int]]
        let hDirection: Bool
        var isKilled: Bool? {
            hits == 0 ? nil : hits == coordinates.count
        }
        
        init(hDirection: Bool, coordinates: [[Int]]) {
            self.hDirection = hDirection
            self.coordinates = coordinates
        }
    }
    
    init(columns: Int, rows: Int, ships: [Int]) {
        board = Board(nColumns: columns, nRows: rows)
        nColumns = columns
        nRows = rows
        setShips(ships)
        addIndexesForShipsToMap()
    }
    
    func showBoard () {
        board.showBoard()
    }

    //MARK: - Ships
    private mutating func setShips(_ ships: [Int]) {
        for ship in ships {
            var isCreated = false
            while !isCreated {
                isCreated = setShip(ship, about: randomCoordinate)
            }
        }
        resetUsedCoordinates() // после установки кораблей обнуляем массив, чтобы использовать для игры за комп
    }
    
    mutating func setShip(_ items: Int, about coordinate: (Int, Int)) ->  Bool {
        let (x, y) = coordinate
        var vPosible = [[Int]]() //вертикальные варианты х постоянное
        var hPosible = [[Int]]() //горизонтальные варианты y постоянно
        
        var low = max(0, y - items + 1)
        var high = min(y + items, nRows)
        for y in low ..< high {
            if !usedCoordinates.contains([x, y]) {
                vPosible.append([x, y])
            }
        }
        low = max(0, x - items + 1)
        high = min(x + items, nColumns)
        for x in low ..< high {
            if !usedCoordinates.contains([x, y]) {
                hPosible.append([x, y])
            }
        }
        
        let (vCount, hCount) = (vPosible.count, hPosible.count)
        guard vCount >= items || hCount >= items else {
            return false
        }
        
        var shipCoordinates = [[Int]]()
        
        //случайным образом выбрать направление
        let hDirection = (Bool(truncating: NSNumber(value: Int.random(in: 0...1))) && hCount >= items) || !(vCount >= items)
        
        if !hDirection {
            for i in 0..<items {
                let x = vPosible[i].first!
                let y = vPosible[i].last!
                usedCoordinates.append([x, y])
                usedCoordinates.append([x + 1, y])
                usedCoordinates.append([x - 1, y])
                if i == 0 {
                    usedCoordinates.append([x, y - 1])
                    usedCoordinates.append([x + 1, y - 1])
                    usedCoordinates.append([x - 1, y - 1])
                }
                if i == items - 1 {
                    usedCoordinates.append([x, y + 1])
                    usedCoordinates.append([x + 1, y + 1])
                    usedCoordinates.append([x - 1, y + 1])
                }
                shipCoordinates.append([x, y])
            }
        } else {
            for i in 0..<items {
                let x = hPosible[i].first!
                let y = hPosible[i].last!
                usedCoordinates.append([x, y])
                usedCoordinates.append([x, y + 1])
                usedCoordinates.append([x, y - 1])
                if i == 0 {
                    usedCoordinates.append([x - 1, y])
                    usedCoordinates.append([x - 1, y + 1])
                    usedCoordinates.append([x - 1, y - 1])
                }
                if i == items - 1 {
                    usedCoordinates.append([x + 1, y])
                    usedCoordinates.append([x + 1, y + 1])
                    usedCoordinates.append([x + 1, y - 1])
                }
                shipCoordinates.append([x, y])
            }
        }
        ships.append(Ship(hDirection: hDirection, coordinates: shipCoordinates))
        return true
    }
    
    mutating func addIndexesForShipsToMap() {
        for i in ships.indices {
            for coordinate in ships[i].coordinates {
                let key = getUserInputForCoordinate((coordinate.first!, coordinate.last!))
                shipsMap[key] = i
            }
        }
    }

    /// попытка получить индекс коробля в списке кораблей из словаря
    private func tryGetShip(byUserInput key: String) -> Int? {
        guard let index = shipsMap[key] else {
            return nil
        }
        
        return index
    }
    
    mutating func arrangeShipsOnBoard() {
        for i in ships.indices {
            for coordinate in ships[i].coordinates {
                let (x, y) = (coordinate.first!, coordinate.last!)
                if board.getStateOfCell(by: (x: x, y: y)) == Helper.startBadge {
                    board.setStateForCell(by: (x: x, y: y), state: Helper.shipBadge)
                }
            }
        }
    }
    
    mutating func resetShips () {
        ships = [Ship]()
        shipsMap.removeAll()
        board = Board(nColumns: nColumns, nRows: nRows)
    }
    
    
    // MARK: - Shots
    mutating func shot(by coordinate: (Int, Int), userInput: String) -> (Bool, String) {

        var currentState = board.getStateOfCell(by: coordinate)
        var result = ""
        var bonus = false
        
        if Helper.noBlankShot.contains(currentState) {
            usedCoordinates.append([coordinate.0, coordinate.1])
            
            if let shipIndex = tryGetShip(byUserInput: userInput) {
                //попадание
                ships[shipIndex].hits += 1 //фиксируем
                let ship = ships[shipIndex] //получаем корабль
                
                if ship.isKilled! {
                    arroundKilledShipNoShoot(ship: ship)
                    resetPosibleMoves()
                } else {
                    changePosibleMoves(by: coordinate)
                }
                
                currentState = Helper.shipBadge
                
                result = "hit: \(ship.isKilled! ? "killed" : "hurt")"
                bonus = true
            } else {
                result = "miss"
            }
           
            board.setStateForCell(by: coordinate, state: currentState - 1)
        } else {
            result = "shouldn't have shot here - Blank Shot"
        }
        
        return (bonus, result)
    }
    
    mutating func compShot() -> (Bool, String) {
        var (x, y) = randomCoordinate
        if !posibleMoves.isEmpty {
            let randomIndex = Int.random(in: 0 ..< posibleMoves.count)
            (x, y) = (posibleMoves[randomIndex].first!, posibleMoves[randomIndex].last!)
            posibleMoves.remove(at: randomIndex)
        }
        return shot(by: (x, y), userInput: getUserInputForCoordinate((x, y)))
    }
    
    
    // MARK: - обработка потопленного корабля
    private mutating func setBadgeNoShoot(for coordinate: (Int, Int)) {
        let (x, y) = coordinate
        guard (0 ..< nColumns).contains(x),
              (0 ..< nRows).contains(y) else {
            return
        }
        if board.getStateOfCell(by: coordinate) == Helper.startBadge {
            board.setStateForCell(by: coordinate, state: Helper.startBadge + 1)
            
            usedCoordinates.append([x, y]) // для подсказки компу
        }
    }
    
    private mutating func arroundKilledShipNoShoot(ship: Ship) {
        for i in ship.coordinates.indices {
            let (x, y) = (ship.coordinates[i].first!, ship.coordinates[i].last!)
            if !ship.hDirection {
                setBadgeNoShoot(for: (x + 1, y))
                setBadgeNoShoot(for: (x - 1, y))
                if i == 0 {
                    setBadgeNoShoot(for: (x, y - 1))
                    setBadgeNoShoot(for: (x + 1, y - 1))
                    setBadgeNoShoot(for: (x - 1, y - 1))
                }
                if i == ship.coordinates.indices.count - 1 {
                    setBadgeNoShoot(for: (x, y + 1))
                    setBadgeNoShoot(for: (x + 1, y + 1))
                    setBadgeNoShoot(for: (x - 1, y + 1))
                }
            } else {
                setBadgeNoShoot(for: (x, y + 1))
                setBadgeNoShoot(for: (x, y - 1))
                if i == 0 {
                    setBadgeNoShoot(for: (x - 1, y))
                    setBadgeNoShoot(for: (x - 1, y + 1))
                    setBadgeNoShoot(for: (x - 1, y - 1))
                }
                if i == ship.coordinates.indices.count - 1 {
                    setBadgeNoShoot(for: (x + 1, y))
                    setBadgeNoShoot(for: (x + 1, y + 1))
                    setBadgeNoShoot(for: (x + 1, y - 1))
                }
            }
        }
    }
    
    // MARK: - стратегия компа
    private mutating func addCoordinateForMove(_ coordinate: (Int, Int)) {
        guard (0 ..< nColumns).contains(coordinate.0),
              (0 ..< nRows).contains(coordinate.1) else {
            return
        }
        if !usedCoordinates.contains([coordinate.0,coordinate.1]) {
            posibleMoves.append([coordinate.0, coordinate.1])
        }
    }
    
    private mutating func addPosibleMovesAroundCoordinate(_ coordinate: (Int, Int)) {
        let deltas = [          [-1, 0],
                        [0, -1],         [0, 1],
                                [1, 0]              ]
        for delta in deltas {
            addCoordinateForMove((coordinate.0 + delta[0], coordinate.1 + delta[1]))
        }
    }
    
    private mutating func changePosibleMoves(by coordinate: (Int, Int)) {
        
        lastResultMoves.append([coordinate.0, coordinate.1])
        addPosibleMovesAroundCoordinate(coordinate)
        
        if lastResultMoves.count > 1 {
            let (x, y) = (coordinate.0, coordinate.1)
            // если это очередное попадание, надо понять направление возможных ходов
            let vDirection = x == lastResultMoves[0].first!
            if vDirection {
                // сохранить только с одинаковыми х
                posibleMoves = posibleMoves.filter{ $0.first == x }
            } else {
                // сохранить только с одинаковыми y
                posibleMoves = posibleMoves.filter{ $0.last == y }
            }
        }
    }
    
    private mutating func resetPosibleMoves() {
        lastResultMoves = [[Int]]()
        posibleMoves = [[Int]]()
    }
    
    mutating func resetUsedCoordinates() {
        usedCoordinates = [[Int]]()
    }
    
    // MARK: - вспомогательные
    private func getUserInputForCoordinate(_ coordinate: (Int, Int)) -> String {
        Helper.digitToColumn[coordinate.0]! + String(coordinate.1 + 1)
    }
    
}
