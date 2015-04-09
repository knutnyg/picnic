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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backButtonPressed:", name: "backPressed", object: nil)
        
        topBannerView = createTopBannerViewController()
        instructionLabel = createInstructionLabel()
        useDetectedButton = createUseDetectedCountryButton()
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        countryTableView = CountryTableViewController(locale: userModel.currentLocale, userModel: userModel, selectorType: selectorType)
        countryTableView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(countryTableView)
        
        view.addSubview(topBannerView.view)
        view.addSubview(instructionLabel)
        view.addSubview(useDetectedButton)
        view.addSubview(topFilterField)
        view.addSubview(countryTableView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "countryTable":countryTableView.view,
            "superView":self.view, "topFilter":topFilterField, "instruction":instructionLabel, "detected":useDetectedButton]
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 70,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-[instruction]-[detected]-[topFilter]-[countryTable(%d)]",
            constraintModel.bannerHeight,
            400)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)

        
        
        let size: CGSize = useDetectedButton.titleLabel!.text!.sizeWithAttributes([NSFontAttributeName: useDetectedButton.titleLabel!.font])
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[topBanner]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[instruction]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: useDetectedButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width + 40))
        view.addConstraint(NSLayoutConstraint(item: useDetectedButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[countryTable]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        view.addConstraints(verticalLayout)  
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
        label.numberOfLines = 2
        
        switch selectorType! {
        case .HOME_COUNTRY:
            label.text = "Please set your prefered home country\n or use the one detected"
            break
        case .GPS:
            label.text = "Please set your prefered current country\n or use the one detected"
        }
        return label

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
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
            if notification.object as CountrySelectorViewController == self {
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
    
    func createUseDetectedCountryButton() -> BButton{
        var button = BButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setType(BButtonType.Danger)
        button.setTitle("not detected", forState: .Normal)
    
        switch selectorType! {
        case .GPS:
            if let loc = userModel.currentLocale {
                button.addAwesomeIcon(FAIcon.FALocationArrow, beforeTitle: true)
                button.setType(BButtonType.Success)
                setButtonTitleBasedOnLocale(button, locale: loc)
                button.addTarget(self, action: "gpsButtonSetAutomaticallyPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            break
        case .HOME_COUNTRY:
            if let loc = userModel.homeLocale {
                button.addAwesomeIcon(FAIcon.FAHome, beforeTitle: true)
                button.setType(BButtonType.Success)
                setButtonTitleBasedOnLocale(button, locale: loc)
                button.addTarget(self, action: "logicalButtonSetAutomaticallyPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            break
        }
        return button
    }
    
    func gpsButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideGPS = false
        NSNotificationCenter.defaultCenter().postNotificationName("setupComplete", object: nil)
    }
    
    func logicalButtonSetAutomaticallyPressed(sender:UIButton!){
        userModel.shouldOverrideLogical = false
        
        let vc = CountrySelectorViewController(userModel: self.userModel, selectorType: CountrySelectorType.GPS)
        vc.delegate = self
        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func setButtonTitleBasedOnLocale(button:BButton, locale:NSLocale) {
        if let countryName = LocaleUtils.createCountryNameFromLocale(locale) {
            button.setTitle("Use \(countryName)", forState: .Normal)
        }
    }
    
    /* ----   Initializers   ----  */
    
    init(userModel:UserModel, selectorType:CountrySelectorType) {
        super.init()
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