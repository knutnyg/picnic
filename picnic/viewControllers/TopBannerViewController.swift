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
        
        self.view.backgroundColor = UIColor(netHex: 0x19B5FE)
        
        let screenWidth = self.view.frame.width
        
        settingButton = createfontAwesomeButton("\u{f013}")
        settingButton.addTarget(self, action: "settingsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        settingButton.hidden = true
        
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refreshPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        nameLabel = createNameLabel()

        self.view.addSubview(settingButton)
        self.view.addSubview(refreshButton)
        self.view.addSubview(nameLabel)
        
        let views: [NSObject : AnyObject] = ["refresh" : refreshButton, "settings":settingButton, "name":nameLabel]
        
        self.setupGUIBasedOnScreenSize(views)
    }
    
    func setupGUIBasedOnScreenSize(views: [NSObject:AnyObject]) {
        let screenHeight = view.frame.height
        
        switch screenHeight {
        case 480: setupForiPhoneFour(views)
        case 568: setupForiPhoneFive(views)
        case 667: setupForiPhoneSix(views)
        case 736: setupForiPhoneSix(views)
        case 1024: setupForIpadTwo(views)

        default: println("default")
        }
    }
    
    func setupForiPhoneFour(views: [NSObject:AnyObject]){
        
        let constraintsModel = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 17,
            nameLabelMarginTop: 17)
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setupForiPhoneFive(views: [NSObject:AnyObject]){
        
        let constraintsModel = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 19,
            nameLabelMarginTop: 19)
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setupForiPhoneSix(views: [NSObject:AnyObject]){
        
        let constraintsModel = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 19,
            nameLabelMarginTop: 19)
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setupForIpadTwo(views: [NSObject:AnyObject]){
        let constraintsModel = TopBannerConstraintsModel(
            refreshButtonLeftMargin: 15,
            settingsButtonRightMargin: 15,
            buttonsMarginTop: 19,
            nameLabelMarginTop: 19)
        
        setConstraintsForiPhone(views, constraintsModel: constraintsModel)
    }
    
    func setConstraintsForiPhone(views: [NSObject:AnyObject], constraintsModel:TopBannerConstraintsModel){
        
        var visualFormat = String(format: "H:|-%d-[refresh]",
            constraintsModel.refreshButtonLeftMargin)
        
        let refreshLeftMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:[settings]-%d-|",
            constraintsModel.settingsButtonRightMargin)
        
        let settingsRightMarginConstraint = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)

        visualFormat = String(format: "V:|-%d-[settings]",
            constraintsModel.buttonsMarginTop)
        
        let settingsButtonTopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:|-%d-[refresh]",
            constraintsModel.buttonsMarginTop)
        
        let refreshButtonTopMargin = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:|-%d-[name]",
            constraintsModel.nameLabelMarginTop)
        
        let lableTop = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let lableCenter = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)

        
        self.view.addConstraints(refreshLeftMarginConstraint)
        self.view.addConstraints(settingsRightMarginConstraint)
        self.view.addConstraints(settingsButtonTopMargin)
        self.view.addConstraints(refreshButtonTopMargin)
        self.view.addConstraint(lableCenter)
        self.view.addConstraints(lableTop)
    }
    
    func createNameLabel() -> UILabel{
        nameLabel = UILabel()
        nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameLabel.text = "Picnic Currency"
        nameLabel.font = UIFont(name: "verdana", size: 25)
        nameLabel.textColor = UIColor.whiteColor()
        return nameLabel
    }
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = UIFont(name: "FontAwesome", size: 22)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)
        return button
    }
    
    func settingsPressed(sender:UIButton!) {
        var alert = UIAlertController(title: "Soon TM", message: "Not implemented yet, however you can override the automatic detection of locale in your settings preferences. Use the standard locale format i.e: no_NO or en_US", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func refreshPressed(sender:UIButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshPressed", object: nil)
    }
    
    

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
