//
//  TopBannerConstraintsModel.swift
//  currencyolini
//
//  Created by Knut Nygaard on 28/02/15.
//  Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class TopBannerConstraintsModel : NSObject{
    let refreshButtonLeftMargin:Int
    let settingsButtonRightMargin:Int
    let buttonsMarginTop: Int
    let nameLabelMarginTop: Int
    
    init(refreshButtonLeftMargin:Int, settingsButtonRightMargin:Int, buttonsMarginTop:Int, nameLabelMarginTop:Int){
        self.refreshButtonLeftMargin = refreshButtonLeftMargin
        self.settingsButtonRightMargin = settingsButtonRightMargin
        self.buttonsMarginTop = buttonsMarginTop
        self.nameLabelMarginTop = nameLabelMarginTop
    }
}
