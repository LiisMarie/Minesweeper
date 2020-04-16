//
//  Square.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation

class Square
{
    let row: Int
    let col: Int
    //  will give them default values that will be re-assigned later
    var numNeighboringMines = 0
    var isMineLocation = false
    var isRevealed = false
    
    init(row: Int, col: Int) {
        // store the row and column of the square in the grid
        self.row = row
        self.col = col
    }
}
