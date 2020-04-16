//
//  SquareButton.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import Foundation
import UIKit

class SquareButton: UIButton {
    
    let squareSize: CGFloat
    let squareMargin: CGFloat
    var square: Square
    var flagPlaced: Bool = false
    
    init(squareModel: Square, squareSize: CGFloat, squareMargin: CGFloat) {
        self.square = squareModel
        self.squareSize = squareSize
        self.squareMargin = squareMargin
        let x = CGFloat(self.square.col) * (squareSize + squareMargin)
        let y = CGFloat(self.square.row) * (squareSize + squareMargin)
        let squareFrame = CGRect(x: x, y: y, width: squareSize, height: squareSize)
        super.init(frame: squareFrame)
    }
    
    func getLabelText() -> String {
        // check the numNeighboringMines and isMineLocation properties for determining the text to be displayed
        if !self.square.isMineLocation {
            if self.square.numNeighboringMines==0 {
                // theres no mine and no neighboring mines
                return ""
            }
            // else theres no mine but there are neighboring mines
            return "\(self.square.numNeighboringMines)"
        }
        // there is a mine
        return "💣"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
