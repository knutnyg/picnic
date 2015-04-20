//
// Created by Knut Nygaard on 4/20/15.
// Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation

class FAComponents {

    class func createFALabel(unicode:String) -> UILabel{
        var label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = unicode
        label.textAlignment = NSTextAlignment.Center
        return label
    }

    class func createfontAwesomeButton(unicode:String) -> UIButton{
        var font = UIFont(name: "FontAwesome", size: 22)!
        let size: CGSize = unicode.sizeWithAttributes([NSFontAttributeName: font])

        var button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        button.setTitle(unicode, forState: .Normal)
        button.titleLabel!.font = font
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor(netHex: 0x19B5FE), forState: .Highlighted)

        return button
    }
}
