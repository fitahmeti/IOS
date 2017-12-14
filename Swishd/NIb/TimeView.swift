//
//  TimeView.swift
//  Swishd
//
//  Created by Yudiz on 11/22/17.
//

import Foundation
import UIKit

class TimeView: ConstrainedView {
    
    /// IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var viewCenterSelection: UIView!
    
    /// Variables
    weak var datePicker: CustomDatePicker!
    
    /// View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI()
        layoutIfNeeded()
    }
}

// MARK: - UI & Utility related
extension TimeView {
    
    func prepareUI() {
        collectionView.allowsSelection = true
        collectionView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    func getCenterSelectedIndex() -> Int? {
        let cells = collectionView.visibleCells
        for cell in cells{
            let rect = collectionView.convert(cell.frame, to: collectionView.superview!)
            if rect.intersects(viewCenterSelection.frame){
                let index = collectionView.indexPath(for: cell)!
                return index.row
            }
        }
        return nil
    }
    
    func setSelectedTimeWhenUserScroll() {
        if let idx = getCenterSelectedIndex(){
            kprint(items: idx)
            datePicker.selectTime(hour: idx)
        }
    }
}

// MARK: - Button Actions
extension TimeView {
    
    @IBAction func btnNextTap(_ sender: UIButton) {
        if let idx = getCenterSelectedIndex(){
            let toInx = idx + 1
            if toInx < 24{
                collectionView.selectItem(at: IndexPath(row: toInx, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                kprint(items: toInx)
                datePicker.selectTime(hour: toInx)
            }
        }
    }
    
    @IBAction func btnPreviousTap(_ sender: UIButton) {
        if let idx = getCenterSelectedIndex(){
            let toInx = idx - 1
            if toInx >= 0{
                collectionView.selectItem(at: IndexPath(row: toInx, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                kprint(items: toInx)
                datePicker.selectTime(hour: toInx)
            }
        }
    }
}

// MARK: - Collection view methods
extension TimeView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DatePickerCell
        cell.lblTitle.text = indexPath.row > 12 ? "\(indexPath.row - 12)" : "\(indexPath.row)"
        cell.lblDesc.text = indexPath.row > 11 ? "PM" : "AM"
        if indexPath.row == 0{
            cell.lblTitle.text = "12"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        datePicker.selectTime(hour: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 65 * _widthRatio, height: 65 * _widthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, dateLeadtrailInset, 0, dateLeadtrailInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        kprint(items: decelerate)
        if !decelerate{
            setSelectedTimeWhenUserScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedTimeWhenUserScroll()
    }
}
