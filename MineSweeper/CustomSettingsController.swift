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
    
    var theme: String = "Regular"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        minesLabel.text = String(Int(minesStepper.value))
        colLabel.text = String(Int(colStepper.value))
        rowLabel.text = String(Int(rowStepper.value))
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
    
    
}
