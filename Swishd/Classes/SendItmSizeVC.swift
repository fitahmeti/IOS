
import UIKit

class SendItmSizeVC: ParentViewController {

    /// IBOutlets
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    
    /// Variables
    var sizes: [ItemSize] = []
    var callBackPriceBlock: ((Double) -> ())?
    var callBackSwsPointBlock: ((SwishdPoint) -> ())?
    var sendData = SendData()
    var isShowPriceBrackDown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        getItemSize()
        prepareUI()
        configCallBackBlocks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "priceSegue" {
            let dest = segue.destination as! SetPriceVC
            dest.price = self.sendData.price
            dest.selectionBlock = callBackPriceBlock
        }else if segue.identifier == "swishdPointSegue"{
            let dest = segue.destination as! SwishdPointVC
            dest.selectionBlock = callBackSwsPointBlock
        }else if segue.identifier == "confirmItmSegue" {
            let dest = segue.destination as! ConfirmSwishVC
            dest.sendItem = self.sendData
        }
    }
}

// MARK: - UI & Utility Related
extension SendItmSizeVC {
    
    func prepareUI() {
        self.myColView.reloadData()
        prepareProgressFor(step: 0)
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
    }
    
    func configCallBackBlocks() {
        callBackPriceBlock = {[weak self] (price) -> () in
            self?.sendData.price = price
            self?.myColView.reloadData()
        }
        
        callBackSwsPointBlock = {[weak self] (swsPoint) -> () in
            let idxs = self?.myColView.indexPathsForVisibleItems
            if idxs?.first!.row == 1 {
//                self?.sendData.picAddress = nil
//                self?.sendData.picSwsPoint = swsPoint
            }else{
//                self?.sendData.dropAddress = nil
//                self?.sendData.dropSwsPoint = swsPoint
            }
            self?.myColView.reloadData()
        }
    }
    
    func prepareProgressFor(step: Int) {
        btnBack.isHidden = step == 0
        btnBack.tag = step
        btnContinue.tag = step
//        progressView.progress = (step + 1) / 4
    }
    
    func itemSentSuccessfully() {
        sendData = SendData()
        prepareProgressFor(step: 0)
        isShowPriceBrackDown = false
        myColView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
        myColView.reloadData()
    }
}

// MARK: - Button Actions
extension SendItmSizeVC {

    @IBAction func lookUpAddressTap(_ sender: UIButton) {
        let mapVc = UIStoryboard.init(name: "KPLocation", bundle: nil).instantiateInitialViewController() as! KPMapVC
        mapVc.callBackBlock = {[weak self] address in
            kprint(items: address)
            let idxs = self?.myColView.indexPathsForVisibleItems
            if idxs?.first!.row == 0 {
                self?.sendData.picLookAdd = nil
                self?.sendData.picAddress = address
            }else{
                self?.sendData.dropLookAdd = nil
                self?.sendData.dropAddress = address
            }
            self?.myColView.reloadData()
        }
        self.present(mapVc, animated: true, completion: nil)
    }
    
