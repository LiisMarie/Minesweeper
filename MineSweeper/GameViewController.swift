//
//  ViewController.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bombsLeftLabel: UILabel!
    @IBOutlet weak var boardView: UIStackView!
    @IBOutlet weak var bombFlagSegmentedControl: UISegmentedControl!
    @IBOutlet weak var gameLabel: UIButton!
    
    var BOARD_SIZE_ROW: Int = 15
    var BOARD_SIZE_COL: Int = 15
    var board: Board
    var squareButtons: [SquareButton] = []
    var gameOn = false
    var currentlyPlacingFlags = false
    var difficulty: Int = 10
        
    var gameStartedInPortrait = true
    
    let minSquareSideLength = 38.2
    
    var theme = C.THEME_ONE

    var unopenedColor = C.THEME_ONE_UNOPENED_COLOR
    var openedColor = C.THEME_ONE_OPENED_COLOR
    var boomedMineColor = C.THEME_ONE_BOOMED_MINE_COLOR
    var titleColor = C.THEME_ONE_TITLE_COLOR
        
    var bomb = C.THEME_ONE_BOMB
    var flag = C.THEME_ONE_FLAG
    
    var gameOnText = C.THEME_ONE_GAME_ON_TEXT
    var gameLostText = C.THEME_ONE_GAME_ON_TEXT
    var gameWonText = C.THEME_ONE_GAME_WON_TEXT
    
    var bombsInTotal: Int? = nil
    var bombsLeft: Int = 0
    {
        didSet {  // everytime the value changes, didset will be triggered
            self.bombsLeftLabel.text = "\(bomb) \(bombsLeft)"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateOrientationUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientationUI), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initializeBoard()
        self.startNewGame()
    }
    
    // resets board with new mine locations and resets all buttons to their default state, also defines how many mines are on the board in total
    func resetBoard() {
        if bombsInTotal == nil {  // not a custom game
            self.board.resetBoard(difficulty: self.difficulty)
        } else {  // a custom game
            self.board.resetBoardMinesDefined(amountOfMines: bombsInTotal!)
        }
        
        // iterates through each button and resets it to default settings
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = unopenedColor
            squareButton.setTitle("", for: .normal)
            squareButton.flagPlaced = false
        }
        self.bombsLeft = self.board.squaresWithMines.count
    }
    
    func setTheme() {
        if theme == C.THEME_ONE {  // classical
            unopenedColor = C.THEME_ONE_UNOPENED_COLOR
            openedColor = C.THEME_ONE_OPENED_COLOR
            boomedMineColor = C.THEME_ONE_BOOMED_MINE_COLOR
            titleColor = C.THEME_ONE_TITLE_COLOR
                 
            bomb = C.THEME_ONE_BOMB
            flag = C.THEME_ONE_FLAG
             
            gameOnText = C.THEME_ONE_GAME_ON_TEXT
            gameLostText = C.THEME_ONE_GAME_LOST_TEXT
            gameWonText = C.THEME_ONE_GAME_WON_TEXT
            
        } else if theme == C.THEME_TWO {  // food
            unopenedColor = C.THEME_TWO_UNOPENED_COLOR
            openedColor = C.THEME_TWO_OPENED_COLOR
            boomedMineColor = C.THEME_TWO_BOOMED_MINE_COLOR
            titleColor = C.THEME_TWO_TITLE_COLOR
                 
            bomb = C.THEME_TWO_BOMB
            flag = C.THEME_TWO_FLAG
             
            gameOnText = C.THEME_TWO_GAME_ON_TEXT
            gameLostText = C.THEME_TWO_GAME_LOST_TEXT
            gameWonText = C.THEME_TWO_GAME_WON_TEXT
        }
        self.gameLabel.setTitle(gameOnText, for: .normal)
        bombFlagSegmentedControl.setTitle(bomb, forSegmentAt: 0)
        bombFlagSegmentedControl.setTitle(flag, forSegmentAt: 1)
    }
    
    // logic for starting a new game
    func startNewGame() {
        self.initializeBoard()  // init board
        self.setTheme()  // sets theme
        self.resetBoard()  // reset the board
        self.gameLabel.setTitle(gameOnText, for: .normal)  // set game label
        
        // setting up timer
        self.timeTaken = 0
        self.oneSecondTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneSecond), userInfo: nil, repeats: true)
        
        self.gameOn = true  // game is on
        
        self.bombsLeft = self.board.squaresWithMines.count  // bombs left count setting
        
        if let rootVC = navigationController?.viewControllers.first as? RootViewController {
            rootVC.difficulty = difficulty  // send current difficulty to root controller
            rootVC.theme = theme
        }
        
    }
    
    // for timer to count seconds
    @objc func oneSecond() {
        self.timeTaken += 1
    }
    
    // start a new game when button is pressed to do so
    @IBAction func newGamePressed(_ sender: Any) {
        self.endCurrentGame()
        print("new game")
        self.startNewGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.board = Board(sizeRow: BOARD_SIZE_ROW, sizeCol: BOARD_SIZE_COL)
        super.init(coder: aDecoder)
    }
    
    // calculates max row, col and game element size based on screen size
    func calculateLimitsForGameBoard() -> CGFloat {
        let minFromRowCol = min(BOARD_SIZE_ROW, BOARD_SIZE_COL)
        let frameWidth = self.boardView.frame.width
        let frameHeight = self.boardView.frame.height
        var squareSize: CGFloat = min(frameHeight, frameWidth) / CGFloat(max(BOARD_SIZE_ROW, BOARD_SIZE_COL))
        
        if squareSize < 38.2 {
            squareSize = 38.2
        }
        
        if bombsInTotal == nil {  // not a custom game
            self.BOARD_SIZE_ROW = Int(frameHeight / squareSize)
            self.BOARD_SIZE_COL = Int(frameWidth / squareSize)
        } else {  // is a custom game
            
            let tempCol = self.BOARD_SIZE_COL
            let tempRow = self.BOARD_SIZE_ROW
            
            if frameWidth < frameHeight {
                self.BOARD_SIZE_COL = min(tempRow, tempCol)
                self.BOARD_SIZE_ROW = max(tempCol, tempRow)
            } else {
                self.BOARD_SIZE_COL = max(tempRow, tempCol)
                self.BOARD_SIZE_ROW = min(tempCol, tempRow)
            }
            
            if frameWidth < CGFloat(self.BOARD_SIZE_COL) * squareSize {
                self.BOARD_SIZE_COL = Int(frameWidth / squareSize)
            }
            if frameHeight < CGFloat(self.BOARD_SIZE_ROW) * squareSize {
                self.BOARD_SIZE_ROW = Int(frameHeight / squareSize)
            }
            
            let maxAmountOfBombs = BOARD_SIZE_COL * BOARD_SIZE_ROW - 1
            if bombsInTotal! > maxAmountOfBombs {
                bombsInTotal = maxAmountOfBombs
            }
        
        }
        
        self.board = Board(sizeRow: BOARD_SIZE_ROW, sizeCol: BOARD_SIZE_COL)

        print("minFromRowCol : \(minFromRowCol)")
        print("frameWidth : \(frameWidth)")
        print("frameHeight : \(frameHeight)")
        print("squareSize : \(self.boardView.frame.width / CGFloat(minFromRowCol))")
        
        return squareSize
    }
    
    // empties the gameboard
    func emptyBoardStack() {
        for stack in boardView.subviews {
            for btn in stack.subviews {
                btn.removeFromSuperview()
            }
            stack.removeFromSuperview()
        }
    }
        
    // makes gameboard, adds buttons and functionality
    func initializeBoard() {
        emptyBoardStack()
        
        self.squareButtons = []
        
        let squareSize = calculateLimitsForGameBoard()
        
        for row in 0..<self.BOARD_SIZE_ROW {
            
            let stackRow = makeNewStack(horizontal: true)
            for col in 0..<self.BOARD_SIZE_COL {
                let square = board.squares[row][col]
                let squareButton = SquareButton(squareModel: square, squareSize: squareSize, squareMargin: 1)
                squareButton.setTitleColor(titleColor, for: .normal)
                squareButton.addTarget(self, action: #selector(squareButtonPressed), for: .touchUpInside)  // Selector(("squareButtonPressed:"))
                stackRow.addArrangedSubview(squareButton)
                boardView.addArrangedSubview(stackRow)
                self.squareButtons.append(squareButton)
            }
        }
        
        setStartedOrientation()
    }
    
    // sets wheteher game was started in portrait or landscape mode
    func setStartedOrientation() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            self.gameStartedInPortrait = false
        case .landscapeRight:
            self.gameStartedInPortrait = false
        case .portrait:
            self.gameStartedInPortrait = true
        case .portraitUpsideDown:
            //orientationText += "portraitUpsideDown"
            break
        default:
            break
        }
    }
    
    // makes new stack for gameboard, if horizontal is true then it will be a horizontal stack, else it will be a vertical one
    func makeNewStack(horizontal: Bool) -> UIStackView {
        let columnStack = UIStackView()  // teeme tyhja stacki
        if horizontal {
            columnStack.axis = .horizontal
        } else {
            columnStack.axis = .vertical
        }
        columnStack.alignment = .fill
        columnStack.distribution = .fillEqually
        columnStack.spacing = 1.0
        return columnStack
    }
    
    // handles game element presses
     @objc func squareButtonPressed(sender: SquareButton) {
        print("Pressed row:\(sender.square.row), col:\(sender.square.col)")
        
        
        if self.gameOn {
            
            if !currentlyPlacingFlags && !sender.flagPlaced {  // if player isnt currently placing flags and current location has no flag
                if (!sender.square.isRevealed) {  // if square isnt opened yet, open it
                    openSquareButton(squareButton: sender)
                }
                if sender.square.isMineLocation {  // if in the location is a mine
                    // player pressed on mine
                    self.endGamePlayerLost(sender: sender)
                }
                if sender.getLabelText() == "" {  // if the place where player clicked was empty, then open neighboring cells
                    print("will have to open neighbors")
                    self.openNeighborsOfEmptyCell(squareButton: sender)
                }
            }  else if currentlyPlacingFlags {  // if player is currently placing flags
                if sender.flagPlaced {
                    // theres already a flag, remove it
                    sender.setTitle("", for: .normal)
                    sender.flagPlaced = false
                    self.bombsLeft += 1  // one possible bomb added
                } else {
                    // theres no flag, so place the flag
                    sender.setTitle(flag, for: .normal)
                    sender.flagPlaced = true
                    self.bombsLeft -= 1  // one possible bomb removed
                }
            }
            if self.hasGameBeenWon() {  // check if player won after move was made
                self.endGamePlayerWon()  // end game as player won
            }
            
        }
        
    }
    
    // logic for opening given button
    func openSquareButton(squareButton: SquareButton) {
        squareButton.square.isRevealed = true
        if squareButton.getLabelText() == "M" {
            squareButton.setTitle(bomb, for: .normal)
        } else {
            squareButton.setTitle("\(squareButton.getLabelText())", for: .normal)
        }
        squareButton.backgroundColor = openedColor
    }
    
    // takes in a square and finds corresponding button for it
    func findSquareButtonBySquare(square: Square) -> SquareButton? {
        for squareButton in squareButtons {
            if squareButton.square.row == square.row && squareButton.square.col == square.col {
                return squareButton
            }
        }
        return nil
    }
    
    // logic for opening neighbor cells
    func openNeighborsOfEmptyCell(squareButton: SquareButton) {
        if squareButton.getLabelText() != "" {  // if theres a number on given cell, open it but don't go to open its neighbors
            openSquareButton(squareButton: squareButton)
        } else {  // given button was empty, find its neighbors and call method openNeighborsOfEmptyCell on them also
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
    
    // logic for checking whether game has been won or not
    func hasGameBeenWon() -> Bool {
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
    
    // logic upon game has been lost
    func endGamePlayerLost(sender: SquareButton) {
        self.endCurrentGame()  // end game
        self.showAllBombs()  // reveal all bombs on the board
        sender.backgroundColor = boomedMineColor
        self.gameLabel.setTitle(gameLostText, for: .normal)
    }
    
    // logic upon game has been won
    func endGamePlayerWon() {
        self.gameLabel.setTitle(gameWonText, for: .normal)
        self.endCurrentGame()
    }
    
    // logic for ending game
    func endCurrentGame() {
        if self.oneSecondTimer != nil {
            self.oneSecondTimer!.invalidate()
            self.oneSecondTimer = nil
        }
        self.gameOn = false
    }
    
    // reveals all bombs on gameboard for the player
    func showAllBombs() {
        for squareButton in squareButtons {
            if !squareButton.square.isRevealed {  // if button hasnt been revealed
                
                if squareButton.square.isMineLocation {  // if at button location is a mine
                    
                    if !squareButton.flagPlaced {  // if theres no flag, reveal bomb
                        squareButton.backgroundColor = openedColor
                        squareButton.setTitle(bomb, for: .normal)
                    }
                    // if there is a flag, it just remains like that as the flag was placed correctly
                    
                } else {  // there is no mine
                    if squareButton.flagPlaced {  // theres a flag which is placed uncorrectly
                        squareButton.backgroundColor = openedColor
                        squareButton.setTitle("❌", for: .normal)
                    }
                }
            }
        }
    }
    
    // sets mode whether player is placing flags or not
    @IBAction func bombFlagSegmentedControlChanges(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.currentlyPlacingFlags = false
        } else {
            self.currentlyPlacingFlags = true
        }
        print("Player currently placing flags \(self.currentlyPlacingFlags)")
        
    }
    
    // see fn kutsutakse välja kui traitidega muutub midagi
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOrientationUI()
    }
    
    // handles phone orientation changes
    @objc func updateOrientationUI() {
        var orientationText = "Orient: "
        if gameOn {
            switch UIDevice.current.orientation {
            case .faceUp:
                orientationText += "faceUp"
            case .faceDown:
                orientationText += "faceDown"
            case .landscapeLeft:
                orientationText += "landscapeLeft"
                //print("turning to LANDSCAPE")
                turnGameBoardToLandscape()
            case .landscapeRight:
                orientationText += "landscapeRight"
                //print("turning to LANDSCAPE")
                turnGameBoardToLandscape()
            case .portrait:
                orientationText += "portrait"
                //print("turning to PORTRAIT")
                turnGameBoardToPortrait()
            case .portraitUpsideDown:
                orientationText += "portraitUpsideDown"
            case .unknown:
                orientationText += "unknown"
            default:
                orientationText += "new"
            }
        } else {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                orientationText += "landscapeLeft"
                print("started in LANDSCAPE")
                gameStartedInPortrait = false
            case .landscapeRight:
                orientationText += "landscapeRight"
                print("started in LANDSCAPE")
                gameStartedInPortrait = false
            case .portrait:
                orientationText += "portrait"
                gameStartedInPortrait = true
            default:
                orientationText += "new"
            }
        }
        // print("updateOrientationUI \(orientationText)")
    }
    
    // logic for handling the gameboard when phone is turned to landscape
    func turnGameBoardToLandscape() {
        if gameStartedInPortrait {  // if game was initialized in portrait mode
            turnGameBoard(horizontal: false)
        } else {  // if game was initialized in landscape mode
            turnGameBoard(horizontal: true)
        }
    }
    
    // logic for handling the gameboard when phone is turned to portrait
    func turnGameBoardToPortrait() {
        if !gameStartedInPortrait {  // if game was initialized in landscape mode
            turnGameBoard(horizontal: false)
        } else {  // if game was initialized in portrait mode
            turnGameBoard(horizontal: true)
        }
    }
    
    func turnGameBoard(horizontal: Bool) {
        var stacksToAdd : [UIStackView] = []
        
        for stack in boardView.subviews {  // go through all old stacks in board
            let newStack = makeNewStack(horizontal: horizontal)  // makes new stack where to put buttons
            for btn in stack.subviews {  // goes through all buttons that are in old stack
                btn.removeFromSuperview()  // removes button from old stack
                newStack.addArrangedSubview(btn)  // adds button to new stack
            }
            stacksToAdd.append(newStack)
            stack.removeFromSuperview()  // removes old stack from the board
        }
        
        for stack in stacksToAdd {
            boardView.addArrangedSubview(stack)  // adds new stack to board
        }
        if horizontal {
            boardView.axis = .vertical
        } else {
            boardView.axis = .horizontal
        }
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
