

import UIKit

class UploadIdCell: ConstrainedTableViewCell{
    @IBOutlet weak var imgIdProof : UIImageView!
    @IBOutlet weak var lblAddProof : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var btnAddProof : UIButton!
    
    weak var parent: UploadIdVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(){
        btnAddProof.tag = self.tag
        lblAddProof.isHidden = false
        if self.tag == 0{
            lblTitle.text = "PHOTO ID"
            lblAddProof.text = "ADD PHOTO ID"
            lblDescription.text = "This can be your Passport, Drive Licenece  or National ID"
            if let img = parent.imgPhotoProof{
                imgIdProof.image = img
                lblAddProof.isHidden = true
            }
        }else{
            lblTitle.text = "PROOF OF ADDRESS"
            lblAddProof.text = "ADD ADDRESS DOCUMENTATION"
            lblDescription.text = "This can be your Passport, Drive Licenece  or National ID"
            if let img = parent.imgAddressProof{
                imgIdProof.image = img
                lblAddProof.isHidden = true
            }
        }
    }
}

class UploadIdVC: ParentViewController{
    
    /// Variables
    var imagePicker: UIImagePickerController!
    var imgPhotoProof : UIImage!
    var imgAddressProof : UIImage!
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UI & Utility Related
extension UploadIdVC  {
    
    func prepareUI() {
        self.view.backgroundColor = UIColor.hexStringToUIColor(hexStr: "EFEFEF")
        tableView.contentInset  = UIEdgeInsets(top: 5 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
    }
}

//MARK:- BUTTON ACTION
extension UploadIdVC{
    @IBAction func btnAddProofAction(_ sender : UIButton){
        index = sender.tag
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) in
            self.openCamera()
        }
        
        let library = UIAlertAction(title: "Select from Library" , style: UIAlertActionStyle.default) { (action) in
            self.openLibrary()
        }
        
        let cancel = UIAlertAction(title: "Cancel" , style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSaveAction(_ sender : UIButton){
        if imgPhotoProof != nil && imgAddressProof != nil{
            saveIdProof()
        }else{
            _ = ValidationToast.showStatusMessage(message: "Please add all Proof.",yCord: _topMsgBarConstant, inView: self.view)
        }
    }
}

// MARK: - Tableview Delegate
extension UploadIdVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 2 ? 90 * _widthRatio : 255 * _widthRatio
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "btnCell") as! UploadIdCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoIdCell") as! UploadIdCell
            cell.tag = indexPath.row
            cell.parent = self
            cell.prepareUI()
            return cell
        }
    }
}

//MARK:- Api Call
extension UploadIdVC{
    
    func saveIdProof() {
        self.showCentralSpinner()        
        KPWebCall.call.verifyIdProof( imgAddress: imgAddressProof, imgPhoto: imgPhotoProof) { (results, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                self.getQrCode()
                _ =  ValidationToast.showStatusMessage(message: "Success",yCord: _topMsgBarConstant, inView: self.view ,withColor: UIColor.swdSuccessPopUp())
            }else{
                self.showError(data: results,yPos: _topMsgBarConstant)
            }
        }
    }
    
    func getQrCode(){
        self.showCentralSpinner()
        KPWebCall.call.getQRcode() { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary, let proffArr = dict["userProfile"] as? [NSDictionary], !proffArr.isEmpty{
                    _user.initWithProff(dict: proffArr.first!)
                    _appDelegator.saveContext()
                    self.performSegue(withIdentifier: "qrCodeSegue", sender: nil)
                }else{
                    self.showError(data: json,yPos: _topMsgBarConstant)
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}

//MARK:- ImagePicker Delegate
extension UploadIdVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if index == 0{
                self.imgPhotoProof = pickedImage
            }else{
                self.imgAddressProof = pickedImage
            }
        }
        tableView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Alert Method
    func showAcceccMessage(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let setting = UIAlertAction(title:  "App access your photos.", style: UIAlertActionStyle.default, handler: { (action) in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            if #available(iOS 10.0, *) {
                _application.open(url!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        })
        let cancel = UIAlertAction(title:  "Edit profile Title", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(setting)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

