//
//  CustomSettingsController.swift
//  MineSweeper
//
//  Created by Liis on 28.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class CustomSettingsController: UIViewController {
         
    
    @IBOutlet weak var minesLabel: UILabel!
    @IBOutlet weak var colLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    
    @IBOutlet weak var minesStepper: UIStepper!
    @IBOutlet weak var colStepper: UIStepper!
    @IBOutlet weak var rowStepper: UIStepper!
    
    @IBOutlet weak var themeSegmentControl: UISegmentedControl!
    
    var amountOfCols : Int? = nil
    var amountOfRows : Int? = nil
    var amountOfMines : Int? = nil
    
    var theme: String = C.THEME_ONE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if amountOfRows != nil && amountOfCols != nil {
            colStepper.value = Double(amountOfCols!)
            rowStepper.value = Double(amountOfRows!)
            //colStepper.setValue(amountOfCols, forKey: <#T##String#>)
        }
        minesLabel.text = String(Int(minesStepper.value))
        colLabel.text = String(Int(colStepper.value))
        rowLabel.text = String(Int(rowStepper.value))
        
        if theme == C.THEME_ONE {
            themeSegmentControl.selectedSegmentIndex = 0
        } else if theme == C.THEME_TWO {
            themeSegmentControl.selectedSegmentIndex = 1
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("prepare for segue \(segue.identifier ?? "Segue identifier not set!")")
        
        if let identifier = segue.identifier {
            switch identifier {
                // be careful with name - it has to match exactly with storyboard
            case "Custom game":
                if let viewControllerWeAreSegueingTo = segue.destination as? GameViewController {
                    // dont access outlets, they are not set yet. it will crash

                    viewControllerWeAreSegueingTo.theme = theme
                    viewControllerWeAreSegueingTo.BOARD_SIZE_COL = Int(colStepper.value)
                    viewControllerWeAreSegueingTo.BOARD_SIZE_ROW = Int(rowStepper.value)
                    viewControllerWeAreSegueingTo.bombsInTotal = Int(minesStepper.value)
                }
            default:
                print("No case for this segue \(identifier)")
            }
                    
        }
    }
    
    @IBAction func minesStepper(_ sender: UIStepper) {
        minesLabel.text = String(Int(sender.value))
    }
    
    @IBAction func colStepper(_ sender: UIStepper) {
        colLabel.text = String(Int(sender.value))
    }
    
    @IBAction func rowStepper(_ sender: UIStepper) {
        rowLabel.text = String(Int(sender.value))
    }
    
    @IBAction func themeChanged(_ sender: Any) {
        if themeSegmentControl.selectedSegmentIndex == 0 {
            theme = C.THEME_ONE
        } else if themeSegmentControl.selectedSegmentIndex == 1 {
            theme = C.THEME_TWO
        }
        if let rootVC = navigationController?.viewControllers.first as? RootViewController {
            rootVC.theme = theme
        }
    }
    
}
