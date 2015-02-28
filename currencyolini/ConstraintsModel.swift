//
//  ConstraintsModel.swift
//  currencyolini
//
//  Created by Knut Nygaard on 2/28/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class ConstraintsModel : NSObject{
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
