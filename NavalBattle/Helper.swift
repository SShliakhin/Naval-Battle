//
//  Helper.swift
//  NavalBattle
//
//  Created by SERGEY SHLYAKHIN on 25.03.2021.
//

import Foundation

struct Helper {
    
    static let sideOfBoard = 10
    static let ships = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1]
    static let digitToBadge = [
                    "-1" : "*",//мимо
                    "0" : " ", //не известно
                    "1" : "~", //не стоит стрелять
                    "2" : "@", //попадание "⦻"
                    "3" : "☗"] //корабль "☗" "#"
    static let startBadge = 0
    static let shipBadge = 3
    static let noBlankShot: [Int] = [startBadge, shipBadge]
    static let columnToDigit = ["a" : 0, "b" : 1, "c" : 2, "d" : 3, "e" : 4, "f" : 5, "g" : 6, "h" : 7, "i" : 8, "j" : 9]
    static var digitToColumn: [Int: String] {
        var dic = [Int: String]()
        for (key, value) in Helper.columnToDigit {
            dic[value] = key
        }
        return dic
    }
    
    static func stringBadgesFromIntArray (for array: [Int], separator: String = "  ") -> String {
        var str = array.map{String($0)}.joined(separator: separator)

        for (key, value) in Helper.digitToBadge.sorted(by: {$0.key < $1.key}) {
            str = str.replacingOccurrences(of: key, with: value)
        }

        return str
    }
    
    static func headerForColumns (columns: Int = Helper.columnToDigit.count, separator: String = "  ") -> String {
        return Helper.columnToDigit.keys.sorted()[0 ..< columns].joined(separator: separator)
    }
    
    static func roundSeparator (count: Int = Helper.columnToDigit.count, separator: String = "=") -> String {
        return Array(repeating: separator, count: count + count - 5).joined(separator: separator)
    }
    
}
