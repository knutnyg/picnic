
import Foundation

class ConverterConstraintsModel : NSObject{
    let textFieldHeight:Int
    
    let topTextFieldMarginTop:Int
    let swapButtonMarginTopAndBottom:Int
    
    let countryLabelDistanceFromTextField:Int
    let distanceFromEdge: Int
    
    
    init(textFieldHeight:Int, topTextFieldMarginTop:Int, swapButtonMarginTopAndBottom:Int, countryLabelDistanceFromTextField:Int, distanceFromEdge:Int){
        self.textFieldHeight = textFieldHeight
        self.topTextFieldMarginTop = topTextFieldMarginTop
        self.swapButtonMarginTopAndBottom = swapButtonMarginTopAndBottom
        self.countryLabelDistanceFromTextField = countryLabelDistanceFromTextField
        self.distanceFromEdge = distanceFromEdge
    }
}
