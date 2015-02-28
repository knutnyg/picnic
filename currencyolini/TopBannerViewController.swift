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
    
    var settingButton:UIButton!
    var refreshButton:UIButton!
    var nameLabel:UILabel!
    
    override func viewDidLoad() {
        
        
        self.view.backgroundColor = UIColor.redColor()
        
        let screenWidth = self.view.frame.width
        
        settingButton = createfontAwesomeButton("\u{f013}")
        settingButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        nameLabel = UILabel()
        nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameLabel.text = "Picnic Currency"
        nameLabel.font = UIFont(name: "verdana", size: 25)
        nameLabel.textColor = UIColor.whiteColor()
        
        self.view.addSubview(settingButton)
        self.view.addSubview(refreshButton)
        self.view.addSubview(nameLabel)
        
        let views: [NSObject : AnyObject] = ["refresh" : refreshButton, "settings":settingButton, "name":nameLabel]
        
        let left = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[refresh]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let right = NSLayoutConstraint.constraintsWithVisualFormat("H:[settings]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let top = NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[settings]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        let top2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[refresh]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraints(left)
        self.view.addConstraints(right)
        self.view.addConstraints(top)
        self.view.addConstraints(top2)
        
        let lableCenter = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let lableTop = NSLayoutConstraint.constraintsWithVisualFormat("V:|-35-[name]", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        self.view.addConstraint(lableCenter)
        self.view.addConstraints(lableTop)
        
    }
    
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "FontAwesome", size: 22)
        return button
    }
    

}
