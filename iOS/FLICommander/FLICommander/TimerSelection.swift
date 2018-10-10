//
//  TimerSelection.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 10/9/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import Foundation
import UIKit

class TimerSelection: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timerButtons: [UIButton]!
    
    public init(width: Int, height: Int) {
        super.init(frame:CGRect(x:0, y:0, width: width, height: height))
        Bundle.main.loadNibNamed("TimerSelection", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        viewSetup()
    }
    
    func viewSetup() {
        titleLabel.textColor = UIColor.themeColor
        mainView.layer.cornerRadius = 15
        mainView.layer.borderColor = UIColor.themeColor.cgColor
        mainView.layer.borderWidth = 2
        
        for button in timerButtons {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.themeColor, for: UIControlState.normal)
            button.layer.cornerRadius = 15
            button.layer.borderColor = UIColor.themeColor.cgColor
            button.layer.borderWidth = 2
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.fadeOut(duration: 0.4)
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
