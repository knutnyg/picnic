//
//  CountrySelectorViewController.swift
//  picnic
//
//  Created by Knut Nygaard on 4/7/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit
import BButton

class CountrySelectorViewController : UIViewController, UITextFieldDelegate {
    
    var topBannerView:TopBannerViewController!
    var instructionLabel:UILabel!
    var useDetectedButton:BButton!
    
    var countryTableView:CountryTableViewController!
    var topFilterField:UITextField!
    var delegate:UIViewController!=nil
    var userModel:UserModel!
    var selectorType:CountrySelectorType!
    var locationManager:LocationManager!
    
    var backButton:UIButton!
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        instructionLabel = createInstructionLabel()
        useDetectedButton = createUseDetectedCountryButton()
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        countryTableView = CountryTableViewController(userModel: userModel, selectorType: selectorType)
        countryTableView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        locationManager = LocationManager(userModel: userModel)
        switch selectorType! {
        case .GPS:
            locationManager.getUserCurrentLocale(false)
                .onSuccess { locale in
                    self.setButtonLocaleAndStyle(locale)
                }
            break
        case .HOME_COUNTRY:
            self.setButtonLocaleAndStyle(locationManager.getUserHomeLocale(false))
            break
        }
        
        self.addChildViewController(countryTableView)
        
        view.addSubview(instructionLabel)
        view.addSubview(useDetectedButton)
        view.addSubview(topFilterField)
        view.addSubview(countryTableView.view)
        
        let views:[NSObject : AnyObject] = ["countryTable":countryTableView.view,
            "superView":self.view, "topFilter":topFilterField, "instruction":instructionLabel, "detected":useDetectedButton]
        
        var visualFormat = String(format: "V:|-74-[instruction]-[detected]-[topFilter]-[countryTable]-0-|")
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let size: CGSize = useDetectedButton.titleLabel!.text!.sizeWithAttributes([NSFontAttributeName: useDetectedButton.titleLabel!.font])
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instruction]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: useDetectedButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width + 40))
        view.addConstraint(NSLayoutConstraint(item: useDetectedButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[countryTable]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(verticalLayout)  
    }
    
    
    func setupNavigationBar(){
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        switch selectorType! {
        case .HOME_COUNTRY:
            navigationItem.title = "Home Country"
        case .GPS:
            navigationItem.title = "Current Country"
    }
        
        var verticalOffset = 3 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        backButton = createfontAwesomeButton("\u{f060}")
        backButton.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    func back(UIEvent) {
        navigationController?.popViewControllerAnimated(true)
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
    
    func createTopBannerViewController()->TopBannerViewController {
        switch selectorType! {

        case .HOME_COUNTRY:
            var vc = TopBannerViewController(userModel: userModel, activeViewController: self)
                .withBackButton()
                .withNameLabel("Home Country")
            vc.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            return vc
        case .GPS:
            var vc = TopBannerViewController(userModel: userModel, activeViewController: self)
                .withBackButton()
                .withNameLabel("Current Country")
            vc.view.setTranslatesAutoresizingMaskIntoConstraints(false)
            return vc
        }
    }
    
    func createInstructionLabel() -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 4
        
        switch selectorType! {
        case .HOME_COUNTRY:
            label.text = "Please set your prefered home country or use the one detected"
            break
        case .GPS:
            label.text = "Please set your prefered current country or use the one detected"
        }
        return label

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func topFilterTextEdited(theTextField:UITextField) -> Void {
        if(theTextField.text.isEmpty){
            countryTableView.setCountryArray(countryTableView.createCountryNameList())
        } else {
            countryTableView.setCountryArray(countryTableView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(theTextField.text.lowercaseString)} )
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func backButtonPressed(notification: NSNotification) {
        if notification.object is CountrySelectorViewController {
            if notification.object as! CountrySelectorViewController == self {
                delegate.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Filter"
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.Default
        textField.returnKeyType = UIReturnKeyType.Done
        
        return textField
    }
    func setButtonLocaleAndStyle(locale:NSLocale){
        setButtonTitleBasedOnLocale(useDetectedButton, locale: locale)
        useDetectedButton.setType(BButtonType.Success)
        switch selectorType! {
        case .GPS:
            useDetectedButton.addTarget(self, action: "gpsButtonSetAutomaticallyPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            break
        case .HOME_COUNTRY:
            useDetectedButton.addTarget(self, action: "logicalButtonSetAutomaticallyPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            break
        }
    }
    
    func createUseDetectedCountryButton() -> BButton{
        var button = BButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setType(BButtonType.Danger)
        button.setTitle("no country detected", forState: .Normal)
    
        return button
    }
    
    func gpsButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideGPS = false
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func logicalButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideLogical = false
        
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.GPS)
        vc.delegate = self
        vc.transitioningDelegate = userModel.tm
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func setButtonTitleBasedOnLocale(button:BButton, locale:NSLocale) {
        if let countryName = LocaleUtils.createCountryNameFromLocale(locale) {
            button.setTitle("Use \(countryName)", forState: .Normal)
        }
    }
    
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel, selectorType:CountrySelectorType) {
        super.init(nibName: nil, bundle: nil)
        self.userModel = userModel
        self.selectorType = selectorType
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}