    @IBAction func userCurrentAddressTap(_ sender: UIButton) {
        guard let idx = IndexPath.indexPathForCellContainingView(view: sender, inCollectionView: myColView) else {
            return
        }
        self.showCentralSpinner()
        weak var controller: UIViewController! = self
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
            if let _ = location{
                if isGooleKeyFound{
                    KPAPICalls.shared.getAddressFromLatLong(lat: "\(location!.coordinate.latitude)", long: "\(location!.coordinate.longitude)", block: { (addres) in
                        self.hideCentralSpinner()
                        if let _ = addres{
                            if idx.row == 0{
                                self.sendData.picLookAdd = addres
                                self.sendData.picAddress = nil
                            }else{
                                self.sendData.dropLookAdd = addres
                                self.sendData.dropAddress = nil
                            }
                            self.myColView.reloadData()
                        }
                    })
                }else{
                    KPAPICalls.shared.addressFromlocation(location: location!, block: { (addres) in
                        self.hideCentralSpinner()
                        if let _ = addres{
                            if idx.row == 0{
                                self.sendData.picLookAdd = addres
                                self.sendData.picAddress = nil
                            }else{
                                self.sendData.dropLookAdd = addres
                                self.sendData.dropAddress = nil
                            }
                            self.myColView.reloadData()
                        }
                    })
                }
            }else{
                self.hideCentralSpinner()
            }
        }
    }
    
    @IBAction func btnSwishdPointTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "swishdPointSegue", sender: nil)
    }
    
    @IBAction func btnDeliverByTap(_ sender: UIButton) {
        if let idx = IndexPath.indexPathForCellContainingView(view: sender, inCollectionView: myColView) {
            
            let min = Date()
            let currentDate: Date!
            if let _ = sendData.pickDate, idx.row == 0{
                currentDate = sendData.pickDate
            }else{
                currentDate = Date()
            }
            let picker = CustomDatePicker.instantiateViewFromNib(selected: currentDate, minimumDate: min > currentDate ? currentDate : min, maximumDate: nil)
            picker.selectionBlock = { date in
                if idx.row == 0{
                    self.sendData.pickDate = date
                }else{
                    self.sendData.delDate = date
                }
                self.myColView.reloadData()
            }
            
//            let min = Date()
//            let currentDate: Date!
//            if let _ = sendData.pickDate, idx.row == 0{
//                currentDate = sendData.pickDate
//            }else{
//                currentDate = Date()
//            }
//            let picker = DateTimePicker.show(selected: currentDate, minimumDate: min > currentDate ? currentDate : min, maximumDate: nil)
//            picker.layoutIfNeeded()
//            picker.highlightColor = UIColor.swdThemeRedColor()
//            picker.darkColor = UIColor.darkGray
//            picker.doneButtonTitle = "Done"
//            picker.todayButtonTitle = "Today"
//            picker.is12HourFormat = true
//            picker.dateFormat = "hh:mm aa dd/MM/YYYY"
//            picker.includeMonth = true // if true the month shows at top
//            picker.completionHandler = { date in
//                if idx.row == 0{
//                    self.sendData.pickDate = date
//                }else{
//                    self.sendData.delDate = date
//                }
//                self.myColView.reloadData()
//            }
            
            
//            let picker = KPDatePicker.instantiateViewFromNib(withView: self.view)
//            picker.datePicker.minimumDate = Date()
//            
//            if let _ = sendData.pickDate, idx.row == 2{
//                picker.datePicker.minimumDate = sendData.pickDate
//            }
//            
//            if let _ = sendData.pickDate, idx.row == 1{
//                picker.datePicker.setDate(sendData.pickDate!, animated: true)
//            }else if let _ = sendData.delDate{
//                picker.datePicker.setDate(sendData.delDate!, animated: true)
//            }
//            picker.selectionBlock = {[unowned self](date) -> () in
//                if idx.row == 1{
//                    self.sendData.pickDate = date
//                }else{
//                    self.sendData.delDate = date
//                }
//                self.myColView.reloadData()
//            }
        }
    }
    
    @IBAction func toolBarDoneBtnTap(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnPriceBrackDownTap(_ sender: UIButton) {
        isShowPriceBrackDown = !isShowPriceBrackDown
        myColView.reloadData()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        myColView.scrollToItem(at: IndexPath(row: sender.tag - 1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
        self.prepareProgressFor(step: sender.tag - 1)
    }
    
    @IBAction func setOwnPriceTap(_ sender: UIButton) {
        sendData.isOwnPriceSet = !sendData.isOwnPriceSet
        myColView.reloadData()
    }
    
    @IBAction func btnContinueTap(_ sender: UIButton) {
//        if let idx = IndexPath.indexPathForCellContainingView(view: sender, inCollectionView: myColView) {
            kprint(items: "Step \(sender.tag)")
            if sender.tag == 0{
                if sendData.picAddress == nil && sendData.picLookAdd == nil{
                    kprint(items: self.topLayoutGuide.length)
                    _ = ValidationToast.showStatusMessage(message: kSelectPickPoint, yCord: _topMsgBarConstant, inView: self.view)
                }else{
                    self.myColView.scrollToItem(at: IndexPath(row: sender.tag + 1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
                    self.prepareProgressFor(step: sender.tag + 1)
                }
            }else if sender.tag == 1{
                if sendData.dropAddress == nil && sendData.dropLookAdd == nil{
                    _ = ValidationToast.showStatusMessage(message: kSelectDropPoint, yCord: _topMsgBarConstant, inView: self.view)
                }else{
                    self.myColView.scrollToItem(at: IndexPath(row: sender.tag + 1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
                    self.prepareProgressFor(step: sender.tag + 1)
                }
            }else if sender.tag == 2{
                if sendData.title.isEmpty{
                    _ = ValidationToast.showStatusMessage(message: kEnterItemTitle, yCord: _topMsgBarConstant, inView: self.view)
                }else if sendData.itemSize == nil{
                    _ = ValidationToast.showStatusMessage(message: kSelectItemSize, yCord: _topMsgBarConstant, inView: self.view)
                }else{
                    self.myColView.scrollToItem(at: IndexPath(row: sender.tag + 1, section: 0), at: UICollectionViewScrollPosition.right, animated: true)
                    self.prepareProgressFor(step:sender.tag + 1)
                }
            }else{
                if sendData.isOwnPriceSet && sendData.ownCharge < sendData.recommendedCharge{
                    _ = ValidationToast.showStatusMessage(message: kPriceBelowRecPrice, yCord: _topMsgBarConstant, inView: self.view)
                }else{
                    self.performSegue(withIdentifier: "confirmItmSegue", sender: nil)
                }
            }
//        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension SendItmSizeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: SendItmCollectionCell
        if indexPath.row == 0 || indexPath.row == 1{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellMap", for: indexPath) as! SendItmCollectionCell
            cell.parent = self
            if indexPath.row == 0{
                cell.prepareSetpPickAddressUI()
            }else{
                cell.prepareSetpDropAddressUI()
            }
        }else if indexPath.row == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SendItmCollectionCell
            cell.parent = self
            cell.prepareNameAndSize()
        }else{
            if sendData.isOwnPriceSet{
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOwnPrice", for: indexPath) as! SendItmCollectionCell
            }else{
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPrice", for: indexPath) as! SendItmCollectionCell
            }
            cell.parent = self
            cell.prepareSetpFourUI()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.frame.size
    }
}

// MARK: - WebCall Methods
extension SendItmSizeVC {
    
    func getItemSize() {
        
        let sort = NSSortDescriptor(key: "seq", ascending: true)
        self.sizes = ItemSize.fetchDataFromEntity(predicate: nil, sortDescs: [sort])
        self.myColView.reloadData()
        
        if self.sizes.isEmpty{
            self.showCentralSpinner()
        }
        KPWebCall.call.getItemSizeList { (json, status) in
            self.hideCentralSpinner()
            if status == 200 {
                if let arr = (json as? NSDictionary)?["items"] as? [NSDictionary]{
                    var tempSize:[ItemSize] = []
                    for dict in arr{
                        let item = ItemSize.addUpdateEntity(key: "id", value: dict.getStringValue(key: "_id"))
                        item.initWith(dict: dict)
                        tempSize.append(item)
                    }
                    _appDelegator.saveContext()
                    ItemSize.deleteRemovedObject(oldObjs: self.sizes, newObjs: tempSize)
                    self.sizes = tempSize
                    self.myColView.reloadData()
                }
            }else{
//                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
