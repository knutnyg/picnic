//
//  TopBannerView.swift
//  currencyolini
//
//  Created by Knut Nygaard on 2/27/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit

class TopBannerViewController : UIViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        settingsButton.setTitle("\u{f021}", forState: .Normal)
        refreshButton.setTitle("\u{f013}", forState: .Normal)
        
    }
   }