

import UIKit

class QRCodeCell : ConstrainedTableViewCell{
    @IBOutlet weak var lblQrCode : UILabel!
    @IBOutlet weak var imgQrcode : UIImageView!
    @IBOutlet weak var imgPhotoId : UIImageView!
    @IBOutlet weak var imgAddressId : UIImageView!
}

class QRCodeVC: ParentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnShowImgAction(_ sender : UIButton){
        let vc = storyboard?.instantiateViewController(withIdentifier: "IdImageVC") as! IdImageVC
        vc.img = sender.tag == 0 ? _user.verifiedIdProofUrl : _user.verifyAddressProofUrl
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalPresentationCapturesStatusBarAppearance = true
        _appDelegator.window?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func btnBackAction(_ sender: UIButton){
        for vc in (navigationController?.viewControllers)!{
            if let profileVc = vc as? ProfileVC{
                navigationController?.popToViewController(profileVc, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
}

// MARK: - UI & Utility Related
extension QRCodeVC  {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
    }
}

//MARK:- Tableview Method
extension QRCodeVC{

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 560 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! QRCodeCell
        cell.lblQrCode.text = _user.proofCode
        cell.imgQrcode.kf.setImage(with: _user.codeImageUrl)
        cell.imgPhotoId.kf.setImage(with : _user.verifiedIdProofUrl)
        cell.imgAddressId.kf.setImage(with: _user.verifyAddressProofUrl)
        return cell
    }   
}
