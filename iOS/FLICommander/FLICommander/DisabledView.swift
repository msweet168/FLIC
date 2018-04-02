//
//  DisabledView.swift
//  FLICommander
//
//  Created by Mitchell Sweet on 3/28/18.
//  Copyright © 2018 Mitchell Sweet. All rights reserved.
//

import UIKit

class DisabledView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    public init(width: Int, height: Int) {
        super.init(frame:CGRect(x:0, y:0, width: width, height: height))
        
        Bundle.main.loadNibNamed("DisabledView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        actionButton.backgroundColor = UIColor.clear
        actionButton.setTitleColor(UIColor.white, for: .normal)
        actionButton.layer.borderColor = UIColor.white.cgColor
        actionButton.layer.borderWidth = 2
        actionButton.layer.cornerRadius = 28
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
