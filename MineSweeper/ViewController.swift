//
//  ViewController.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let BOARD_SIZE_ROW: Int = 18
    let BOARD_SIZE_COL: Int = 10
    var board: Board
    var squareButtons: [SquareButton] = []
    var gameOn = false
    var currentlyPlacingFlags = false
    
    let unopenedColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
    let openedColor = #colorLiteral(red: 0.7436007261, green: 0.7436007261, blue: 0.7436007261, alpha: 1)
    let boomedMineColor = #colorLiteral(red: 0.9201895622, green: 0.3224265123, blue: 0.341611661, alpha: 1)
    
    let bomb = "💣"
    let flag = "🚩"
    
    let gameOnText = "😊"
    let gameLostText = "😵"
    let gameWonText = "🥳"
    
    var bombsLeft: Int = 0
    {
        didSet {  // everytime the value changes, didset will be triggered
            self.bombsLeftLabel.text = "💣 \(bombsLeft)"
            self.bombsLeftLabel.sizeToFit()  // size of label will be adjusted
        }
    }
    var timeTaken:Int = 0
    {
        didSet {
            self.timeLabel.text = "⏱ \(timeTaken)"
            self.timeLabel.sizeToFit()
        }
    }
    
    var oneSecondTimer: Timer?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bombsLeftLabel: UILabel!
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var gameLabel: UIButton!
    
    func initializeBoard() {
        // TODO dynamically changing board size
        for row in 0..<board.sizeRow {
            for col in 0..<board.sizeCol {
                let square = board.squares[row][col]
                let squareSize: CGFloat = self.boardView.frame.width / CGFloat(BOARD_SIZE_COL)
                let squareButton = SquareButton(squareModel: square, squareSize: squareSize, squareMargin: 1)
                squareButton.setTitleColor(UIColor.darkGray, for: .normal)
                squareButton.addTarget(self, action: #selector(squareButtonPressed), for: .touchUpInside)  // Selector(("squareButtonPressed:"))
                self.boardView.addSubview(squareButton)
                self.squareButtons.append(squareButton)
            }
        }
    }
    
     @objc func squareButtonPressed(sender: SquareButton) {
        print("Pressed row:\(sender.square.row), col:\(sender.square.col)")
        
        if self.gameOn {
            
            if !currentlyPlacingFlags && !sender.flagPlaced {  // if player isnt currently placing flags and current location has no flag
                if (!sender.square.isRevealed) {
                    sender.square.isRevealed = true
                    sender.setTitle("\(sender.getLabelText())", for: .normal)
                    sender.backgroundColor = openedColor
                    
                    if self.hasGameBeenWon() {
                        self.endGamePlayerWon()
                    }
                    
                }
                if sender.square.isMineLocation {
                    // player pressed on mine
                    self.endCurrentGame()
                    self.showAllBombs()
                    sender.backgroundColor = boomedMineColor
                    self.gameLabel.setTitle(gameLostText, for: .normal)
                }
            }  else if currentlyPlacingFlags {  // if player is currently placing flags
                if sender.flagPlaced {
                    // theres already a flag, remove it
                    sender.setTitle("", for: .normal)
                    sender.flagPlaced = false
                    self.bombsLeft += 1
                } else {
                    // theres no flag, so place the flag
                    sender.setTitle(flag, for: .normal)
                    sender.flagPlaced = true
                    self.bombsLeft -= 1
                }
            }
            
        }
        
    }
    
    func hasGameBeenWon() -> Bool {  // TODO
        // returns true if game has been won
        return false
    }
    
    func endGamePlayerWon() { // TODO
        // logic upon game has been won
        self.gameLabel.setTitle(gameWonText, for: .normal)
    }
    
    func showAllBombs() {
        // shows all bombs
        for squareButton in squareButtons {
            if !squareButton.square.isRevealed {  // if button hasnt been revealed
                
                if squareButton.square.isMineLocation {  // if at button location is a mine
                    
                    if !squareButton.flagPlaced {  // if theres no flag
                        squareButton.backgroundColor = openedColor
                        squareButton.setTitle("\(squareButton.getLabelText())", for: .normal)
                    }
                    // if there is a flag, it just remains like that
                } else {  // there is no mine
                    if squareButton.flagPlaced {  // theres a flag
                        squareButton.backgroundColor = openedColor
                        squareButton.setTitle("❌", for: .normal)
                    }
                }
            }
        }
    }
    
    
    func resetBoard() {
        // resets board with new mine locations & sets isRevealed to false for each square
        self.board.resetBoard()
        // iterates through each button and resets it to default
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = unopenedColor
            squareButton.setTitle("", for: .normal)
            squareButton.flagPlaced = false
        }
    }
    
    func endCurrentGame() {
        if self.oneSecondTimer != nil {
            self.oneSecondTimer!.invalidate()
            self.oneSecondTimer = nil
        }
        self.gameOn = false
    }
    
    func startNewGame() {
        // start new game
        self.resetBoard()
        self.gameLabel.setTitle(gameOnText, for: .normal)
        
        self.timeTaken = 0
        self.oneSecondTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneSecond), userInfo: nil, repeats: true)
        
        self.gameOn = true
        
        self.bombsLeft = self.board.squaresWithMines.count
    }
    
    @objc func oneSecond() {
        self.timeTaken += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.initializeBoard()
        self.startNewGame()
        
    }

    @IBAction func newGamePressed(_ sender: Any) {
        self.endCurrentGame()
        print("new game")
        self.startNewGame()
    }
    
    @IBAction func bombFlagSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.currentlyPlacingFlags = false
        } else {
            self.currentlyPlacingFlags = true
        }
        print("Player currently placing flags \(self.currentlyPlacingFlags)")
        
    }
    
    required init?(coder aDecoder: NSCoder) {  // eemalda ?
        self.board = Board(sizeRow: BOARD_SIZE_ROW, sizeCol: BOARD_SIZE_COL)
        super.init(coder: aDecoder)
    }
    
    
}
