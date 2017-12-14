//
//  SearchCell.swift

import Foundation

enum Day: String{

    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesDay = "Wedenesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    case unknown = "unknown"
    case all = "all"
    
    init(str: String) {
        if let val = Day(rawValue: str){
            self = val
        }else{
            self = .unknown
        }
    }
}

class SearchCell: ConstrainedTableViewCell{
    
    @IBOutlet weak var lblFromAdd: UILabel!
    @IBOutlet weak var lbltoAdd: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var imgSaveSatus: UIImageView!
    
    @IBOutlet var btnMonday: UIButton!
    @IBOutlet var btnTuesday: UIButton!
    @IBOutlet var btnWenday: UIButton!
    @IBOutlet var btnThursday: UIButton!
    @IBOutlet var btnFriday: UIButton!
    @IBOutlet var btnSaturday: UIButton!
    @IBOutlet var btnSunday: UIButton!
    
    @IBOutlet var vwEveryday: UIView!
    @IBOutlet var lblDate: UILabel!
    
    weak var savedSearchParent: SavedSerchVC?
    weak var recentSearchParent: SerchVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(search: Search){
        btnSave.tag = self.tag
        lblFromAdd.text = search.sourceAddress?.formattedAddress
        lbltoAdd.text = search.destAddress?.formattedAddress
        imgSaveSatus.image = search.searchStatus == .saved ? UIImage(named: "ic_save_orange") : UIImage(named: "ic_star_black_unsave")
        if let parent = savedSearchParent{
            btnSave.addTarget(parent, action: #selector(parent.btnRemoveAction(_:)), for: .touchUpInside)
        }else{
            btnSave.addTarget(recentSearchParent, action: #selector(recentSearchParent?.btnUpdateSaveStaus(_:)), for: .touchUpInside)
        }
    }
    
    func prepareUIForAdvanceSaecrh(search: Search){
        btnSave.tag = self.tag
        vwEveryday.isHidden = false
        lblDate.isHidden = false
        lblFromAdd.text = search.sourceAddress?.formattedAddress
        lbltoAdd.text = search.destAddress?.formattedAddress
        imgSaveSatus.image = search.searchStatus == .saved ? UIImage(named: "ic_save_orange") : UIImage(named: "ic_star_black_unsave")
        if let parent = savedSearchParent{
            btnSave.addTarget(parent, action: #selector(parent.btnRemoveAction(_:)), for: .touchUpInside)
        }else{
            btnSave.addTarget(recentSearchParent, action: #selector(recentSearchParent?.btnUpdateSaveStaus(_:)), for: .touchUpInside)
        }
        if let date = search.specificDate{
            lblDate.text = Date.getLocalString(from: date, format: "dd.MMM yyyy")
        }else if search.isAnytime{
            lblDate.text = "Anytime"
        }else{
            lblDate.isHidden = true
        }
            
        if !search.everyDay.isEmpty{
            for day in search.everyDay{
                switch day {
                case .monday:
                    btnMonday.isSelected = true
                case .tuesday:
                    btnTuesday.isSelected = true
                case .wednesDay:
                    btnWenday.isSelected = true
                case .thursday:
                    btnThursday.isSelected = true
                case .friday:
                    btnFriday.isSelected = true
                case .saturday:
                    btnSaturday.isSelected = true
                case .sunday:
                    btnSunday.isSelected = true
                case .all:
                    btnMonday.isSelected = true
                    btnTuesday.isSelected = true
                    btnWenday.isSelected = true
                    btnThursday.isSelected = true
                    btnFriday.isSelected = true
                    btnSaturday.isSelected = true
                    btnSunday.isSelected = true
                default:
                    kprint(items: "Default")
                }
            }
        }else{
                vwEveryday.isHidden = true
            }
        }
}
