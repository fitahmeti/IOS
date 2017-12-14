

import UIKit

class ResentSearchCell : ConstrainedTableViewCell{
    @IBOutlet weak var lblFrom : UILabel!
    @IBOutlet weak var lblTo : UILabel!
    @IBOutlet weak var btnSaved : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SerchVC: ParentViewController {
    
    /// IBOutlets
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    
    /// Variables
    var index: Int!
    var advanceSearchData: Search?
    var isRecent: Bool = false
    var recentSearch: [Search]!
    var delegate: SavedSearchDelegate?
    var isFromEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isFromEdit{
            redirectToMap(tag: index)
        }
        prepareUI()
        getMostUsedSearch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResultSegue"{
            let vc = segue.destination as! SearchResultVC
            if let search = sender as? Search{
                vc.advanceSearch = search
                vc.isFromRecent = isRecent
                vc.delegate = self
            }
        }else if segue.identifier == "advanceSearchSegue"{
            let vc = segue.destination as! AdvanceSearchVC
            vc.advanceData = sender as! Search
        }
    }
}

// MARK: - UI And Utility Related
extension SerchVC{
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        tableView.register(UINib(nibName: "AdvanceSearchCell", bundle: nil), forCellReuseIdentifier: "advanceSearchCell")
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: .valueChanged)
        tableView.addSubview(referesh)
        // Headerview
        let header = UINib(nibName: "HeaderView", bundle: nil)
        tableView.register(header, forHeaderFooterViewReuseIdentifier: "HeaderView")
        prepareEditUI()
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        getMostUsedSearch()
    }
    
    func prepareEditUI(){
        if isFromEdit{
            btnCancel.isHidden = true
            btnBack.setImage(#imageLiteral(resourceName: "ic_back_arrow"), for: .normal)
        }else{
            btnCancel.isHidden = false
            btnBack.setImage(#imageLiteral(resourceName: "ic_nav_scanBtn"), for: .normal)
        }
    }
}

// MARK: - Delegate
extension SerchVC: SavedSearchDelegate{
    
    func updateSaveSearch(searchObj: Search?) {
        if let search = searchObj{
            isFromEdit = true
            advanceSearchData = search
            prepareEditUI()
            tableView.reloadData()
        }else{
            getMostUsedSearch()
        }
    }
}

//MARK: - Button action
extension SerchVC{
    
    @IBAction func btnCancelAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnBackAction(_ sender : UIButton){
        if isFromEdit{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.openScanner()
        }
    }

    @IBAction func btnFromToAction(_ sender : UIButton){
        redirectToMap(tag: sender.tag)
    }
    
    @IBAction func btnSearchAction(_ sender : UIButton){
        if advanceSearchData?.sourceAddress == nil{
            _ = ValidationToast.showStatusMessage(message: kEnterFromAddress,yCord: _topMsgBarConstant, inView:self.view)
        }else if advanceSearchData?.destAddress == nil{
            _ = ValidationToast.showStatusMessage(message: kEnterToAddress,yCord: _topMsgBarConstant, inView:self.view)
        }else{
            performSegue(withIdentifier: "searchResultSegue", sender: advanceSearchData)
        }
    }
    
    @IBAction func btnUpdateSaveStaus(_ sender : UIButton){
        if recentSearch[sender.tag].searchStatus == .unsaved{
            updateSaveStatus(index: sender.tag, status: SearchStatus.saved)
        }else{
            updateSaveStatus(index: sender.tag, status: SearchStatus.unsaved)
        }
    }
    
    @IBAction func btnAdvanceSearchAction(_ sender: UIButton){
        if let data = advanceSearchData{
            performSegue(withIdentifier: "advanceSearchSegue", sender: data)
        }else{
            advanceSearchData = Search()
            performSegue(withIdentifier: "advanceSearchSegue", sender: advanceSearchData)
        }
        
    }
    
    // Redirect to Map
    func redirectToMap(tag : Int){
        let mapVC = UIStoryboard.init(name: "KPLocation", bundle: nil).instantiateInitialViewController() as! KPMapVC
        mapVC.callBackBlock = {[weak self] address in
            if self?.advanceSearchData == nil{
                self?.advanceSearchData = Search()
            }
            if tag == 0{
                self?.advanceSearchData?.sourceAddress = Address(searchObj: address)
            }else{
                self?.advanceSearchData?.destAddress = Address(searchObj: address)
            }
            self?.tableView.reloadData()
            kprint(items: address)
        }
        self.present(mapVC, animated: true, completion: nil)
    }
}

//MARK:- Tableview Method
extension SerchVC{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if recentSearch != nil{
            if recentSearch.isEmpty{
                return 1
            }
            return recentSearch.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 272 * _widthRatio
        }else{
            if !recentSearch.isEmpty{
                if !recentSearch[indexPath.row].isAnytime && recentSearch[indexPath.row].specificDate == nil && recentSearch[indexPath.row].everyDay.isEmpty{
                    return 80 * _widthRatio
                }
            }
            return 130 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 55 * _widthRatio
        }else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
            header.lblText.text = "MOST USED SEARCHES"
            return header
        }else{
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchLocationCell") as! SearchJobCell
            if advanceSearchData != nil{
                cell.tfFrom.text = advanceSearchData?.sourceAddress?.formattedAddress
                cell.tfTo.text = advanceSearchData?.destAddress?.formattedAddress
            }
            return cell
        }else {
            if recentSearch.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: "noDataFoundCell") as! NOItemCell
                return cell
            }else{
                if !recentSearch[indexPath.row].isAnytime && recentSearch[indexPath.row].specificDate == nil && recentSearch[indexPath.row].everyDay.isEmpty{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
                    cell.recentSearchParent = self
                    cell.tag = indexPath.row
                    cell.prepareUI(search: recentSearch[indexPath.row])
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "advanceSearchCell") as! SearchCell
                    cell.recentSearchParent = self
                    cell.tag = indexPath.row
                    cell.prepareUIForAdvanceSaecrh(search: recentSearch[indexPath.row])
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1{
        }else if indexPath.section == 1 && !recentSearch.isEmpty{
            isRecent = true
            performSegue(withIdentifier: "searchResultSegue", sender: recentSearch[indexPath.row])
        }
    }
}

//MARK:- Api Call
extension SerchVC{
    
    func getMostUsedSearch(){
        KPWebCall.call.getMostUsedSerach() { (json, flag) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if flag == 200 {
                self.delegate?.updateSaveSearch(searchObj: nil)
                if let dict = json as? NSDictionary{
                    if let data = dict["data"] as? [NSDictionary]{
                        self.recentSearch = []
                        for search in data{
                            self.recentSearch.append(Search(dict: search))
                        }
                        self.tableView.reloadData()
                    }
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
    
    func updateSaveStatus(index : Int , status : SearchStatus){
        let dict : [String : Any] =
            ["search_id" : recentSearch[index].searchID! , "status" : status.rawValue]
        self.showCentralSpinner()
        KPWebCall.call.updateSaveSerach(param: dict) { (json, flag) in
            if flag == 200 {
                if let _ = json as? NSDictionary{
                    self.delegate?.updateSaveSearch(searchObj: nil)
                    self.getMostUsedSearch()
                    self.tableView.reloadData()
                }else{
                    self.showError(data: json, yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}


