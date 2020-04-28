//
//  RootViewController.swift
//  MineSweeper
//
//  Created by Liis on 28.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var levelDifficulty: UISegmentedControl!
    
    private var difficulty: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if levelDifficulty.selectedSegmentIndex == 0 {
            difficulty = 10
        } else if levelDifficulty.selectedSegmentIndex == 1 {
            difficulty = 20
        } else if levelDifficulty.selectedSegmentIndex == 2 {
            difficulty = 30
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
            case "Back to game":
                if let viewControllerWeAreSegueingTo = segue.destination as? GameViewController {
                    // dont access outlets, they are not set yet. it will crash
                    if levelDifficulty.selectedSegmentIndex == 0 {
                        difficulty = 10
                    } else if levelDifficulty.selectedSegmentIndex == 1 {
                        difficulty = 20
                    } else if levelDifficulty.selectedSegmentIndex == 2 {
                        difficulty = 30
                    }
                    viewControllerWeAreSegueingTo.difficulty = difficulty
                }
            default:
                print("No case for this segue \(identifier)")
            }
                    
        }
    }
    

}
