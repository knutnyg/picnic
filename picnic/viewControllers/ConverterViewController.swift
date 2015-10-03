
import Foundation
import UIKit
import iAd

class ConverterViewController: UIViewController, UserModelObserver, UITextFieldDelegate, ADBannerViewDelegate {

    // -- UI Elements -- //
    var topCountryLabel:UILabel!
    var bottomCountryLabel:UILabel!
    var topTextField:UITextField!
    var bottomTextField:UITextField!
    var swapButton:UIButton!
    var pointButton:UIButton!
    var houseButton:UIButton!
    
    var refreshButton:UIButton!
    var settingsButton:UIButton!
    var refreshButtonItem:UIBarButtonItem!
    var settingsButtonItem:UIBarButtonItem!

    var topLabel:UILabel!
    var bottomLabel:UILabel!
    var dataAgeLabel:UILabel!

    // -- App Elements -- //
    var userModel:UserModel!
    var gpsLocationManager:GPSLocationManager!
    var conversionRateManager:ConversionRateManager!

    let userDefaults = NSUserDefaults.standardUserDefaults();
    var storedFileName = "data.dat"
    
    var adBannerView:ADBannerView!
    var adBannerConstraint:[NSLayoutConstraint]!
    
    var interAd:ADInterstitialAd?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserModel()
        userModel.loadOffLineData()
        userModel.loadStateFromUserDefaults()
        
        userModel.addObserver(self)
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        gpsLocationManager = GPSLocationManager(userModel: userModel)
        conversionRateManager = ConversionRateManager(userModel: userModel)
        conversionRateManager.storedFileName = storedFileName
        
