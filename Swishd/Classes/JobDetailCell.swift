

import Foundation
import UIKit
import MapKit

class JobDetailCell: ConstrainedTableViewCell {
    
    /// Map View
    @IBOutlet weak var mapView: MKMapView!
    
    /// Size and description
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblSize: UILabel!
    @IBOutlet var lblSenderName: UILabel!
    @IBOutlet var lblSender: UILabel!
    @IBOutlet var imgSize: UIImageView!
    @IBOutlet var btnEditJob: UIButton!
    
    /// Address Info
    @IBOutlet var lblPickDate: UILabel!
    @IBOutlet var lblDropDate: UILabel!
    @IBOutlet var lblPickAddr: UILabel!
    @IBOutlet var lblDropAddr: UILabel!
    @IBOutlet var lblFrom: UILabel!
    @IBOutlet var lblTo: UILabel!
    
    // QRCode 
    @IBOutlet var imgViewCode: UIImageView!
    @IBOutlet var lblCode: UILabel!
    
    // Activity
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblActivity: UILabel!
    
    //Propose Time
    @IBOutlet var lblProposeTime: UILabel!
    
    /// Variables
    var fromAno: MKPointAnnotation!
    var toAno: MKPointAnnotation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - UI Related
extension JobDetailCell {

    func prepareMapUI(job: Job) {
        
        if fromAno != nil{
            mapView.removeAnnotation(fromAno)
        }
        
        if toAno != nil{
            mapView.removeAnnotation(toAno)
        }
        
        fromAno = MKPointAnnotation()
        toAno = MKPointAnnotation()
        
        if let point = job.pickOffice{
            fromAno.coordinate = CLLocationCoordinate2D(latitude: point.address.lat, longitude: point.address.long)
        }else{
            fromAno.coordinate = CLLocationCoordinate2D(latitude: job.pickLocation!.lat, longitude: job.pickLocation!.long)
        }
        if let point = job.dropOffice{
            toAno.coordinate = CLLocationCoordinate2D(latitude: point.address.lat, longitude: point.address.long)
        }else{
            toAno.coordinate = CLLocationCoordinate2D(latitude: job.dropLocation!.lat, longitude: job.dropLocation!.long)
        }
        
        fromAno.title = "PICK UP"
        toAno.title = "DROP OFF"
        mapView.addAnnotations([fromAno, toAno])
        mapView.showAnnotations([fromAno, toAno], animated: true)
    }
    
    func prepareQrCodeUI(job: Job) {
        imgViewCode.kf.setImage(with: job.displayCode!.codeUrl, placeholder: _placeImage)
        lblCode.text = job.displayCode!.code
    }
    
    func prepareActivityUI(job: Job) {
        if job.isSentByMe{
            imgUser.kf.setImage(with: job.swishr?.imageUrl, placeholder: _placeImage)
            lblActivity.text = "\(job.swishr!.userName) is your swishr"
        }else{
            imgUser.kf.setImage(with: job.sender?.imageUrl, placeholder: _placeImage)
            lblActivity.text = "You are helping \(job.sender!.userName)"
        }
    }
    
    func prepareOfferUI(job: Job) {
        lblActivity.text = "\(job.jobRequestCount > 1 ? "\(job.jobRequestCount) Swishrs" : "\(job.jobRequestCount) Swishr") have offered to swish your item."
    }
    
    func prepareSizeUI(job: Job) {
        lblSize.text = job.itemSize.title
        lblTitle.text = job.jobTitle
        lblPrice.text = "£\(job.recommandPrice)"
        
        if job.isSentByMe{
            if job.status == JobStatus.pending || job.status == JobStatus.unknown{
                btnEditJob.isHidden = false
            }else{
                btnEditJob.isHidden = true
            }
        }else{
            btnEditJob.isHidden = true
        }
        
        if job.isSentByMe || job.status == JobStatus.active{
            lblSender.text = "Status:"
            lblSenderName.text = job.status.rawValue
        }else{
            lblSender.text = "Sendr:"
            lblSenderName.text = job.sender?.userName
        }
        
        imgSize.kf.setImage(with: job.itemSize.imgUrl, completionHandler: { (img, error, catchType, url) in
            if let _ = img{
                self.imgSize.image = img?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            }
        })
        imgSize.tintColor = UIColor.hexStringToUIColor(hexStr: "A0A0A0")
    }

    func prepareTimeUI(job: Job) {
        lblPickDate.text = job.pickDateFullStr
        lblDropDate.text = job.dropDateFullStr
    }
    
    func prepareAddrUI(job: Job) {
//        if let office = job.pickOffice{
//            lblFrom.text = office.name
//        }else{
//            lblFrom.text = "From:"
//        }
//        
//        if let office = job.dropOffice{
//            lblTo.text = "To: \(office.name)"
//        }else{
//            lblTo.text = "To:"
//        }
        lblTo.text = job.dropAddress
        lblFrom.text = job.pickAddress
    }
}

// MARK: - MKMapViewDelegate
extension JobDetailCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let reuserIdent = "mapPin"
        var ano = mapView.dequeueReusableAnnotationView(withIdentifier: reuserIdent) as? KPAnnotaionView
        if ano == nil{
            ano = KPAnnotaionView.createObjectFromNib()
            ano?.annotation = annotation
            ano?.lblTitle.text = annotation.title!
        }else{
            ano?.annotation = annotation
            ano?.lblTitle.text = annotation.title!
        }
        return ano
    }
}

