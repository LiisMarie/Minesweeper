//
//  RootViewController.swift
//  MineSweeper
//
//  Created by Liis on 28.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var levelDifficultySegmentControl: UISegmentedControl!
    @IBOutlet weak var themeSegmentControl: UISegmentedControl!
    @IBOutlet weak var btnApplyChanges: UIButton!
    @IBOutlet weak var btnCustomSettings: UIButton!
    
    
    var difficulty: Int = 10
        
    var theme: String = C.THEME_ONE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if difficulty == 10 {
            levelDifficultySegmentControl.selectedSegmentIndex = 0
        } else if difficulty == 20 {
            levelDifficultySegmentControl.selectedSegmentIndex = 1
        } else if difficulty == 30 {
            levelDifficultySegmentControl.selectedSegmentIndex = 2
        } else {
            levelDifficultySegmentControl.selectedSegmentIndex = -1
        }
        
        if theme == C.THEME_ONE {
            themeSegmentControl.selectedSegmentIndex = 0
        } else {
            themeSegmentControl.selectedSegmentIndex = 1
        }
        
        themeSegmentControl.setTitle(C.THEME_ONE, forSegmentAt: 0)
        themeSegmentControl.setTitle(C.THEME_TWO, forSegmentAt: 1)
        
        btnCustomSettings.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        btnCustomSettings.layer.cornerRadius = 10
        
        btnApplyChanges.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        btnApplyChanges.layer.cornerRadius = 10
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
            case "Back to game":
                if let viewControllerWeAreSegueingTo = segue.destination as? GameViewController {
                    // dont access outlets, they are not set yet. it will crash

                    viewControllerWeAreSegueingTo.difficulty = difficulty
                    viewControllerWeAreSegueingTo.theme = theme
                }
            case "Custom settings":
                if let viewControllerWeAreSegueingTo = segue.destination as? CustomSettingsController {
                    // dont access outlets, they are not set yet. it will crash

                    viewControllerWeAreSegueingTo.theme = theme
                }
            default:
                print("No case for this segue \(identifier)")
            }
                    
        }
    }
    
    @IBAction func levelChanged(_ sender: Any) {
        if levelDifficultySegmentControl.selectedSegmentIndex == 0 {
            difficulty = 10
        } else if levelDifficultySegmentControl.selectedSegmentIndex == 1 {
            difficulty = 20
        } else if levelDifficultySegmentControl.selectedSegmentIndex == 2 {
            difficulty = 30
        }
    }
    
    @IBAction func themeChanged(_ sender: Any) {
        if themeSegmentControl.selectedSegmentIndex == 0 {
            theme = C.THEME_ONE
        } else if themeSegmentControl.selectedSegmentIndex == 1 {
            theme = C.THEME_TWO
        }
    }
    

}
