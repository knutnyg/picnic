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
    var offlineToggleLabel:UILabel!
    var offlineDataAgeLabel:UILabel!
    var offlineToggle:UISwitch!
    var offlineReloadButton:UIButton!
    var userModel:UserModel!
    var delegate:ConverterViewController!
    var backButton:UIButton!
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupComplete:", name: "setupComplete", object: nil)

        instructionAutomaticLabel = createLabel("Let Picnic guess where you are:")
        instructionManualLabel = createLabel("or you decide:")

        gpsButton = createBButton("Automatic setup")
        gpsButton.addTarget(self, action: "autoSetupPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        countrySetup = createBButton("Choose Countries")
        countrySetup.addTarget(self, action: "setupButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        offlineToggle = UISwitch()
        offlineToggle.setTranslatesAutoresizingMaskIntoConstraints(false)
        offlineToggle.setOn(userModel.offlineMode, animated: false)
        offlineToggle.addTarget(self, action: Selector("offlineChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        offlineToggleLabel = createLabel("Offline mode:")

        var text:String
        if userModel.offlineData == nil {
            text = "No data stored"
        } else {
            var date = userModel.offlineData!["NOK"]!.timeStamp
            text = "Last update: \(date)"
        }
        offlineDataAgeLabel = createLabel(text)
        
        offlineReloadButton = createReloadButton()
        offlineReloadButton.addTarget(self, action: Selector("reloadPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        setActiveButtonStyle()
        
        self.view.addSubview(instructionAutomaticLabel)
        self.view.addSubview(instructionManualLabel)
        self.view.addSubview(gpsButton)
        self.view.addSubview(countrySetup)
        self.view.addSubview(offlineToggle)
        self.view.addSubview(offlineToggleLabel)
        self.view.addSubview(offlineDataAgeLabel)
        self.view.addSubview(offlineReloadButton)
        
        var views = ["gps":gpsButton, "setup":countrySetup, "instructionsAuto":instructionAutomaticLabel, "instructionsManual":instructionManualLabel, "offlineToggle":offlineToggle, "offlineLabel":offlineToggleLabel, "offlineAgeLabel":offlineDataAgeLabel, "reload":offlineReloadButton]
        
        var screenHeight = view.bounds.height
        var marginTop = Int((screenHeight - 24 - 120) / 2) - 66
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(marginTop)-[instructionsAuto]-[gps(40)]-40-[instructionsManual]-[setup(40)]-40-[offlineLabel]-[offlineToggle]-[offlineAgeLabel]-[reload]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsAuto]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instructionsManual]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[offlineLabel]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[offlineAgeLabel]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: gpsButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 180))
        view.addConstraint(NSLayoutConstraint(item: countrySetup, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: offlineToggle, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: offlineToggleLabel.bounds.width))
        view.addConstraint(NSLayoutConstraint(item: offlineReloadButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: offlineToggleLabel.bounds.width))

    }
    
    func createReloadButton() -> UIButton{
        var button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle("Reload", forState: .Normal)
        button.titleLabel!.font = UIFont(name:"Helvetica", size:30)
        return button
    }
    
    func getOfflineData(){
        offlineDataAgeLabel.text = "Updating..."
        var crm = ConversionRateManager()
        crm.getAllCurrencies()
            .onSuccess{dict in
                var offlineEntries = self.parseResult(dict as! Dictionary<String, Dictionary<String, String>>)

                self.userModel.offlineData = offlineEntries
                
                saveDictionaryToDisk("data.dat", offlineEntries)
                
                var updated = offlineEntries["USD"]!.timeStamp
                self.offlineDataAgeLabel.text = "Last updated: \(updated)"
            }.onFailure {error in
                if self.userModel.offlineData != nil {
                    var updated = self.userModel.offlineData!["USD"]!.timeStamp
                    self.offlineDataAgeLabel.text = "Last updated: \(updated)"
                } else {
                    self.offlineDataAgeLabel.text = "No offline data stored"
                }
            }
    }
    
    func parseResult(dict:Dictionary<String, Dictionary<String,String>>) -> [String:OfflineEntry]{
        var resultDict:[String:OfflineEntry] = [:]
    
        for key in dict.keys {
            var value = (dict[key]!["value"]! as NSString).doubleValue
            var from = dict[key]!["unit_from"]!
            var to = dict[key]!["unit_to"]!
            var timestamp = dict[key]!["timestamp"]!
            
            resultDict[key] = OfflineEntry(timeStamp: dateFromUTCString(timestamp), unit_from: from, unit_to: to, value: value)
        }
        return resultDict
    }
    
    func setupNavigationBar() {

        var font = UIFont(name: "Verdana", size: 22)!
        var attributes: [NSObject:AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = attributes

        var verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)

        backButton = FAComponents.createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
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

    func createLabel(text:String) -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = text
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
    
    func offlineChanged(sender:UISwitch) {
        println("toggle switched to: \(sender.on)")
        userModel.offlineMode = sender.on
        
        if(sender.on){
            getOfflineData()
        }
        
    }
    
    func reloadPressed(sender: UIButton) {
        getOfflineData()
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