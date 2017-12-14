
import UIKit
import Alamofire

protocol EditProfileDelegate {
    func editProfile()
}

class EditTextCell: ConstrainedTableViewCell,UITextFieldDelegate {
    
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var txtF:UITextField!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet var imgTick: UIImageView!
    var dataTask : DataRequest?
    weak var parent:EditProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUserImage(){
        if let img = parent.profileData.selectedImage{
            imgUser.image = img
        }else{
            imgUser.kf.setImage(with: _user.imageUrl)
        }
    }
    
    func prepareEditUI() {
        imgTick.isHidden = true
        txtF.keyboardType = .asciiCapable
        txtF.returnKeyType = .next
        txtF.autocorrectionType = .no
        txtF.autocapitalizationType = .none
        txtF.isSecureTextEntry = false
        txtF.tintColor = UIColor.swdThemeRedColor()
        lblTitle.text = parent.arrField[txtF.tag - 2]
        if txtF.tag == 2{
             txtF.text = parent.profileData.email
        }else if txtF.tag == 3{
            txtF.returnKeyType = .done
            txtF.text = parent.profileData.username
        }
    }
    
    //MARK:- UITextFieldDelegate
    @IBAction func didTxtChaned(_ textField:UITextField) {
        switch textField.tag {
        case 2:
            parent.profileData.email = textField.text!
        case 3:
            isUserNameValid(str: textField.text!)
        case 4:
            parent.profileData.mobile = textField.text!
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
                parent.scrollToIndex(index: txtF.tag + 1)
                let cell = parent.tableViewCell(index: textField.tag + 1) as! EditTextCell
                cell.txtF.becomeFirstResponder()
          
        }else{
            textField.resignFirstResponder()
        }
            return true
        }
}

// MARK: - API Calls
extension EditTextCell {
    
    func isUserNameValid(str: String) {
        var username = str
        username = username.replacingOccurrences(of: " ", with: "_")
        txtF.text = username
        parent.profileData.username = username
        if username.isValidUsername(){
            dataTask?.cancel()
            dataTask = KPWebCall.call.checkForUserName(userName: username, block: { (json, status) in
                if status == 200{
                    self.parent.profileData.isUserNameValid = true
                    self.imgTick.isHidden = false
                }else{
                    self.parent.profileData.isUserNameValid = false
                    self.imgTick.isHidden = true
                }
            })
        }else{
            dataTask?.cancel()
            self.imgTick.isHidden = true
        }
    }
}

class EditTextFLCell: ConstrainedTableViewCell,UITextFieldDelegate {
    
    @IBOutlet var txtF:UITextField!
    @IBOutlet var txtL:UITextField!
    weak var parent:EditProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareFLEditUI() {
        txtF.keyboardType = .asciiCapable
        txtF.returnKeyType = .next
        txtF.autocorrectionType = .yes
        txtF.autocapitalizationType = .words
        txtF.tintColor = UIColor.swdThemeRedColor()
        txtL.tintColor = UIColor.swdThemeRedColor()
        txtL.returnKeyType = .next
    }
    
    //MARK:- UITextFieldDelegate
   
    @IBAction func didTxtChaned(_ textField:UITextField) {
        switch textField.tag {
        case 0:
            parent.profileData.firstName = textField.text!
        case 1:
            parent.profileData.lastName = textField.text!
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next{
            parent.scrollToIndex(index: textField.tag + 1)
            if textField.tag == 0{
                if let cell = parent.tableViewCell(index: txtF.tag + 1) as? EditTextFLCell{
                    cell.txtL.becomeFirstResponder()
                }
            }else{
                if let cell = parent.tableViewCell(index: textField.tag + 1) as? EditTextCell{
                    cell.txtF.becomeFirstResponder()
                }
            }
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
}

class EditProfileVC: ParentViewController  {

    /// Variables
    var profileData = ProfileData()
    var imagePicker: UIImagePickerController!
    let arrField = ["Email","Username"]
    var delegate: EditProfileDelegate?

    struct ProfileData {
        var firstName : String = _user.fName
        var lastName : String = _user.lName
        var email : String = _user.email
        var username : String = _user.userName
        var mobile : String!
        var selectedImage : UIImage?
        var password : String = "123456"
        var isUserNameValid: Bool = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setKeyboardNotifications()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnSaveTapped(_ sender:UIButton) {
        if !isDataValid().0{
            _ = ValidationToast.showStatusMessage(message: isDataValid().1,yCord: _topMsgBarConstant, inView: self.view)
        }else{
            editProfile()
        }
    }
}

//MARK:-  Button Actions
extension EditProfileVC{
    
    @IBAction func btnAddImageAction(_ sender : UIButton){
        
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
}

//MARK:- UITableviewDelegate
extension EditProfileVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 175 * _widthRatio
        }else if indexPath.row == 4 {
            return 110 * _widthRatio
        }else {
            return 90 * _widthRatio
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editPhotoCell", for: indexPath) as! EditTextCell
            cell.parent = self
            cell.setUserImage()
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFL", for: indexPath) as! EditTextFLCell
            cell.parent = self
            cell.txtF.tag = 0
            cell.txtL.tag = 1
            cell.prepareFLEditUI()
            cell.txtF.text = profileData.firstName
            cell.txtL.text = profileData.lastName
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellBtn", for: indexPath) 
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileCell", for: indexPath) as! EditTextCell
            cell.parent = self
            cell.txtF.tag = indexPath.row
            cell.prepareEditUI()
            return cell
        }
    }
}

// MARK: - Keyboard Functions
extension EditProfileVC {
    func setKeyboardNotifications() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

//MARK:- API Calls

extension EditProfileVC {
    
    func isDataValid() -> (Bool, String) {
        if profileData.username != _user.userName{
            if profileData.username.isEmpty{
                return (false, kValidUserName)
            }else if !profileData.isUserNameValid{
                return (false, kUserNameTaken)
            }else{
                return(true, "")
            }
        }else if !profileData.email.isEmpty && !profileData.email.isValidEmailAddress(){
            return (false, kValidEmail)
        }
        else{
            return(true, "")
        }
    }
    
    func editProfile() {
        var param:[String:Any] = [:]
        param["username"] = profileData.username
        param["first_name"] = profileData.firstName
        param["last_name"] = profileData.lastName
        param["email"] = profileData.email
//        param["password"] = profileData.password
        self.showCentralSpinner()
        KPWebCall.call.setProfileInfo(param: param, img: profileData.selectedImage) { (json, flag) in
            self.hideCentralSpinner()
            if flag == 200 {
                if let dict = json as? NSDictionary{
                    if let  userInfo = dict["userProfile"] as? [NSDictionary]{
                        _user = User.addUpdateEntity(key: "id", value: userInfo[0].getStringValue(key: "_id"))
                        _user.initWithProfile(dict: userInfo[0])
                        _appDelegator.saveContext()
                        self.delegate?.editProfile()
                        _ =  ValidationToast.showStatusMessage(message: "Success",yCord: _topMsgBarConstant, inView: self.view ,withColor: UIColor.swdSuccessPopUp())
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                self.showError(data: json,yPos: _topMsgBarConstant)
            }
        }
    }
}

//MARK:- ImagePicker Delegate
extension EditProfileVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
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
            profileData.selectedImage = pickedImage
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

