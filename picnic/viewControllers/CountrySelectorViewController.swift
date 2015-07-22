
import Foundation
import UIKit
import BButton

class CountrySelectorViewController : UIViewController, UITextFieldDelegate {
    
    var instructionLabel:UILabel!
    var useDetectedButton:BButton!
    
    var countryTableView:CountryTableViewController!
    var topFilterField:UITextField!
    var delegate:UIViewController!=nil
    var userModel:UserModel!
    var selectorType:CountrySelectorType!
    
    var backButton:UIButton!
    var backButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        topFilterField = createTextField()
        topFilterField.addTarget(self, action: Selector("topFilterTextEdited:"), forControlEvents: UIControlEvents.EditingChanged)
        
        countryTableView = CountryTableViewController(userModel: userModel, selectorType: selectorType)
        countryTableView.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addChildViewController(countryTableView)
        
        view.addSubview(topFilterField)
        view.addSubview(countryTableView.view)
        
        let views:[String : AnyObject] = ["countryTable":countryTableView.view, "topFilter":topFilterField]
        
        let visualFormat = String(format: "V:|-74-[topFilter(40)]-[countryTable]-0-|")
        
        let verticalLayout = NSLayoutConstraint.constraintsWithVisualFormat(
            visualFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[countryTable]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[topFilter]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(verticalLayout)  
    }
    
    
    func setupNavigationBar(){
        
        switch selectorType! {
        case .HOME_COUNTRY:
            navigationItem.title = "Home Country"
        case .GPS:
            navigationItem.title = "Current Location"
    }
        
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
    
    func createInstructionLabel() -> UILabel{
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 4
        
        switch selectorType! {
        case .HOME_COUNTRY:
            label.text = "Please set your preferred home country or use the one detected:"
            break
        case .GPS:
            label.text = "Please set your preferred current country or use the one detected:"
        }
        return label

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func topFilterTextEdited(theTextField:UITextField) -> Void {
        if let text = theTextField.text {
            countryTableView.setCountryArray(countryTableView.createCountryNameList().filter{$0.countryName.lowercaseString.contains(text.lowercaseString)} )
        } else {
            countryTableView.setCountryArray(countryTableView.createCountryNameList())
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func backButtonPressed(notification: NSNotification) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createTextField() -> UITextField{
        let textField = UITextField()
        
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