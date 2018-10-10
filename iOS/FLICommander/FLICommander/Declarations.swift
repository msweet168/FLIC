//
//  Declarations.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 3/25/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    @nonobjc static var themeColor: UIColor {
        return #colorLiteral(red: 0.2274509804, green: 0.3254901961, blue: 0.6078431373, alpha: 1)
    }
}

extension UIView {
    /// Animates the appearence of any UIView with a fade lasting a default of 0.4 seconds. Optionally, an Int can be passed in specifying a custom duration. Typically run after view is added as a subview.
    func fadeIn(duration: Double?) {
        let defaultDuration = 0.4
        self.alpha = 0
        UIView.animate(withDuration: duration ?? defaultDuration) {
            self.alpha = 1
        }
    }
    
    /// Animates the removal of any UIView with a fade lasting a default of 0.4 seconds. Optionally, an Int can be passed in specifying a custom duration. Typically run before view is removed from superview.
    func fadeOut(duration: Double?) {
        let defaultDuration = 0.4
        UIView.animate(withDuration: duration ?? defaultDuration) {
            self.alpha = 0
        }
    }
}

