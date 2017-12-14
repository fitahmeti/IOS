

import UIKit
import MapKit

enum SendItmCellType: String {
    case title = "itemTitleCell"
    case sizeHeader = "selectSizeCell"
    case sizeSelction = "sizeSelectionCell"
}

class SendItmCollectionCell: ConstrainedCollectionViewCell {
    
    /// Step 1
    @IBOutlet var tblView: UITableView!
    @IBOutlet var tfName: UITextField!
    
    /// Step 2
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPickUp: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblDeliverBy: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var viewAddress: UIView!
    @IBOutlet var viewSwsPoint: UIView!
    @IBOutlet var viewAddText: UIView!
    @IBOutlet var viewDateTimeHeight: NSLayoutConstraint!
    @IBOutlet var viewDateTimeBottom: NSLayoutConstraint!
    @IBOutlet var viewProgressConst: NSLayoutConstraint!
    
    // Step 3
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var btnShowBrakdwn: UIButton!
    @IBOutlet var lblReward: UILabel!
    @IBOutlet var lblFee: UILabel!
    @IBOutlet var lblVat: UILabel!
    @IBOutlet var viewShadow: UIView!
    @IBOutlet var viewBrackDownHeight: NSLayoutConstraint!
    
    var sizes:[ItemSize] = []
    weak var parent: SendItmSizeVC!
    var pickAnotation: MKPointAnnotation!
    var dropAnotation: MKPointAnnotation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if tblView != nil{
            tblView.register(UINib(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "itemSizeHeader")
            tblView.contentInset = UIEdgeInsets(top: 10 * _widthRatio, left: 0, bottom: 10 * _widthRatio, right: 0)
        }
    }
    
    override func prepareForReuse() {
        if tfName != nil{
            tfName.text = ""
        }
    }
    
    func prepareNameAndSize() {
        sizes = parent.sizes
        tblView.reloadData()
    }
    
    func prepareSetpPickAddressUI() {
        let oldAno = mapView.annotations
        mapView.removeAnnotations(oldAno)
        lblAddress.text = nil
        viewDateTimeBottom.constant = 10 * _widthRatio
        viewDateTimeHeight.constant = 40 * _widthRatio
        lblPickUp.text = "PICKUP POINT"
        lblTitle.text = "WHERE DO YOU WANT ITEM COLLECTED FROM?" //WHERE DO YOU WANT TO PICK IT UP FROM?
        viewAddress.backgroundColor = UIColor.hexStringToUIColor(hexStr: "E2DDDD")
        viewSwsPoint.backgroundColor = UIColor.hexStringToUIColor(hexStr: "E2DDDD")
        viewAddText.isHidden = true
        viewProgressConst.constant = 94 * _widthRatio
        if let add = parent.sendData.picAddress {
            viewAddText.isHidden = false
            viewSwsPoint.backgroundColor = UIColor.swdThemeRedColor()
            self.lblAddress.text = add.formatedAddress
            self.setMap(lat: add.lat, long: add.long,isPick: true)
        }else if let add = parent.sendData.picLookAdd{
            viewAddText.isHidden = false
            viewAddress.backgroundColor = UIColor.swdThemeRedColor()
            self.lblAddress.text = add.formatedAddress
            self.setMap(lat: add.lat, long: add.long, isPick: true)
        }
        
        if let date = parent.sendData.pickDate{
            self.lblDeliverBy.text = "Available From: \(Date.getLocalString(from: date, format: "dd. MMM hh:mm a"))"
        }else{
            self.lblDeliverBy.text = "Available From: Flexible"
        }
    }
    
