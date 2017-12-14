//
//  DateView.swift
//  Swishd
//
//  Created by Yudiz on 11/22/17.
//

import Foundation
import UIKit

class DateView: ConstrainedView {
    
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
extension DateView {
    
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
    
    func setSelectedDateWhenUserScroll() {
        if let idx = getCenterSelectedIndex(){
            kprint(items: Date.getLocalString(from: datePicker.dates[idx], format: "d"))
            datePicker.selectDateAt(index: idx)
        }
    }
}

// MARK: - Button Actions
extension DateView {
    
    @IBAction func btnNextTap(_ sender: UIButton) {
        if let idx = getCenterSelectedIndex(){
            let toInx = idx + 1
            if toInx < datePicker.dates.count{
                collectionView.selectItem(at: IndexPath(row: toInx, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                kprint(items: Date.getLocalString(from: datePicker.dates[toInx], format: "d"))
                datePicker.selectDateAt(index: toInx)
            }
        }
    }
    
    @IBAction func btnPreviousTap(_ sender: UIButton) {
        if let idx = getCenterSelectedIndex(){
            let toInx = idx - 1
            if toInx >= 0{
                collectionView.selectItem(at: IndexPath(row: toInx, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                kprint(items: Date.getLocalString(from: datePicker.dates[toInx], format: "d"))
                datePicker.selectDateAt(index: toInx)
            }
        }
    }
}

// MARK: - Collection view methods
extension DateView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if datePicker != nil {
            return datePicker.dates.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DatePickerCell
        cell.lblTitle.text = Date.getLocalString(from: datePicker.dates[indexPath.row], format: "d")
        cell.lblDesc.text = Date.getLocalString(from: datePicker.dates[indexPath.row], format: "MMM").uppercased()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, dateLeadtrailInset, 0, dateLeadtrailInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 65 * _widthRatio, height: 65 * _widthRatio)
    }
    
    func collectionView(_ collectionVriew: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        datePicker.selectDateAt(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        kprint(items: decelerate)
        if !decelerate{
            setSelectedDateWhenUserScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedDateWhenUserScroll()
    }
}
