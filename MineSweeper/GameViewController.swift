//
//  ViewController.swift
//  MineSweeper
//
//  Created by Liis on 16.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var BOARD_SIZE_ROW: Int = 15
    var BOARD_SIZE_COL: Int = 15
    var board: Board
    var squareButtons: [SquareButton] = []
    var gameOn = false
    var currentlyPlacingFlags = false
    var difficulty: Int = 10
    
    var gameStartedInPortrait = true
    
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
    @IBOutlet weak var boardView: UIStackView!
    @IBOutlet weak var gameLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        updateOrientationUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientationUI), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("GAAAME Ooooooooon " + String(gameOn))

        if (!gameOn) {
            self.initializeBoard()
            self.startNewGame()
        }
    
        print("GAAAME STARTEDDDDD " + String(gameOn))
    }
    
    // resets board with new mine locations and resets all buttons to their default state, also defines how many mines are on the board in total
    func resetBoard() {
        self.board.resetBoard(difficulty: self.difficulty)
        // iterates through each button and resets it to default settings
        for squareButton in self.squareButtons {
            squareButton.backgroundColor = unopenedColor
            squareButton.setTitle("", for: .normal)
            squareButton.flagPlaced = false
        }
        self.bombsLeft = self.board.squaresWithMines.count
    }
    
    // logic for starting a new game
    func startNewGame() {
        self.initializeBoard()  // init board
        self.resetBoard()  // reset the board
        self.gameLabel.setTitle(gameOnText, for: .normal)  // set game label
        
        // setting up timer
        self.timeTaken = 0
        self.oneSecondTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneSecond), userInfo: nil, repeats: true)
        
        self.gameOn = true  // game is on
        
        self.bombsLeft = self.board.squaresWithMines.count  // bombs left count setting
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
        var squareSize: CGFloat = min(frameHeight, frameWidth) / CGFloat(minFromRowCol)
        
        if squareSize < 38.2 {
            squareSize = 38.2
        }
        self.BOARD_SIZE_ROW = Int(frameHeight / squareSize)
        self.BOARD_SIZE_COL = Int(frameWidth / squareSize)
        
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
                squareButton.setTitleColor(UIColor.darkGray, for: .normal)
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
        squareButton.setTitle("\(squareButton.getLabelText())", for: .normal)
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
                        squareButton.setTitle("\(squareButton.getLabelText())", for: .normal)
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
    @IBAction func bombFlagSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.currentlyPlacingFlags = false
        } else {
            self.currentlyPlacingFlags = true
        }
        print("Player currently placing flags \(self.currentlyPlacingFlags)")
        
    }
    
    // sets difficulty for the next started game
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
    
    // handles phone orientation changes
    @objc func updateOrientationUI() {
        var orientationText = "Orient: "
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
