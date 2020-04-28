//
//  UINavigationController.swift
//  MineSweeper
//
//  Created by Liis on 28.04.2020.
//  Copyright © 2020 Liis. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
    
}
