//
//  LinkTextView.swift
//  Precisely
//
//  Created by iOS Development Company on 4/18/17.
//  Copyright © 2017 iOS Development Company. All rights reserved.
//

import Foundation
import UIKit

protocol TagSelectionDelegate: class {
    func tapOnTag(_ tagName: String)
}

class LinkTextView: JPWidthTextView, UITextViewDelegate {
    
    var delegte: TagSelectionDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.isScrollEnabled = false
        self.isEditable = false
        self.isSelectable = true
        self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5)
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        self.selectedTextRange = nil
        return []
    }
    
    override var canBecomeFirstResponder: Bool { return false }

    override var canBecomeFocused: Bool { return false }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        delegte?.tapOnTag(URL.absoluteString)
        return true
    }
}
