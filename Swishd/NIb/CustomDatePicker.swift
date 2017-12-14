//
//  CustomDatePicker.swift
//  Swishd
//
//  Created by Yudiz on 11/22/17.
//

import Foundation
import UIKit

let dateLeadtrailInset: CGFloat = ((_screenSize.width - (20 * _widthRatio) - 60) / 2) - (32.5 * _widthRatio)

class CustomDatePicker: ConstrainedView {
    
    //MARK:- IBOutlets
    @IBOutlet var datePickerBottom: NSLayoutConstraint!
    @IBOutlet weak var viewDate: DateView!
    @IBOutlet weak var viewTime: TimeView!
    
    //MARK:- Variables
    public var timeZone = TimeZone.current
    
    internal var minimumDate: Date!
    internal var maximumDate: Date!
    public var selectedDate = Date() {
        didSet {
//            resetDateTitle()
        }
    }
    internal var calendar: Calendar = .current
    internal var dates: [Date]! = []
    internal var components: DateComponents! {
        didSet {
            components.timeZone = timeZone
        }
    }
    
    var selectionBlock:((_ date: Date)->())?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self)
        if let location = loc{
            if location.y < (_screenSize.height - _customDatePickerHideConstant){
                removeViewWithAnimation()
            }
        }
    }
    
    //MARK:- Other
    class func instantiateViewFromNib(selected: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil) -> CustomDatePicker {
        let obj = Bundle.main.loadNibNamed("CustomDatePicker", owner: nil, options: nil)![0] as! CustomDatePicker
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.datePickerBottom.constant = -_customDatePickerHideConstant
        obj.layoutIfNeeded()
        obj.prepareDatePicker(selected: selected, minimumDate: minimumDate, maximumDate: maximumDate)
        obj.datePickerBottom.constant = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
        })
        return obj
    }
    
    func removeViewWithAnimation(){
        datePickerBottom.constant = -_customDatePickerHideConstant
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
        }) { (done) in
            self.removeFromSuperview()
        }
    }
}

// MARK: - UI & Utility methods
extension CustomDatePicker {
    
    func prepareDatePicker(selected: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil)  {
        self.minimumDate = minimumDate ?? Date(timeIntervalSinceNow: -3600 * 24 * 365 * 20)
        self.maximumDate = maximumDate ?? Date(timeIntervalSinceNow: 3600 * 24 * 365 * 20)
        self.selectedDate = selected ?? self.minimumDate
        weak var datepicker = self
        self.viewDate.datePicker = datepicker
        self.viewTime.datePicker = datepicker
        assert(self.minimumDate.compare(self.maximumDate) == .orderedAscending, "Minimum date should be earlier than maximum date")
        assert(self.minimumDate.compare(self.selectedDate) != .orderedDescending, "Selected date should be later or equal to minimum date")
        assert(self.selectedDate.compare(self.maximumDate) != .orderedDescending, "Selected date should be earlier or equal to maximum date")
        fillDates(fromDate: self.minimumDate, toDate: self.maximumDate)
        components = calendar.dateComponents([.day, .month, .year, .hour], from: selectedDate)
        setDateSelection()
        setTimeSelection()
    }
    
    func fillDates(fromDate: Date, toDate: Date) {
        
        var dates: [Date] = []
        var days = DateComponents()
        
        var dayCount = 0
        repeat {
            days.day = dayCount
            dayCount += 1
            guard let date = calendar.date(byAdding: days, to: fromDate) else {
                break;
            }
            if date.compare(toDate) == .orderedDescending {
                break
            }
            dates.append(date)
        } while (true)
        
        self.dates = dates
        self.viewDate.collectionView.reloadData()
    }
    
    func setDateSelection() {
        let selectedDateStr = Date.getLocalString(from: selectedDate)
        for (idx,date) in dates.enumerated() {
            let dateStr = Date.getLocalString(from: date)
            if dateStr == selectedDateStr{
                viewDate.collectionView.selectItem(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                break
            }
        }
    }
    
    func setTimeSelection() {
        if let hour = components.hour{
            viewTime.collectionView.selectItem(at: IndexPath(row: hour, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        }
    }
    
    func selectTime(hour: Int) {
        components.hour = hour
        if let selected = calendar.date(from: components) {
            if selected.compare(minimumDate) == .orderedAscending {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
    func selectDateAt(index: Int) {
        let date = dates[index]
        let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        if let selected = calendar.date(from: components) {
            if selected.compare(minimumDate) == .orderedAscending {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
    func resetTime() {
        components = calendar.dateComponents([.day, .month, .year, .hour], from: selectedDate)
        setTimeSelection()
    }
}

// MARK: - IBActions
extension CustomDatePicker {
    
    @IBAction func cancelTap(sender: UIButton){
        removeViewWithAnimation()
    }
    
    @IBAction func doneTap(sender: UIButton){
        selectionBlock?(selectedDate)
        removeViewWithAnimation()
    }
}