    func prepareSetpDropAddressUI() {
        let oldAno = mapView.annotations
        mapView.removeAnnotations(oldAno)
        viewDateTimeBottom.constant = 0
        viewDateTimeHeight.constant = 0
        lblPickUp.text = "DELIVERY POINT"
        lblTitle.text = "WHERE DO YOU WANT TO SEND TO?"
        lblAddress.text = nil
        viewProgressConst.constant = 187 * _widthRatio
        viewAddress.backgroundColor = UIColor.hexStringToUIColor(hexStr: "E2DDDD")
        viewSwsPoint.backgroundColor = UIColor.hexStringToUIColor(hexStr: "E2DDDD")
        viewAddText.isHidden = true
        
        if let add = parent.sendData.picAddress {
            self.setMap(lat: add.lat, long: add.long,isPick: true)
        }else if let add = parent.sendData.picLookAdd{
            self.setMap(lat: add.lat, long: add.long, isPick: true)
        }
        
        if let add = parent.sendData.dropAddress {
            viewAddText.isHidden = false
            viewSwsPoint.backgroundColor = UIColor.swdThemeRedColor()
            self.lblAddress.text = add.formatedAddress
            self.setMap(lat: add.lat, long: add.long, isPick: false)
        }else if let add = parent.sendData.dropLookAdd{
            viewAddText.isHidden = false
            viewAddress.backgroundColor = UIColor.swdThemeRedColor()
            self.lblAddress.text = add.formatedAddress
            self.setMap(lat: add.lat, long: add.long, isPick: false)
        }
        if let date = parent.sendData.delDate{
            self.lblDeliverBy.text = "Deliver By: \(Date.getLocalString(from: date, format: "dd. MMM hh:mm a"))"
        }else{
            self.lblDeliverBy.text = "Deliver By: Flexible"
        }
    }
    
    func setMap(lat: Double, long: Double, isPick: Bool) {
        let cord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        if isPick{
            if pickAnotation != nil{
                mapView.removeAnnotation(pickAnotation)
            }
            pickAnotation = MKPointAnnotation()
            pickAnotation.title = "PICK UP"
            pickAnotation.coordinate = cord
            mapView.addAnnotation(pickAnotation)
        }else{
            if dropAnotation != nil{
                mapView.removeAnnotation(dropAnotation)
            }
            dropAnotation = MKPointAnnotation()
            dropAnotation.title = "DROP OFF"
            dropAnotation.coordinate = cord
            mapView.addAnnotation(dropAnotation)
        }
        if isPick{
            mapView.showAnnotations([pickAnotation], animated: true)
        }else{
            mapView.showAnnotations([dropAnotation, pickAnotation], animated: true)
        }
    }
    
    func prepareSetpFourUI() {
        btnShowBrakdwn.isSelected = parent.isShowPriceBrackDown
        if parent.isShowPriceBrackDown{
            let rect = CGRect(x: 0, y: 0, width: 394 * _widthRatio, height: 370 * _widthRatio)
            viewShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
            viewBrackDownHeight.constant = 370 * _widthRatio
        }else{
            let rect = CGRect(x: 0, y: 0, width: 394 * _widthRatio, height: 235 * _widthRatio)
            viewShadow.layer.shadowPath = UIBezierPath(rect: rect).cgPath
            viewBrackDownHeight.constant = 235 * _widthRatio
        }
        
        if parent.sendData.isOwnPriceSet{
            tfName.inputAccessoryView = parent.toolBar
            if let str = _numberFormatter.string(from: NSNumber(value: parent.sendData.ownCharge)){
                tfName.placeholder = str
            }
            setPriceForOwn()
        }else{
            lblPrice.text = "£\(parent.sendData.recommendedCharge.getFormattedValue(str: "2")!)"
            lblFee.text = "£\(parent.sendData.fee.getFormattedValue(str: "1")!)"
            lblVat.text = "£\(parent.sendData.vat.getFormattedValue(str: "1")!)"
            let swsPrice = parent.sendData.recommendedCharge - parent.sendData.fee - parent.sendData.vat
            lblReward.text = "£\(swsPrice.getFormattedValue(str: "1")!)"
        }
    }
    
