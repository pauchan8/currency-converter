//
//  UIView+Extensions.swift
//  CurrencyConverter
//
//  Created by Pavlo Deinega on 04.08.2022.
//

import UIKit

extension UIView {
    func underlined(color: UIColor = .lightGray) {
        let border = CALayer()
        let width: CGFloat = 1.0
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height - width, width:  frame.size.width, height: frame.size.height)
        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