        topCountryLabel = UILabel()
        topCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("topAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomTextField = createTextField()
        bottomTextField.addTarget(self, action: Selector("bottomAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        pointButton = createFAButton("\u{f124}")
        pointButton.addTarget(self, action: Selector("pointPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        houseButton = createFAButton("\u{f015}")
        houseButton.addTarget(self, action: Selector("housePressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        dataAgeLabel = createLabel("")
        
        swapButton = createFAButton("\u{f0ec}")
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        swapButton.addTarget(self, action: "swapButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)

        view.addSubview(topCountryLabel)
        view.addSubview(topTextField)
        view.addSubview(swapButton)
        view.addSubview(bottomCountryLabel)
        view.addSubview(bottomTextField)
        view.addSubview(pointButton)
        view.addSubview(houseButton)
        view.addSubview(dataAgeLabel)
        
        let views: [String : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "topIcon":pointButton, "bottomIcon":houseButton, "dataAgeLabel":dataAgeLabel]
        
        self.setConstraints(views)
    }

    func readOfflineDataFromDisk() {
        if let data = readOfflineDateFromDisk(storedFileName){
            userModel.offlineData = data
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        clearTextFields()
        redraw()
        refreshData()
        
        if(!userModel.skipAds) {
            addBanner()
        }
    }
    
    func addBanner(){
        adBannerView = ADBannerView()
        adBannerView.translatesAutoresizingMaskIntoConstraints = false
        adBannerView.delegate = self
        view.addSubview(adBannerView)
        let views:[String:AnyObject] = ["adBanner":adBannerView]
        adBannerConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[adBanner]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(adBannerConstraint)
    }
    
    func removeBanner(){
        adBannerView.removeFromSuperview()
        view.removeConstraints(adBannerConstraint)
        adBannerView.delegate = nil
        adBannerView = nil
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print("Error: \(error)")
        banner.hidden = true
    }
    
    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(netHex: 0x19B5FE)
        
        let font = UIFont(name: "Verdana", size:22)!
        let attributes:[String : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Picnic Currency"
        navigationController!.navigationBar.titleTextAttributes = attributes
        
        let verticalOffset = 1.5 as CGFloat;
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(verticalOffset, forBarMetrics: UIBarMetrics.Default)
        
        refreshButton = createfontAwesomeButton("\u{f021}")
        refreshButton.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.TouchUpInside)
        refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        
        settingsButton = createfontAwesomeButton("\u{f013}")
        settingsButton.addTarget(self, action: "settings:", forControlEvents: UIControlEvents.TouchUpInside)
        settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        
        navigationItem.leftBarButtonItem = refreshButtonItem
        navigationItem.rightBarButtonItem = settingsButtonItem
    }

    
    func setConstraints(views: [String:AnyObject]){
        
        let swapMargin = getSwapButtonMarginBasedOnDevice()
        let keyboardHeight = getKeyboardHeightBasedOnDevice()
        
        let screenSize = Double(view.bounds.height)
        let textFieldHeight = Int(screenSize * 0.10)

        let swapButtonMarginTopAndBottom = Int(screenSize * swapMargin)
        let countryLabelDistanceletmTextField = Int(screenSize * 0.003)
        let distanceFromEdge = Int(screenSize * 0.01)
        
        let textFieldFontSize = CGFloat(screenSize * 0.033)
        let swapButtonFontSize = CGFloat(screenSize * 0.082)
        let iconFontSize = CGFloat(screenSize * 0.045)
        
        self.topTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.swapButton.titleLabel!.font = UIFont(name: "FontAwesome", size: swapButtonFontSize)
        self.bottomTextField.font = UIFont(name: "Verdana", size: textFieldFontSize)
        self.pointButton.titleLabel!.font = UIFont(name: "FontAwesome", size: iconFontSize)
        self.houseButton.titleLabel!.font = UIFont(name: "FontAwesome", size: iconFontSize)
        
        var visualFormat = String(format: "V:[topTextField(%d)]-%d-[swapButton]-%d-[bottomTextField(%d)]-%d-|",
            textFieldHeight,
            swapButtonMarginTopAndBottom,
            swapButtonMarginTopAndBottom,
            textFieldHeight,
            keyboardHeight)
        
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            countryLabelDistanceletmTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: bottomTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: topTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            distanceFromEdge,
            distanceFromEdge)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
    
        view.addConstraint(NSLayoutConstraint(item: bottomCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: bottomTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            countryLabelDistanceletmTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        let size: CGSize = houseButton.titleLabel!.text!.sizeWithAttributes([NSFontAttributeName: houseButton.titleLabel!.font])
        let labelWidth = size.width + CGFloat(2*distanceFromEdge)
        
        visualFormat = String(format: "H:|-%d-[topIcon(\(size.width))]-%d-[topTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(\(size.width))]-%d-[bottomTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: dataAgeLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: dataAgeLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomTextField, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: CGFloat(keyboardHeight / 2)))

        self.view.addConstraints(verticalLayout)
        self.view.addConstraints(topCountrylabelSpaceToTextField)
        self.view.addConstraints(topTextFieldWidthConst)
        self.view.addConstraint(swapButtonHorizontalAlign)
        self.view.addConstraints(bottomCountrylabelbottomConst)
        self.view.addConstraints(bottomTextFieldWidthConst)
    }
    
    
    func getKeyboardHeightBasedOnDevice() -> Int{
        var keyboardHeight = 216
        
        if view.bounds.height > 667 {
            //iPhone 6 PLUS RAAAAAGE
            keyboardHeight = 226
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            keyboardHeight = 350
        }
        
        return keyboardHeight
        
    }
    
    func getSwapButtonMarginBasedOnDevice() -> Double{
        
        //Special case for iPhone 4
        if view.bounds.height < 500 {
            return 0.022
        }
        return 0.045
    }

    func refreshData(){
        if !shouldRefreshContiniueSpinning() {
           refreshButton.rotate360Degrees(2, completionDelegate: self)
        }
        
        if userModel.removeAdProduct == nil {
            userModel.requestProducts()
        }

        updateOfflineData()
        updateUserHomeLocale()
        updateUserCurrentLocale()
    }
    
    func updateOfflineData(){
        userModel.updateingAllCurrenciesCounter += 1
        conversionRateManager.updateAllCurrencies()
    }
    
    func updateUserHomeLocale() {
        userModel.updatingHomeLocaleCounter += 1
        gpsLocationManager.updateUserHomeLocale()
    }
    
    func updateUserCurrentLocale(){
        userModel.updatingCurrentLocaleCounter = 1
        gpsLocationManager.updateUserCurrentLocale()
    }
    
    func swapButtonPressed(sender:UIButton){
        self.view.endEditing(true)
        let tempLocale = userModel.homeLocale
        userModel.homeLocale = userModel.currentLocale
        userModel.currentLocale = tempLocale
        
        let tempOverrideLocal = userModel.overrideGPSLocale
        userModel.overrideGPSLocale = userModel.overrideLogicalLocale
        userModel.overrideLogicalLocale = tempOverrideLocal
        
        topTextField.text = ""
        bottomTextField.text = ""
        
        redraw()
    }
    
    func housePressed(sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pointPressed(sender:UIButton){
        let vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.GPS)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func setBottomCountryText(){
        let countryCode:String = userModel.getActiveHomeLocale().objectForKey(NSLocaleCountryCode) as! String
        let country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        bottomCountryLabel.text = country
        
    }
    
    func setTopCountryText() {        
        let countryCode:String = userModel.getActiveCurrentLocale().objectForKey(NSLocaleCountryCode) as! String
        let country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
        topCountryLabel.text = country
    }
    
    func setBottomCurrencyLabel() {
        bottomTextField.placeholder = userModel.getActiveHomeLocale().objectForKey(NSLocaleCurrencyCode) as? String
    }

    func setTopCurrencyLabel() {
        topTextField.placeholder = userModel.getActiveCurrentLocale().objectForKey(NSLocaleCurrencyCode) as? String
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func normalizeText(input:String) -> NSString{
        return input.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString
    }
    
    func displayFailedToResolveCurrencyError(){
        let alert2 = UIAlertController(title: "Error", message: "Unable to access obtain the convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert2, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        let alert = UIAlertController(title: "Error", message: "Unable to detect your location. Please make sure Picnic is allowed the use of GPS under general settings.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func redraw(){
        setTopCountryText()
        setTopCurrencyLabel()
        topAmountEdited(topTextField)
        setBottomCountryText()
        setBottomCurrencyLabel()
        bottomAmountEdited(bottomTextField)
        checkDataAge()
    }
    
    func homeLocaleHasChanged() {
        redraw()
    }

    func currentLocaleHasChanged() {
        redraw()
    }
    
    func offlineDataHasChanged() {
        redraw()
    }
    
    func topAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(topTextField.text!)
        if normalizedNumber == "" {
            userModel.updateCurrentAmount(nil)
        } else {
            userModel.updateCurrentAmount(normalizedNumber.doubleValue)
        }
   
    }
    
    func bottomAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(bottomTextField.text!)
            if normalizedNumber == "" {
                userModel.updateHomeAmount(nil)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            }
    }
    
    func homeAmountChanged() {
        var text = ""
        if let amount = userModel.homeAmount {
            text = String(format: "%.2f", amount)
        }
        if(!bottomTextField.isFirstResponder()){
            bottomTextField.text = text
        }
    }
    
    func currentAmountChanged() {
        var text = ""
        if let amount = userModel.currentAmount {
            text = String(format: "%.2f", amount)
        }
        if(!topTextField.isFirstResponder()){
            topTextField.text = text
        }
    }
    
    func clearTextFields() {
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    func checkDataAge(){
        if let offlineData = userModel.offlineData {
            if let entry = offlineData["USD"] {
                    self.dataAgeLabel.text = "Last updated: \(entry.timeStamp.relativePrintalbe())"
            }
        }
    }
    
    func createTextField() -> UITextField{
        let textField = UITextField()
        
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "USD"
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.DecimalPad
        textField.returnKeyType = UIReturnKeyType.Done

        return textField
    }
    
    func createSwapButton() -> UIButton{
        let swapButton = UIButton()
        swapButton.translatesAutoresizingMaskIntoConstraints = false
        swapButton.setTitle("\u{f0ec}", forState: .Normal)
        swapButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        swapButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        swapButton.transform = CGAffineTransformMakeRotation(3.14/2)
        swapButton.addTarget(self, action: "swapButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return swapButton
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let val = shouldRefreshContiniueSpinning()
        if val {
            refreshButton.rotate360Degrees(2, completionDelegate: self)
        }
    }
    
    func refresh(sender:UIButton!) {
        refreshData()
    }
    
    func shouldRefreshContiniueSpinning() -> Bool{
//        print("\(userModel.updateingAllCurrenciesCounter) \(userModel.updatingHomeLocaleCounter) \(userModel.updatingCurrentLocaleCounter)")
        
        return userModel.updateingAllCurrenciesCounter > 0 ||
        userModel.updatingCurrentLocaleCounter > 0 ||
        userModel.updatingHomeLocaleCounter > 0
    }
    
    func settings(sender:UIButton!) {
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self

        if !userModel.skipAds {
            interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
            requestInterstitialAdPresentation()
        }

        if adBannerView != nil {
            removeBanner()
        }
        navigationController?.pushViewController(vc, animated: true)

    }
}