    func setPriceForOwn() {
        lblFee.text = "£\(parent.sendData.fee.getFormattedValue(str: "1")!)"
        lblVat.text = "£\(parent.sendData.vat.getFormattedValue(str: "1")!)"
        let swsPrice = parent.sendData.ownCharge - parent.sendData.fee - parent.sendData.vat
        if swsPrice < 0{
            lblReward.text = "£0.0"
        }else{
            lblReward.text = "£\(swsPrice.getFormattedValue(str: "1")!)"
        }
    }
}

// MARK: - MKMapViewDelegate
extension SendItmCollectionCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let reuserIdent = "mapPin"
        var ano = mapView.dequeueReusableAnnotationView(withIdentifier: reuserIdent) as? KPAnnotaionView
        if ano == nil{
            ano = KPAnnotaionView.createObjectFromNib()//MKAnnotationView(annotation: annotation, reuseIdentifier: reuserIdent)
            ano?.annotation = annotation
            ano?.lblTitle.text = annotation.title!
        }else{
            ano?.annotation = annotation
            ano?.lblTitle.text = annotation.title!
        }
        return ano
    }
}

// MARK: - UITextFieldDelegate
extension SendItmCollectionCell: UITextFieldDelegate {

    @IBAction func textChagne(_ sender: UITextField) {
        if sender.tag == 0{
            parent.sendData.title = sender.text!.trimmedString()
        }else{
            if !sender.text!.isEmpty{
                let str = sender.text!.replacingOccurrences(of: "£", with: "")
                if str.isEmpty{
                    sender.text = ""
                }else{
                    sender.text = "£\(str)"
                }
                if let amount = _numberFormatter.number(from: sender.text!){
                    parent.sendData.ownCharge = amount.doubleValue
                    setPriceForOwn()
                }
            }else{
                parent.sendData.ownCharge = 0
                setPriceForOwn()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SendItmCollectionCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return sizes.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 159 * _widthRatio
        }else if indexPath.section == 1{
            return 85 * _widthRatio
        }else{
            if indexPath.row == 0{
                return 75 * _widthRatio
            }else{
                return 65 * _widthRatio
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 55 * _widthRatio
        }else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "itemSizeHeader") as! HeaderView
        header.lblText.text = "SELECT ITEM SIZE"
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SendItmTblCell
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "itmTitleCell", for: indexPath) as! SendItmTblCell
            cell.tfTitle.text = parent.sendData.title
        }else if indexPath.section == 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "itemSizeCell", for: indexPath) as! SendItmTblCell
            cell.lblTitle.text = sizes[indexPath.row].title
            cell.lblDesc.text = sizes[indexPath.row].desc
            cell.imgView.kf.setImage(with: sizes[indexPath.row].imgUrl, completionHandler: { (img, error, catchType, url) in
                if let _ = img{
                    cell.imgView.image = img?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                }
            })
            cell.imgView.tintColor = sizes[indexPath.row] == parent.sendData.itemSize ? UIColor.swdThemeRedColor() : UIColor.hexStringToUIColor(hexStr: "A0A0A0")
            cell.imgTick.isHidden = sizes[indexPath.row] != parent.sendData.itemSize
            
            cell.viewShadowTop.constant = -5
            cell.lblSeparator.isHidden = false
            cell.viewShadowBottom.constant = -5
            if indexPath.row == 0{
                cell.viewShadowTop.constant = 5 * _widthRatio
            }else if indexPath.row == sizes.count - 1{
                cell.viewShadowBottom.constant = 5 * _widthRatio
                cell.lblSeparator.isHidden = true
            }
        }else{
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "itemValueCell", for: indexPath) as! SendItmTblCell
                if let _ = parent.sendData.price{
                    cell.imgTick.isHidden = false
                }else{
                    cell.imgTick.isHidden = true
                }
            }else{
                cell = tableView.dequeueReusableCell(withIdentifier: "continueCell", for: indexPath) as! SendItmTblCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            parent.sendData.itemSize = sizes[indexPath.row]
            tblView.reloadData()
        }else if indexPath.section == 2 && indexPath.row == 0{
            parent.performSegue(withIdentifier: "priceSegue", sender: nil)
        }
    }
}
