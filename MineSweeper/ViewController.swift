//
//  ViewController.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var BOARD_SIZE_ROW: Int = 35
    var BOARD_SIZE_COL: Int = 35
    var board: Board
    var squareButtons: [SquareButton] = []
    var gameOn = false
    var currentlyPlacingFlags = false
    var difficulty: Int = 10
    
    let unopenedColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
    let openedColor = #colorLiteral(red: 0.7436007261, green: 0.7436007261, blue: 0.7436007261, alpha: 1)
    let boomedMineColor = #colorLiteral(red: 0.9201895622, green: 0.3224265123, blue: 0.341611661, alpha: 1)
    
    let minSquareSideLength = 38.2
    
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
    //@IBOutlet weak var boardView: UIView!
    //@IBOutlet weak var boardView: UIStackView!
    @IBOutlet weak var boardView: UIStackView!
    @IBOutlet weak var gameLabel: UIButton!
    
    required init?(coder aDecoder: NSCoder) {  // eemalda ?
        self.board = Board(sizeRow: BOARD_SIZE_ROW, sizeCol: BOARD_SIZE_COL)
        super.init(coder: aDecoder)
    }
    
    func initializeBoard() {
        // TODO dynamically changing board size
        for view in boardView.subviews {
            view.removeFromSuperview()
        }
        self.squareButtons = []
        let minFromRowCol = min(BOARD_SIZE_ROW, BOARD_SIZE_COL)
        let frameWidth = self.boardView.frame.width
        let frameHeight = self.boardView.frame.height
        var squareSize: CGFloat = min(frameHeight, frameWidth) / CGFloat(minFromRowCol)
        
        if squareSize < 38.2 {
            squareSize = 38.2
            self.BOARD_SIZE_ROW = Int(frameHeight / 38.2)
            self.BOARD_SIZE_COL = Int(frameWidth / 38.2)
        }
        
        self.board = Board(sizeRow: BOARD_SIZE_ROW, sizeCol: BOARD_SIZE_COL)

        print("minFromRowCol : \(minFromRowCol)")
        print("frameWidth : \(frameWidth)")
        print("frameHeight : \(frameHeight)")
        print("squareSize : \(self.boardView.frame.width / CGFloat(minFromRowCol))")
        
        for row in 0..<self.BOARD_SIZE_ROW {
            for col in 0..<self.BOARD_SIZE_COL {
                let square = board.squares[row][col]
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
                    openSquareButton(squareButton: sender)
                }
                if sender.square.isMineLocation {
                    // player pressed on mine
                    self.endCurrentGame()
                    self.showAllBombs()
                    sender.backgroundColor = boomedMineColor
                    self.gameLabel.setTitle(gameLostText, for: .normal)
                }
                if sender.getLabelText() == "" {
                    print("will have to open neighbors")
                    self.openNeighborsOfEmptyCell(squareButton: sender)
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
            if self.hasGameBeenWon() {
                self.endGamePlayerWon()
            }
            
        }
        
    }
    
    func openSquareButton(squareButton: SquareButton) {
        squareButton.square.isRevealed = true
        squareButton.setTitle("\(squareButton.getLabelText())", for: .normal)
        squareButton.backgroundColor = openedColor
    }
    
    func findSquareButtonBySquare(square: Square) -> SquareButton? {
        for squareButton in squareButtons {
            if squareButton.square.row == square.row && squareButton.square.col == square.col {
                return squareButton
            }
        }
        return nil
    }
    
    func openNeighborsOfEmptyCell(squareButton: SquareButton) {
        if squareButton.getLabelText() != "" {
            openSquareButton(squareButton: squareButton)
            //return
        } else {
            openSquareButton(squareButton: squareButton)
            let adjacentOffsets = [(0,-1),(-1,0),(1,0),(0,1)]
            for (rowOffset,colOffset) in adjacentOffsets {
                // getTileAtLocation may return a Square or it might return nil
                let optionalNeighbor:Square? = self.board.getTileAtLocation(row: squareButton.square.row + rowOffset, col: squareButton.square.col + colOffset)
                if let neighbor = optionalNeighbor { // only evaluates true if optional tile isnt nil
                    // print("neighbor row: \(neighbor.row)  col: \(neighbor.col)")
                    if !neighbor.isRevealed {
                        if let neighborButton = self.findSquareButtonBySquare(square: neighbor) {
                            openSquareButton(squareButton: neighborButton)
                            self.openNeighborsOfEmptyCell(squareButton: neighborButton)
                        }
                    }
                    
                }
            
            }
        }
    }
    
    func hasGameBeenWon() -> Bool {  // TODO
        // returns true if game has been won
        if self.bombsLeft == 0 {
            var flaggedBombs = 0
            for squareButton in squareButtons {
                if !squareButton.square.isRevealed {  // if button hasnt been revealed
                    
                    if squareButton.square.isMineLocation {  // if at button location is a mine
                        
                        if !squareButton.flagPlaced {  // if theres no flag
                            return false
                        } else { // if there is a flag, +1 to the counter
                            flaggedBombs += 1
                        }
                    }
                }
            }
            if flaggedBombs == self.board.squaresWithMines.count {  // if amount of correctly placed flags matches bombs amount then player has won
                return true
            }
        }
        return false
    }
    
    func endGamePlayerWon() { // TODO
        // logic upon game has been won
        self.gameLabel.setTitle(gameWonText, for: .normal)
        self.endCurrentGame()
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
        self.board.resetBoard(difficulty: self.difficulty)
        // iterates through each button and resets it to default
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = unopenedColor
            squareButton.setTitle("", for: .normal)
            squareButton.flagPlaced = false
        }
        self.bombsLeft = self.board.squaresWithMines.count
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
        self.initializeBoard()
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
        
        updateOrientationUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientationUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        
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
    
    @IBAction func changeOfLevel(_ sender: UIButton) {
        switch sender.title(for: .normal) {
        case "L1":
            sender.setTitle("L2", for: .normal)
            self.difficulty = 20
            print("Player chose L2")
        case "L2":
            sender.setTitle("L3", for: .normal)
            self.difficulty = 30
            print("Player chose L3")
        case "L3":
            sender.setTitle("L1", for: .normal)
            self.difficulty = 10
            print("Player chose L1")
        default:
            print("Unknown value for level")
        }
    }
    
    // see fn kutsutakse välja kui traitidega muutub midagi
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOrientationUI()
    }
    
    @objc func updateOrientationUI() {
        var orientationText = "Orient: "
        switch UIDevice.current.orientation {
        case .faceUp:
            orientationText += "faceUp"
        case .faceDown:
            orientationText += "faceDown"
        case .landscapeLeft:
            orientationText += "landscapeLeft"
        case .landscapeRight:
            orientationText += "landscapeRight"
        case .portrait:
            orientationText += "portrait"
        case .portraitUpsideDown:
            orientationText += "portraitUpsideDown"
        case .unknown:
            orientationText += "unknown"
        default:
            orientationText += "new"
        }
        // print("updateOrientationUI \(orientationText)")
    }
    
    // kui kogu kontrolleri suurus muutub
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateOrientationUI()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOrientationUI()
    }
    
    
}
