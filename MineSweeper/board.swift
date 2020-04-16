//
//  Board.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation

class Board
{
    //let size: Int
    let sizeRow: Int
    let sizeCol: Int
    var squares: [[Square]] = []  // a 2D array of square cells, indexed by [row][column]
    
    init(sizeRow: Int, sizeCol: Int) {
        self.sizeRow = sizeRow
        self.sizeCol = sizeCol
        
        for row in 0..<sizeRow {
            var squareRow: [Square] = []
            for col in 0..<sizeCol {
                let square = Square(row: row, col: col)
                squareRow.append(square)
            }
            squares.append(squareRow)
        }
    }
    
    func resetBoard() {
        // assign mines to squares
        for row in 0..<sizeRow{
            for col in 0..<sizeCol{
                squares[row][col].isRevealed = false
                self.calculateIsMineLocationForSquare(square: squares[row][col])
            }
        }
        
        // count number of neighboring squares
        for row in 0..<sizeRow {
            for col in 0..<sizeCol {
                self.calculateNumNeighborMinesForSquares(square: squares[row][col])
            }
        }
    }
    
    // gives mine to a square with a probability of 10%
    func calculateIsMineLocationForSquare(square: Square) {     // TODO change logic
        square.isMineLocation=((arc4random()%10)==0)
        // 1-in-10 chance that each location contains a mine
    }
    
    func calculateNumNeighborMinesForSquares(square: Square) {
        // first get a list of adjacent squares
        let neighbors = getNeighboringSquares(square: square)
        var numNeighboringMines = 0
        // for each neighbor with a mine, add 1 to this square's count
        for neighborSquare in neighbors {
            if neighborSquare.isMineLocation {
                numNeighboringMines += 1
            }
        }
        square.numNeighboringMines = numNeighboringMines
    }
    
    func getNeighboringSquares(square: Square) -> [Square] {
        var neighbors: [Square] = []
        // an array of tuples containing the relative position of each neighboor to the square
        let adjacentOffsets = [(-1,-1),(0,-1),(1,-1),(-1,0),(1,0),(-1,1),(0,1),(1,1)]
        for (rowOffset,colOffset) in adjacentOffsets {
            // getTileAtLocation may return a Square or it might return nil
            let optionalNeighbor:Square? = getTileAtLocation(row: square.row + rowOffset, col: square.col + colOffset)
            if let neighbor = optionalNeighbor { // only evaluates true if optional tile isnt nil
                neighbors.append(neighbor)
            }
        }
        return neighbors
    }
    
    func getTileAtLocation(row: Int, col: Int) -> Square? {
        if row >= 0 && row < self.sizeRow && col >= 0 && col < self.sizeCol {
            return squares[row][col]
        }
        return nil
    }
}
