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
    var userModel:UserModel!
    var delegate:RootViewController!
    var backButton:UIButton!
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupComplete:", name: "setupComplete", object: nil)

        instructionAutomaticLabel = createAutomaticInstructionLabel()
        instructionManualLabel = createManualInstructionLabel()

        gpsButton = createBButton("Automatic setup")
        gpsButton.addTarget(self, action: "autoSetupPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        countrySetup = createBButton("Choose Countries")
        countrySetup.addTarget(self, action: "setupButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        setActiveButtonStyle()
        
        self.view.addSubview(instructionAutomaticLabel)
        self.view.addSubview(instructionManualLabel)
        self.view.addSubview(gpsButton)
        self.view.addSubview(countrySetup)
        
        var views = ["gps":gpsButton, "setup":countrySetup, "instructionsAuto":instructionAutomaticLabel, "instructionsManual":instructionManualLabel]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[instructionsAuto]-[gps(40)]-40-[instructionsManual]-[setup(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsManual]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
    }
    
    func setupNavigationBar(){
        
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        var verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func createfontAwesomeButton(unicode:String) -> UIButton{
        var font = UIFont(name: "FontAwesome", size: 22)!
        let size: CGSize = unicode.sizeWithAttributes([NSFontAttributeName: font])
        
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = font
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)
        
        return button
    }
    
    func back(UIEvent) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func setupButtonPressed(sender:UIButton!){
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func autoSetupPressed(sender:UIButton!){
        userModel.shouldOverrideGPS = false
        userModel.shouldOverrideLogical = false
        navigationController?.popViewControllerAnimated(true)
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