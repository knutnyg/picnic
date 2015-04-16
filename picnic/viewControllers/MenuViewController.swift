//
//  MenuViewController.swift
//  picnic
//
//  Created by Knut Nygaard on 4/7/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit
import BButton

class MenuViewController : UIViewController {
    
    var gpsButton:BButton!
    var countrySetup:BButton!
    var instructionAutomaticLabel:UILabel!
    var instructionManualLabel:UILabel!
    var topBanner:TopBannerViewController!
    var userModel:UserModel!
    var delegate:TopBannerViewController!=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupComplete:", name: "setupComplete", object: nil)

        topBanner = TopBannerViewController(userModel: userModel, activeViewController:self)
            .withBackButton()
            .withNameLabel("Settings")
        topBanner.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        instructionAutomaticLabel = createAutomaticInstructionLabel()
        instructionManualLabel = createManualInstructionLabel()

        gpsButton = createBButton("Automatic setup")
        gpsButton.addTarget(self, action: "autoSetupPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        countrySetup = createBButton("Choose Countries")
        countrySetup.addTarget(self, action: "setupButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        setActiveButtonStyle()
        
        self.addChildViewController(topBanner)
        self.view.addSubview(topBanner.view)
        self.view.addSubview(instructionAutomaticLabel)
        self.view.addSubview(instructionManualLabel)
        self.view.addSubview(gpsButton)
        self.view.addSubview(countrySetup)
        
        var views = ["topBanner":topBanner.view, "gps":gpsButton, "setup":countrySetup, "instructionsAuto":instructionAutomaticLabel, "instructionsManual":instructionManualLabel]
        
        var topBannerHeight = Int(view.bounds.height * 0.1)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[topBanner(\(topBannerHeight))]-30-[instructionsAuto]-[gps(40)]-40-[instructionsManual]-[setup(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topBanner]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsManual]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
    }
    
    func backButtonPressed(notification: NSNotification) {
        if notification.object is MenuViewController {
            if notification.object as! MenuViewController == self {
                delegate.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func createSwapButton() -> UIButton{
        var swapButton = UIButton()
        swapButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        swapButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        swapButton.addTarget(self, action: "swapButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return swapButton
    }
    
    
    func setupButtonPressed(sender:UIButton!){
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        vc.delegate = self
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func autoSetupPressed(sender:UIButton!){
        userModel.shouldOverrideGPS = false
        userModel.shouldOverrideLogical = false
        self.delegate.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func setupComplete(notification: NSNotification) {
        self.delegate.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func createAutomaticInstructionLabel() -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = "Let Picnic guess where you are:"
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 2
        return label
    }
    
    func createManualInstructionLabel() -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = "or you decide:"
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 2
        return label
    }
    
    func createBButton(title:String) -> BButton{
        var button = BButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle(title, forState: .Normal)
        button.setType(BButtonType.Info)

        return button
    }
    
    func setActiveButtonStyle() {
        if userModel.isManualSetupActive() {
            countrySetup.setType(BButtonType.Success)
            countrySetup.addAwesomeIcon(FAIcon.FACheck, beforeTitle: true)
        } else {
            gpsButton.setType(BButtonType.Success)
            gpsButton.addAwesomeIcon(FAIcon.FACheck, beforeTitle: true)
        }
    }
    
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}