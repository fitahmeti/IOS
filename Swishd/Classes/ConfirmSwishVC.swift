

import UIKit

class ConfirmSwsCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblSize: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var imgSize: UIImageView!
    
    @IBOutlet var lblTo: UILabel!
    @IBOutlet var lblFrom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ConfirmSwishVC: ParentViewController {
    
    /// Variables
    var sendItem: SendData!
    var isSent: Bool = false
    var job: Job?
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: - UI & Utility
extension ConfirmSwishVC {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
    }
    
    func navigateToProfile() {
        if let tab = self.tabBarController as? KPTabBarVC{
            tab.setSelectedTab(idx: 1)
        }
        let nav = self.tabBarController?.viewControllers?[1] as! UINavigationController
        nav.popToRootViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func addToProfile() {
        for vc in (self.navigationController?.viewControllers)!{
            if let sndItm = vc as? SendItmSizeVC{
                sndItm.itemSentSuccessfully()
                break
            }
        }
        
        for vc in (self.tabBarController?.childViewControllers)!{
            if let nav = vc as? UINavigationController, let profile = nav.viewControllers.first as? ProfileVC{
                if profile.isViewLoaded && self.job != nil{
                    profile.addNewJob(job: self.job!)
                }
                break
            }
        }
    }
    
    func editJob(step: Int) {
        var sendVc: SendItmSizeVC? = nil
        for vc in (self.navigationController?.viewControllers)!{
            if let sndItm = vc as? SendItmSizeVC{
                sendVc = sndItm
                break
            }
        }
        
        if let vc = sendVc{
            vc.myColView.scrollToItem(at: IndexPath(row: step, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
            vc.prepareProgressFor(step: step)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Button Actions
extension ConfirmSwishVC {
    
    @IBAction func btnSwishTap(_ sender: UIButton) {
        sendItemAPi()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func viewItemTap(_ sender: UIButton) {
        navigateToProfile()
    }
    
    @IBAction func btnEditPickAddress(_ sender: UIButton) {
        editJob(step: 0)
    }
    
    @IBAction func btnEditDropAddress(_ sender: UIButton) {
        editJob(step: 1)
    }
    
    @IBAction func btnEditPickTime(_ sender: UIButton) {
        editJob(step: 0)
    }
    
    @IBAction func btnEditPrice(_ sender: UIButton) {
        editJob(step: 3)
    }
    
    @IBAction func btnEditTitleAndSize(_ sender: UIButton) {
        editJob(step: 2)
    }
}

// MARK: - Table View Methods
extension ConfirmSwishVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSent{
            return 1
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSent {
            return 520 * _widthRatio
        }else{
            if indexPath.row == 0{
                return 235 * _widthRatio
            }else if indexPath.row == 1{
                return 115 * _widthRatio
            }else if indexPath.row == 2{
                return 270 * _widthRatio
            }else{
                return 60 * _widthRatio
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConfirmSwsCell
        if isSent{
            cell = tableView.dequeueReusableCell(withIdentifier: "itemSentCell", for: indexPath) as! ConfirmSwsCell
        }else{
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo", for: indexPath) as! ConfirmSwsCell
                cell.lblName.text = sendItem.title
                cell.lblSize.text = sendItem.itemSize?.title
                cell.lblPrice.text = "£\(sendItem.isOwnPriceSet ? sendItem.ownCharge : sendItem.recommendedCharge)"
                cell.imgSize.kf.setImage(with: sendItem.itemSize!.imgUrl, completionHandler: { (img, error, catchType, url) in
                    if let _ = img{
                        cell.imgSize.image = img?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    }
                })
                cell.imgSize.tintColor = UIColor.hexStringToUIColor(hexStr: "A0A0A0")
            }else if indexPath.row == 1{
                cell = tableView.dequeueReusableCell(withIdentifier: "cellTime", for: indexPath) as! ConfirmSwsCell
                if let dt = sendItem.pickDate{
                    cell.lblFrom.text = Date.getLocalString(from: dt, format: "dd. MMM hh:mm a")
                }else{
                    cell.lblFrom.text = "Flexible"
                }
                
                if let dt = sendItem.delDate{
                    cell.lblTo.text = Date.getLocalString(from: dt, format: "dd. MMM hh:mm a")
                }else{
                    cell.lblTo.text = "Flexible"
                }
            }else if indexPath.row == 2{
                cell = tableView.dequeueReusableCell(withIdentifier: "cellAddress", for: indexPath) as! ConfirmSwsCell
                if let _ = sendItem.picAddress{
                    cell.lblFrom.text = sendItem.picAddress?.formatedAddress
                }else{
                    cell.lblFrom.text = sendItem.picLookAdd?.formatedAddress
                }
                
                if let _ = sendItem.dropAddress{
                    cell.lblTo.text = sendItem.dropAddress?.formatedAddress
                }else{
                    cell.lblTo.text = sendItem.dropLookAdd?.formatedAddress
                }
            }else{
                cell = tableView.dequeueReusableCell(withIdentifier: "cellSwish", for: indexPath) as! ConfirmSwsCell
            }
        }
        return cell
    }
}

// MARK: - WebCall methods
extension ConfirmSwishVC {
    
    func sendItemAPi() {
        self.showCentralSpinner()
        KPWebCall.call.sendItem(param: sendItem.getParamDict()) { (json, status) in
            self.hideCentralSpinner()
            if status == 200{
                if let data = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.job = Job(dict: data)
                    self.addToProfile()
                    self.isSent = true
                }
                self.tableView.reloadData()
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
