//  Created by iOS Development Company on 21/04/16.
//  Copyright © 2016 iOS Development Company All rights reserved.
//

import Foundation
import UIKit

extension IndexPath {
    // Return IndexPath
    static func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> IndexPath? {
        let viewCenterRelativeToTableview = tableView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return tableView.indexPathForRow(at: viewCenterRelativeToTableview)
    }
    
    static func indexPathForCellContainingView(view: UIView, inCollectionView collView:UICollectionView) -> IndexPath? {
        let viewCenterRelativeToCollview = collView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return collView.indexPathForItem(at: viewCenterRelativeToCollview)
    }
}

extension NSAttributedString {
    
    func lineHeightWithConstrainedWidth() -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        return ceil(boundingBox.height)
    }
    
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        return ceil(boundingBox.height)
    }
}

// MARK: - Attributed
extension NSAttributedString {
    
    // This will give combined string with respective attributes
    class func attributedText(texts: [String], attributes: [[NSAttributedStringKey : Any]]) -> NSAttributedString {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        return attbStr
    }
}

extension UILabel {
    
    func animateLabelAlpha( fromValue: NSNumber, toValue: NSNumber, duration: CFTimeInterval) {
        let titleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        titleAnimation.duration = duration
        titleAnimation.fromValue = fromValue
        titleAnimation.toValue = toValue
        titleAnimation.isRemovedOnCompletion = true
        layer.add(titleAnimation, forKey: "opacity")
    }
    
    func setAttributedText(text: String, font: UIFont, color: UIColor) {
        let mutatingAttributedString = NSMutableAttributedString(string: text)
        mutatingAttributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, text.count))
        mutatingAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, text.count))
        attributedText = mutatingAttributedString
    }
    
    // This will give combined string with respective attributes
    func setAttributedText(texts: [String], attributes: [[NSAttributedStringKey : Any]]) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        attributedText = attbStr
    }
    
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

extension UIButton{
    // This will give combined string with respective attributes
    func setAttributedText(texts: [String], attributes: [[NSAttributedStringKey : Any]],state: UIControlState) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        setAttributedTitle(attbStr, for: state)
    }
}

extension UITextField{
    func setAttributedPlaceHolder(text: String, font: UIFont, color: UIColor, spacing: CGFloat) {
        let mutatingAttributedString = NSMutableAttributedString(string: text)
        mutatingAttributedString.addAttribute(NSAttributedStringKey.font, value: font, range: NSMakeRange(0, text.count))
        mutatingAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, text.count))
        attributedPlaceholder = mutatingAttributedString
    }
    
    func addCharactersSpacingInTaxt(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
    
    func addCharactersSpacingInPlaceHolder(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedPlaceholder = attributedString
    }
    
    func addCharactersSpacingWithFont(spacing:CGFloat, text:String, range: NSRange) {
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText!)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: range)
        self.attributedText = attributedString
    }
}

extension UITextView {
    func addCharactersSpacingInTaxt(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

extension UIPanGestureRecognizer {
    
    func shouldScrollVertical() -> Bool {
        let point = self.translation(in: self.view)
        let pointX = abs(point.x)
        let pointY = abs(point.y)
        if pointX < pointY {
            return true
        }else{
            return false
        }
    }
}

//Remove objects
extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            remove(object: object)
        }
    }
}
