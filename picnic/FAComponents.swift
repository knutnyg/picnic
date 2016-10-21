//
// Created by Knut Nygaard on 4/20/15.
// Copyright (c) 2015 Knut Nygaard. All rights reserved.
//

import Foundation
import UIKit

func createFALabel(_ unicode:String) -> UILabel{
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = unicode
    label.textAlignment = NSTextAlignment.center
    return label
}

func createfontAwesomeButton(_ unicode:String) -> UIButton{
    let font = UIFont(name: "FontAwesome", size: 22)!
    let size: CGSize = unicode.size(attributes: [NSFontAttributeName: font])

    let button = UIButton(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    button.setTitle(unicode, for: UIControlState())
    button.titleLabel!.font = font
    button.setTitleColor(UIColor.white, for: UIControlState())
    button.setTitleColor(UIColor(netHex: 0x19B5FE), for: .highlighted)

    return button
}

func createFAButton(_ unicode:String) -> UIButton{
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(unicode, for: UIControlState())
    button.setTitleColor(UIColor.black, for: UIControlState())
    button.setTitleColor(UIColor.white, for: .highlighted)
    return button
}
