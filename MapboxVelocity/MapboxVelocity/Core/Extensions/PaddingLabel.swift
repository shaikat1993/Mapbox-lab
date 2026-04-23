//
//  PaddingLabel.swift
//  MapboxVelocity
//
//  Created by Shaikat on 4/23/26.
//

import UIKit

@IBDesignable
class PaddedLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 3
    @IBInspectable var bottomInset: CGFloat = 3
    @IBInspectable var leftInset: CGFloat = 8
    @IBInspectable var rightInset: CGFloat = 8

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset,
                                  left: leftInset,
                                  bottom: bottomInset,
                                  right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
