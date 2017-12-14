//  Created by iOS Development Company on 19/04/16.
//  Copyright © 2016 iOS Development Company All rights reserved.
//

import Foundation
import UIKit

class KPTouch: ConstrainedView {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CustomBtnFollow: JPWidthButton {
    var indexPath: NSIndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class RoundView: UIView {
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = (self.frame.height * _widthRatio) / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
    }
}

class RoundShadowView: RoundView{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5 * _widthRatio
        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.size.width * _widthRatio, height: self.frame.size.height * _widthRatio))
        layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
}

class RoundImageView: UIImageView {
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = (self.frame.height * _widthRatio) / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
    }
}

class BlurView: VisualEffectView{
    
    @IBInspectable var radious: CGFloat = 0 {
        didSet{
            blurRadius = radious
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.clear{
        didSet{
            self.colorTint = color
        }
    }
    
    @IBInspectable var colorAlpha: CGFloat = 0{
        didSet{
            self.colorTintAlpha = colorAlpha
        }
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
    }
}

class SimpleDarkBlur: UIView {
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubview(toBack: blurEffectView)
    }
}

class SimpleLightBlur: UIView {
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubview(toBack: blurEffectView)
    }
}

/// This Class will decrease font size as well it will make intrinsiz content size 10 pixel bigger as we need padding on both side of label
class KPointsLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _widthRatio)
        self.layer.cornerRadius = ((self.bounds.size.height + 4) * _widthRatio)/2
        self.layer.masksToBounds = true
    }

    override var intrinsicContentSize: CGSize{
        let asize = super.intrinsicContentSize
        if self.text?.count == 1{
            return CGSize(width: (22 * _widthRatio) , height: asize.height + (4 * _widthRatio))
        }else{
            let width = asize.width + (2 * _widthRatio)
            let height = asize.height + (4 * _widthRatio)
            return CGSize(width: (width < height ? height : width) , height: height)
        }
    }
}

