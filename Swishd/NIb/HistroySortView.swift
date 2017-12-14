//
//  HistroySortView.swift
//  Swishd
//

import Foundation

class HistroySortView: ConstrainedView{

    @IBOutlet var sortViewBottom: NSLayoutConstraint!
    @IBOutlet var vwHeightConstant: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var vwBackground: UIView!

    // View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI()
    }
    
    //MARK:- Variables
    var selectionBlock:((_ selectedIndex: Int)->())?
    var options = [String]()
    var selectedIndex: Int!
    var sortViewHideConstant: CGFloat = 0
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self)
        if let location = loc{
            if location.y < (_screenSize.height - sortViewHideConstant){
                removeViewWithAnimation()
            }
        }
    }
    
    func removeViewWithAnimation(){
        sortViewBottom.constant = sortViewHideConstant
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            self.layoutIfNeeded()
            self.vwBackground.alpha = 0
        }) { (done) in
                self.removeFromSuperview()
        }
    }
    
    func prepareUI(){
        tableView.register(UINib(nibName: "PopupCell", bundle: nil), forCellReuseIdentifier: "popupCell")
        tableView.contentInset = UIEdgeInsets(top: 8 * _widthRatio, left: 0, bottom: 8 * _widthRatio, right: 0)
    }
    
    //MARK:- Other
    class func instantiateViewFromNib(withView view: UIView, options: [String], title: String, selectdIdx: Int?) -> HistroySortView {
        let obj = Bundle.main.loadNibNamed("HistroySortView", owner: nil, options: nil)![0] as! HistroySortView
        _appDelegator.window?.addSubview(obj)
        obj.options = options
        obj.lblTitle.text = title
        if let idx = selectdIdx{
            obj.selectedIndex = idx
        }
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        //Animation
        obj.sortViewHideConstant = -(((CGFloat(options.count)) * 53 * _widthRatio) + 61 * _widthRatio)
        obj.sortViewBottom.constant = obj.sortViewHideConstant
        obj.vwHeightConstant.constant = obj.sortViewHideConstant * -1
        obj.layoutIfNeeded()
        obj.sortViewBottom.constant = 0
        obj.vwBackground.alpha = 0
        UIView.animate(withDuration: _pickerAnimationTime, animations: {
            obj.layoutIfNeeded()
            obj.vwBackground.alpha = 1
        })
        return obj
    }
}

//MARK: - Tableview Method

extension HistroySortView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popupCell") as! PopupCell
        cell.lblTitle.text = options[indexPath.row]
        cell.parent = self
        cell.tag = indexPath.row
        cell.prepareUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionBlock?(indexPath.row)
        removeViewWithAnimation()
    }
}
