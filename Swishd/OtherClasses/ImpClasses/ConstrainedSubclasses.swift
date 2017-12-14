//  Created by iOS Development Company on 01/03/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit


//MARK: - Constained Classes for All device support
/// Below all calssed reduces text of button and Lavel according to device screen size
class KPFixButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = ((btnsize.height - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsetsMake(verPad, 0, verPad, 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

class KPWidthButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = (((btnsize.height * _widthRatio) - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsetsMake(verPad, 0, verPad, 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

class JPWidthTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _widthRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}

class JPHeightTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heighRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _heighRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}


class JPWidthTextView: UITextView {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heighRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _widthRatio)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}

class JPHeightTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _heighRatio)
        }
    }
}

class KPLogoLabel: UILabel {
    
    @IBInspectable var textBorder : CGFloat = 0{
        didSet{
            textBorder = textBorder * _widthRatio
        }
    }
    
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _widthRatio)
        let range = (self.text! as NSString).range(of: self.text!)
        let attriStr = NSMutableAttributedString(string: self.text!)
        
        attriStr.addAttribute(NSAttributedStringKey.strokeWidth, value: -textBorder, range: range)
        attriStr.addAttribute(NSAttributedStringKey.strokeColor, value: UIColor.white, range: range)
        attriStr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: range)
        attriStr.addAttribute(NSAttributedStringKey.kern, value: letterSpace, range: range)
        attributedText = attriStr
    }
}

class JPWidthButton: UIButton {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
        if let title = titleLabel?.text{
            titleLabel?.addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class RoundButton: JPWidthButton {
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

class JPHeightButton: UIButton {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heighRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _heighRatio)
        }
        if let title = titleLabel?.text{
            titleLabel?.addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class KPWidthAttriLabel: UILabel {
    
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let att = self.attributedText{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedStringKey.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _widthRatio)
                    newAttriString.addAttributes([NSAttributedStringKey.font: newFont], range: range)
                }
            })
            self.attributedText = newAttriString
        }
        if let title = text{
//            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}


class JPWidthLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _widthRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class JPHeightLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heighRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _heighRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class KPWidthAttriButton: JPWidthButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let att = self.currentAttributedTitle{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedStringKey.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _widthRatio)
                    newAttriString.addAttributes([NSAttributedStringKey.font: newFont], range: range)
                }
            })
            self.setAttributedTitle(newAttriString, for: UIControlState.normal)
        }
        
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}

class JPWidthRoundLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _widthRatio)
        self.layer.cornerRadius = (self.bounds.size.height * _widthRatio)/2
        self.layer.masksToBounds = true
        
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class JPHeightRoundLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heighRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _heighRatio)
        self.layer.cornerRadius = (self.bounds.size.height * _heighRatio)/2
        self.layer.masksToBounds = true
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}


/// This View contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedControl: UIControl {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
}


class ConstrainedView: UIView {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
}

class GenericTableViewCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var imgv: UIImageView!
    @IBOutlet var lblSeprator : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

/// This Collection view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
    
    // MARK: Activity
    lazy internal var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivityButtonImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    func showSmallSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        let xPoint: CGFloat!
        if isCenter {
            xPoint = -10
        }else{
            let str = control.title(for: .selected)
            control.contentEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0)
            xPoint = (str!.WidthWithNoConstrainedHeight(font: (control.titleLabel?.font)!)/2) - 5
        }
        
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: xPoint)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -10)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.contentEdgeInsets = UIEdgeInsets.zero
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
        
    }
}

/// This Header view cell contains tableview of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedHeaderTableView: UITableViewHeaderFooterView {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
}



/// This Table view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedTableViewCell: UITableViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heighRatio
                const.constant = v2
            }
        }
    }
    

    // MARK: Activity
    lazy internal var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivityButtonImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    func showSmallSpinnerIn(container: UIView, control: UIControl, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIControl) {
        isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(activityIndicator)
                
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -10)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: container, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: -10)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }

    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.contentEdgeInsets = UIEdgeInsets.zero
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
}
