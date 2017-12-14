

import UIKit
import MapKit

class SwishdPointDetailCell: ConstrainedTableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblOpenDay: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var lblWebSite: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SwishdPointDetailVC: ParentViewController {

    /// Variables
    var pointId: String!
    var swisPoint: SwishdPoint!
    var location: CLLocation?
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getSwishdPointDetail()
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

// MARK: - UI Related.
extension SwishdPointDetailVC {
    
    func prepareUI()  {
        referesh.addTarget(self, action: #selector(self.refreshData(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(referesh)
    }
    
    @objc func refreshData(sender: UIRefreshControl)  {
        location = nil
        getSwishdPointDetail()
    }
}

// MARK: - Tableview methods
extension SwishdPointDetailVC {

    func numberOfSections(in tableView: UITableView) -> Int {
        if swisPoint != nil{
            return 3
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return swisPoint.schedules.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 120
        }else if indexPath.section == 1{
            return 25
        }else{
            let hei = swisPoint.address.formattedAddress.heightWithConstrainedWidth(width: _screenSize.width - 30, font: UIFont.avenirBook(size: 16))
            return hei + 200
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SwishdPointDetailCell!
        if indexPath.section == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwishdPointDetailCell
            cell.lblName.text = swisPoint.name
            cell.lblStatus.text = swisPoint.status.rawValue
            cell.lblDistance.text = "\(swisPoint.distance.getFormattedValue(str: "1")!) KM"
        }else if indexPath.section == 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellOpenTime", for: indexPath) as! SwishdPointDetailCell
            cell.lblOpenDay.text = "\(swisPoint.schedules[indexPath.row].dayString):"
            cell.lblTime.text = swisPoint.schedules[indexPath.row].timeString
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo", for: indexPath) as! SwishdPointDetailCell
            cell.lblAddress.text = swisPoint.address.formattedAddress
            cell.lblPhone.text = swisPoint.phone
            cell.lblWebSite.text = swisPoint.webSite
        }
        return cell
    }
}

// MARK: - Webcall Methods
extension SwishdPointDetailVC {

    func getSwishdPointDetail()  {
        if let _ = location{
            apiCall()
        }else{
            if !referesh.isRefreshing{
                self.showCentralSpinner()
            }
            weak var controller: UIViewController! = self
            UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
                if let loc = location {
                    self.location = loc
                    self.apiCall()
                }else{
                    self.hideCentralSpinner()
                    self.referesh.endRefreshing()
                }
            }
        }
    }
    
    func apiCall() {
        KPWebCall.call.getSwishdPointDetail(officeId: pointId, lat: location!.coordinate.latitude, long: location!.coordinate.longitude) { (json, status) in
            self.hideCentralSpinner()
            self.referesh.endRefreshing()
            if status == 200{
                if let dict = (json as? NSDictionary)?["data"] as? NSDictionary{
                    self.swisPoint = SwishdPoint(dict: dict)
                    self.tableView.reloadData()
                }
            }else{
                self.showError(data: json, yPos: _topMsgBarConstant)
            }
        }
    }
}
