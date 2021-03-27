//
//  main.swift
//  NavalBattle
//
//  Created by SERGEY SHLYAKHIN on 25.03.2021.
//

import Foundation

var game = Game(nColums: Helper.sideOfBoard, nRows: Helper.sideOfBoard, ships: Helper.ships)

game.rearrangeShipsOnBoard()
game.gameCycle()

