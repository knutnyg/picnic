//
//  SettingsViewController.swift
//  picnic
//
//  Created by Jan Tore Stølsvik on 18/03/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var topBannerView:TopBannerViewController!
    var homeCountryView:UIViewController!
    var currentCountryView:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blueColor()
        
        topBannerView = TopBannerViewController()
        topBannerView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        homeCountryView = CountryTableViewController(test: "from_country")
        homeCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        currentCountryView = CountryTableViewController(test: "to_country")
        currentCountryView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(topBannerView)
        self.addChildViewController(homeCountryView)
        self.addChildViewController(currentCountryView)
        view.addSubview(topBannerView.view)
        view.addSubview(homeCountryView.view)
        view.addSubview(currentCountryView.view)
        
        let views:[NSObject : AnyObject] = ["topBanner":topBannerView.view, "home":homeCountryView.view, "current":currentCountryView.view, "superView":self.view]
        
        let constraintModel = ParentConstraintsModel(
            bannerHeight: 55,
            keyboardHeight: 216,
            screenHeight: Int(view.frame.height)
        )
        
        var visualFormat = String(format: "V:|-0-[topBanner(%d)]-0-[home(%d)]-0-[current(%d)]-0-|",
            constraintModel.bannerHeight,
            constraintModel.converterHeight,
            constraintModel.converterHeight)
        
        var verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[topBanner]-0-|"
        
        var topBannerWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[home]-0-|"
        
        var homeWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = "H:|-0-[current]-0-|"
        
        var currentWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraints(verticalLayout)
        view.addConstraints(topBannerWidthConstraints)
        view.addConstraints(homeWidthConstraints)
        view.addConstraints(currentWidthConstraints)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
