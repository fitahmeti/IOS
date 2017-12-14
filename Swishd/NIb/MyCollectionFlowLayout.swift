//
//  MyCollectionFlowLayout.swift
//  ScaleCollectionDemo
//
//  Created by Yudiz on 11/16/17.
//  Copyright © 2017 yudiz. All rights reserved.
//

import Foundation
import UIKit

class MyCollectionFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + dateLeadtrailInset
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.height)

        let array = super.layoutAttributesForElements(in: targetRect)!
        for layoutAttribute in array{
            let itemOffset = layoutAttribute.frame.origin.x
            if abs(itemOffset - horizontalOffset) < abs(offsetAdjustment){
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
