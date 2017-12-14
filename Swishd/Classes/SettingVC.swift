

import UIKit
import SafariServices
import MessageUI

class SettingCell: ConstrainedTableViewCell{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var viewShadowTop: NSLayoutConstraint!
    @IBOutlet var swPayment: UISwitch!
}

class SettingVC: ParentViewController,SFSafariViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    /// Variables
    var settings = ["About Us","Help","Get In Touch","Notification Setting","Terms & Conditions","Privacy Policy","Refer a Friend"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI & Utility Methods
extension SettingVC{
    
    func prepareUI()  {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 0, left: 0, bottom: 5 * _widthRatio, right: 0)
    }
}

// MARK:-  Button action
extension SettingVC{
    
    @IBAction func logOutTap(_ sender: UIButton) {
        confirmLogout()
    }
    
    @IBAction func swValueChanged(_ sender: UISwitch){
        _appDelegator.isPaymentAllow = !_appDelegator.isPaymentAllow
    }
}

// MARK:- Tableview Method
extension SettingVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 90 * _widthRatio
        }else if indexPath.row == settings.count {
            return 75 * _widthRatio
        }else{
            return 70 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        else if indexPath.row == settings.count{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentSettingCell") as! SettingCell
//            cell.swPayment.isOn = _appDelegator.isPaymentAllow
//            return cell
//        }
        
        if indexPath.row == settings.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCellNew") as! SettingCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCellNew") as! SettingCell
            cell.lblTitle.text = settings[indexPath.row]
            cell.viewShadowTop.constant = -10 * _widthRatio
            if indexPath.row == 0{
                cell.viewShadowTop.constant = 10 * _widthRatio
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openSafari(str: _aboutUsUrl)
        case 1:
            openSafari(str: _helpUrl)
        case 2:
            openMailComposer()
        case 3:
            performSegue(withIdentifier: "notiSettingSegue", sender: nil)
        case 4:
            openSafari(str: _termsUrl)
        case 5:
            openSafari(str: _privacyUrl)
        case 6:
            performSegue(withIdentifier: "referFriendSegue", sender: nil)
        default:
            break
        }
    }
}

// MARK: - Other methods
extension SettingVC{
    
    func openSafari(str: String){
        let controller = SFSafariViewController(url: URL(string: str)!)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    func openMailComposer(){
        let composer = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            composer.mailComposeDelegate = self
            composer.setToRecipients(["tony@gmail.com"])
            composer.setSubject("Test")
            present(composer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Alertview method
extension SettingVC{
    
    func confirmLogout(){
        let alert = UIAlertController(title: nil, message: "Are you Sure you want to logout?", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive) { (action) in
            self.logout()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func logout(){
        self.showCentralSpinner()
        _appDelegator.prepareForLogout { (success, json) in
            self.hideCentralSpinner()
        }
    }
}
