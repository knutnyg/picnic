//
//  ParentConstraintsModel.swift
//  currencyolini
//
//  Created by Knut Nygaard on 28/02/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class ParentConstraintsModel : NSObject{
    
    let bannerHeight:Int
    let keyboardHeight: Int
    let converterHeight: Int
    
    init(bannerHeight:Int, keyboardHeight:Int, screenHeight:Int){
        self.bannerHeight = bannerHeight
        self.keyboardHeight = keyboardHeight
        self.converterHeight = screenHeight - bannerHeight - keyboardHeight
    }
}
