
import Foundation
import BrightFutures
import UIKit

class ConverterViewController: UIViewController, UserModelObserver, UITextFieldDelegate {

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
    
    var shouldRefreshContiniueSpinning:Bool = false
    var isRefreshing:Bool = false

    var topLabel:UILabel!
    var bottomLabel:UILabel!
    var dataAgeLabel:UILabel!

    // -- App Elements -- //
    var userModel:UserModel!
    var locationManager:LocationManager!
    var conversionRateManager:ConversionRateManager!

    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userModel = UserModel()
        
        userModel.addObserver(self)
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        readOfflineDataFromDisk()
        
        locationManager = LocationManager(userModel: userModel)
        conversionRateManager = ConversionRateManager()
        
        topCountryLabel = UILabel()
        topCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        topTextField = createTextField()
        topTextField.addTarget(self, action: Selector("topAmountEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        bottomCountryLabel = UILabel()
        bottomCountryLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

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
        
        let views: [NSObject : AnyObject] = ["topCountryLabel":topCountryLabel, "bottomCountryLabel":bottomCountryLabel,
            "topTextField":topTextField, "bottomTextField":bottomTextField, "swapButton":swapButton, "topIcon":pointButton, "bottomIcon":houseButton, "dataAgeLabel":dataAgeLabel]
        
        self.setConstraints(views)

        redraw()
    }
    
    func readOfflineDataFromDisk() {
        if let data = readOfflineDateFromDisk("data.dat"){
            userModel.offlineData = data
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        clearTextFields()
        if !isRefreshing {
            refreshData()
        }
    }
    
    func setupNavigationBar(){
        navigationController?.navigationBar.barTintColor = UIColor(netHex: 0x19B5FE)
        
        var font = UIFont(name: "Verdana", size:22)!
        var attributes:[NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationItem.title = "Picnic Currency"
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        var verticalOffset = 1.5 as CGFloat;
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

    
    func setConstraints(views: [NSObject:AnyObject]){
        
        var swapMargin = getSwapButtonMarginBasedOnDevice()
        var keyboardHeight = getKeyboardHeightBasedOnDevice()
        
        var screenSize = Double(view.bounds.height)
        var textFieldHeight = Int(screenSize * 0.10)
        var topTextFieldMarginTop = Int(screenSize * 0.14)
        var swapButtonMarginTopAndBottom = Int(screenSize * swapMargin)
        var countryLabelDistanceFromTextField = Int(screenSize * 0.003)
        var distanceFromEdge = Int(screenSize * 0.01)
        
        var textFieldFontSize = CGFloat(screenSize * 0.033)
        var swapButtonFontSize = CGFloat(screenSize * 0.082)
        var iconFontSize = CGFloat(screenSize * 0.045)
        
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
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "V:[topCountryLabel]-%d-[topTextField]",
            countryLabelDistanceFromTextField)
        
        let topCountrylabelSpaceToTextField = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        view.addConstraint(NSLayoutConstraint(item: pointButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: topTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: houseButton, attribute: NSLayoutAttribute.CenterY, relatedBy: .Equal, toItem: bottomTextField, attribute: .CenterY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: topTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "H:|-%d-[swapButton]-%d-|",
            distanceFromEdge,
            distanceFromEdge)
        
        let swapButtonWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let swapButtonHorizontalAlign = NSLayoutConstraint(item: swapButton, attribute: NSLayoutAttribute.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
    
        view.addConstraint(NSLayoutConstraint(item: bottomCountryLabel, attribute: NSLayoutAttribute.Left, relatedBy: .Equal, toItem: bottomTextField, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        visualFormat = String(format: "V:[bottomCountryLabel]-%d-[bottomTextField]",
            countryLabelDistanceFromTextField)
        
        let bottomCountrylabelbottomConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        let size: CGSize = houseButton.titleLabel!.text!.sizeWithAttributes([NSFontAttributeName: houseButton.titleLabel!.font])
        var labelWidth = size.width + CGFloat(2*distanceFromEdge)
        
        visualFormat = String(format: "H:|-%d-[topIcon(\(size.width))]-%d-[topTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let topTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        visualFormat = String(format: "H:|-%d-[bottomIcon(\(size.width))]-%d-[bottomTextField]-\(labelWidth)-|",
            distanceFromEdge,distanceFromEdge)
        
        let bottomTextFieldWidthConst = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
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
        isRefreshing = true
        shouldRefreshContiniueSpinning = true
        refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)

        getOfflineData()
        
        updateUserHomeLocale()
        updateUserCurrentLocale()
        fetchCurrency()
    }
    
    func updateUserCurrentLocale(){
        locationManager.getUserCurrentLocale(true)
            .onSuccess { locale in
                self.updateUserCurrentLocale(locale)
                self.fetchCurrency()
            }
            .onFailure { error in
                self.displayFailedToCurrentLocation()
            }
            .onComplete { context in
                self.shouldRefreshContiniueSpinning = false
                self.isRefreshing = false
            }
    }
    
    func getOfflineData(){
        ConversionRateManager().getAllCurrencies()
            .onSuccess{dict in
                var offlineEntries = self.parseResult(dict as! Dictionary<String, Dictionary<String, String>>)
                self.userModel.offlineData = offlineEntries
                saveDictionaryToDisk("data.dat", offlineEntries)
            }.onFailure {error in
                println("Error retrieving offline list")
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
    
    func fetchCurrency(completion: (() -> Void)? = nil) {
        conversionRateManager.getConvertionRate(self.userModel)
                .onSuccess { convObj in
                    self.userModel.convertionRate = convObj.value
                    self.userModel.conversionRateTimeStamp = convObj.timestamp
                    
                    if self.isDataOld(convObj.timestamp) {
                        self.dataAgeLabel.text = "Last updated: \(convObj.timestamp.mediumPrintable())"
                    } else {
                        self.dataAgeLabel.text = ""
                    }
                    if let callback = completion {
                        callback()
                    }
                }
                .onFailure { error in
                    println("failed to get conv rate")
                    self.displayFailedToResolveCurrencyError()
                    self.userModel.convertionRate = 1
                    self.dataAgeLabel.text = ""
                    
                    if let callback = completion {
                        callback()
                    }

        }
    }
    
    func isDataOld(timestamp:NSDate) -> Bool{
        
        var limit = NSDate().addDays(-2)
        
        let res = timestamp.compare(limit)
        if res == NSComparisonResult.OrderedDescending {
            return false
        }
        return true
    }
    
    func swapButtonPressed(sender:UIButton){
        self.view.endEditing(true)
        var tempLocale = userModel.homeLocale
        userModel.homeLocale = userModel.currentLocale
        userModel.currentLocale = tempLocale
        
        var tempBool = userModel.shouldOverrideGPS
        userModel.shouldOverrideGPS = userModel.shouldOverrideLogical
        userModel.shouldOverrideLogical = tempBool
        
        var tempOverrideLocal = userModel.overrideGPSLocale
        userModel.overrideGPSLocale = userModel.overrideLogicalLocale
        userModel.overrideLogicalLocale = tempOverrideLocal
        
        if let conv = userModel.convertionRate {
            if conv != 0 {
                userModel.convertionRate = 1/conv
            }

        }
        
        userModel.updateCurrentAmount(nil)
        userModel.updateHomeAmount(nil)
        
        redraw()
    }
    
    func housePressed(sender:UIButton){
        locationManager.stopGatheringGPSLocaiton()
        isRefreshing = false
        var vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.HOME_COUNTRY)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pointPressed(sender:UIButton){
        locationManager.stopGatheringGPSLocaiton()
        isRefreshing = false
        var vc = CountrySelectorViewController(userModel: userModel, selectorType: CountrySelectorType.GPS)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateUserCurrentLocale(locale:NSLocale){
        self.userModel.updateCurrentLocale(locale)
    }
    
    func updateUserHomeLocale() {
        let locale:NSLocale = locationManager.getUserHomeLocale(true)
        self.userModel.updateHomeLocale(locale)
        
    }
    
    func setBottomCountryText(){
        if let locale = self.userModel.homeLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            bottomCountryLabel.text = country
        }
    }
    
    func setTopCountryText() {
        if let locale = userModel.currentLocale {
            let countryCode:String = locale.objectForKey(NSLocaleCountryCode) as! String
            var country: String = userModel.languageLocale.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
            topCountryLabel.text = country
        }
    }
    
    func setBottomCurrencyLabel() {
        if let locale = userModel.homeLocale {
            bottomTextField.placeholder = locale.objectForKey(NSLocaleCurrencyCode) as? String
        }

    }

    func setTopCurrencyLabel() {
        if let loc = userModel.currentLocale {
            topTextField.placeholder = loc.objectForKey(NSLocaleCurrencyCode) as? String
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func normalizeText(input:String) -> NSString{
        return input.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil) as NSString
    }
    
    func displayFailedToResolveCurrencyError(){
        var alert2 = UIAlertController(title: "Error", message: "Unable to access obtain the convertionrate. Please check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert2, animated: true, completion: nil)
    }
    
    func displayFailedToCurrentLocation(){
        var alert = UIAlertController(title: "Error", message: "Unable to detect your location. Please make sure Picnic is allowed the use of GPS under general settings.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func redraw(){
        setTopCountryText()
        setTopCurrencyLabel()
        setBottomCountryText()
        setBottomCurrencyLabel()
    }
    
    func homeLocaleHasChanged() {
        redraw()
    }

    func currentLocaleHasChanged() {
        redraw()
    }
    
    func topAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(topTextField.text)
        if normalizedNumber == "" {
            userModel.updateCurrentAmount(nil)
        } else {
            userModel.updateCurrentAmount(normalizedNumber.doubleValue)
        }
   
    }
    
    func bottomAmountEdited(theTextField:UITextField) -> Void {
        let normalizedNumber:NSString = self.normalizeText(bottomTextField.text)
            if normalizedNumber == "" {
                userModel.updateHomeAmount(nil)
            } else {
                userModel.updateHomeAmount(normalizedNumber.doubleValue)
            }
    }
    
    func clearTextFields() {
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    
    func createTextField() -> UITextField{
        var textField = UITextField()
        
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "USD"
        textField.textAlignment = NSTextAlignment.Center
        textField.keyboardType = UIKeyboardType.DecimalPad
        textField.returnKeyType = UIReturnKeyType.Done

        return textField
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
    
    func homeAmountChanged() {
        var text = ""
        if let amount = userModel.homeAmount {
            text = String(format: "%.2f", amount)
        }
        if(!bottomTextField.isFirstResponder()){
            bottomTextField.text = text
        }
    }
    
    func refresh(sender:UIButton!) {
        if !isRefreshing {
            refreshData()
        }
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldRefreshContiniueSpinning {
            refreshButton.rotate360Degrees(duration: 2, completionDelegate: self)
        }
    }
    
    func settings(sender:UIButton!) {
        locationManager.stopGatheringGPSLocaiton()
        isRefreshing = false
        let vc = MenuViewController(userModel: userModel)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
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
}

