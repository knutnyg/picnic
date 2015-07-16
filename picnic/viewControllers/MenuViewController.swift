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
    var delegate:ConverterViewController!
    var backButton:UIButton!
    var pointButton:BButton!
    var houseButton:BButton!
    
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupComplete:", name: "setupComplete", object: nil)

        instructionAutomaticLabel = createLabel("Let Picnic guess where you are:")
        instructionManualLabel = createLabel("or you decide:")

        gpsButton = createBButton(" Automatic setup")
        gpsButton.addTarget(self, action: "autoSetupPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        pointButton = createBButton(" Set location")
        pointButton.addAwesomeIcon(FAIcon.FALocationArrow, beforeTitle: true)
        pointButton.addTarget(self, action: Selector("pointPressed:"), forControlEvents: UIControlEvents.TouchUpInside)

        houseButton = createBButton(" Set home")
        houseButton.addAwesomeIcon(FAIcon.FAHome, beforeTitle: true)
        houseButton.addTarget(self, action: Selector("housePressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        setActiveButtonStyle()
        
        self.view.addSubview(instructionAutomaticLabel)
        self.view.addSubview(instructionManualLabel)
        self.view.addSubview(gpsButton)
        self.view.addSubview(pointButton)
        self.view.addSubview(houseButton)
        
        let views = ["gps":gpsButton, "instructionsAuto":instructionAutomaticLabel, "instructionsManual":instructionManualLabel, "pointButton":pointButton, "houseButton":houseButton]
        
        let screenHeight = view.bounds.height
        let marginTop = Int((screenHeight - 24 - 120) / 2) - 66
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(marginTop)-[instructionsAuto]-[gps(40)]-40-[instructionsManual]-[pointButton(40)]-18-[houseButton(40)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        view.addConstraint(NSLayoutConstraint(item: houseButton.titleLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 115))
        view.addConstraint(NSLayoutConstraint(item: pointButton.titleLabel!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 115))
        view.addConstraint(NSLayoutConstraint(item: instructionManualLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 145))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 145))
    }
    
    func createReloadButton() -> UIButton{
        let button = UIButton(type: UIButtonType.System)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reload", forState: .Normal)
        button.titleLabel!.font = UIFont(name:"Helvetica", size:30)
        return button
    }
    
    func parseResult(dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]{
        var resultDict:[String:OfflineEntry] = [:]
    
        for key in dict.keys {
            let value = (dict[key]!["value"]! as NSString).doubleValue
            let from = dict[key]!["unit_from"]!
            let to = dict[key]!["unit_to"]!
            let timestamp = dict[key]!["timestamp"]!
            
            resultDict[key] = OfflineEntry(timeStamp: dateFromUTCString(timestamp), unit_from: from, unit_to: to, value: value)
        }
        return resultDict
    }
    
    func setupNavigationBar() {

        let font = UIFont(name: "Verdana", size: 22)!
        let attributes: [String:AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Menu"
        navigationController!.navigationBar.titleTextAttributes = attributes

        let verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)

        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func back(_: UIEvent) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func setupButtonPressed(sender:UIButton!){
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func autoSetupPressed(sender:UIButton!){
        userModel.overrideGPSLocale = nil
        userModel.overrideLogicalLocale = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
    func pointPressed(sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.GPS)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func housePressed(sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createBButton(title:String) -> BButton{
        let button = BButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, forState: .Normal)
        button.setType(BButtonType.Info)

        return button
    }
    
    func setActiveButtonStyle() {
        
        if userModel.overrideGPSLocale != nil {
            pointButton.setType(BButtonType.Success)
        }
        
        if userModel.overrideLogicalLocale != nil {
            houseButton.setType(BButtonType.Success)
        }
        
        if !userModel.isManualSetupActive() {
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