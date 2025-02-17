//
//  ActorDetailsVC.swift
//  
//
//  Created by Parth on 27/01/25.
//

import UIKit

public class ActorDetailsVC: UIViewController {

    static func storyboardInstance() -> ActorDetailsVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "ActorDetailsVC") as! ActorDetailsVC
    }
    @IBOutlet weak var ActorDetailsTBL: UITableView!
    
    var actorID = ""
    var actorData : ActorDetailsModel?
    var isCellExpanded = false
    var isfromVideo = false
    public struct Identifiers {
        static let kActorDetailTableViewCell = "ActorDetailTableViewCell"
        static let kCategoriesTableViewCell = "CategoriesTableViewCell"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("ActorDetailsVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        // Do any additional setup after loading the view.
        GetActorDetail()
        ConfigureTableView()
    }
    @IBAction func closeClick(_ sender: UIButton) {
        if isfromVideo{
            rotate_flag = true
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func ConfigureTableView(){
        
        ActorDetailsTBL.delegate = self
        ActorDetailsTBL.dataSource = self
        ActorDetailsTBL.register(UINib(nibName: Identifiers.kActorDetailTableViewCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kActorDetailTableViewCell)
        ActorDetailsTBL.register(UINib(nibName: Identifiers.kCategoriesTableViewCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCategoriesTableViewCell)
        ActorDetailsTBL.isHidden = true
        
        ActorDetailsTBL.estimatedRowHeight = 850
        ActorDetailsTBL.rowHeight = UITableView.automaticDimension
        
        ActorDetailsTBL.contentInsetAdjustmentBehavior = .never
        ActorDetailsTBL.insetsContentViewsToSafeArea = false
        ActorDetailsTBL.insetsLayoutMarginsFromSafeArea = false
        ActorDetailsTBL.preservesSuperviewLayoutMargins = false
    }
    
}
extension ActorDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = ActorDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kActorDetailTableViewCell, for: indexPath) as! ActorDetailTableViewCell
            
            cell.lblDesc.text = actorData?.info ?? ""

            let maxSize = CGSize(width: cell.lblDesc.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            let labelSize = (cell.lblDesc.text! as NSString).boundingRect(with: maxSize,
                                                                     options: .usesLineFragmentOrigin,
                                                                     attributes: [NSAttributedString.Key.font: cell.lblDesc.font],
                                                                     context: nil).size
            let textHeight = ceil(labelSize.height)

            print("Cell Inside : \(textHeight)")
            cell.readMoreUV.isHidden = textHeight < 370 ? true : false
            cell.ageUV.isHidden = false
            cell.heightUV.isHidden = false
            cell.lblMovieTitle.text = actorData?.name ?? ""
            cell.pageControl.numberOfPages = actorData?.images?.count ?? 0
            cell.imageArr = actorData?.images
            cell.cvImageLIst.reloadData()

            cell.readMoreTapped = { [weak self] in
                self?.isCellExpanded.toggle()
                self?.ActorDetailsTBL.beginUpdates()
                self?.ActorDetailsTBL.endUpdates()
                self?.ActorDetailsTBL.reloadData()
            }
            
            return cell
        }else if indexPath.row == 1 {
            
            let cell = ActorDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorData?.projectsActed?.count ?? 0 > 0{
                cell.actorDetail = actorData?.projectsActed
                cell.isActorDetails = true
                cell.index = indexPath.row
                cell.cvCategory.reloadData()
                
                let title = "Projects Acted"
                let count = actorData?.projectsActed?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.MovieClick = { (videoDic) -> Void in
                    let viewcontroller = VideoDetailsFromOtherVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.VideoListData = videoDic
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            return cell
            
        }else if indexPath.row == 2 {
            
            let cell = ActorDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorData?.projectsDirected?.count ?? 0 > 0{
                cell.actorDetail = actorData?.projectsDirected
                cell.isActorDetails = true
                cell.index = indexPath.row
                cell.cvCategory.reloadData()
                
                let title = "Projects Directed"
                let count = actorData?.projectsDirected?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.MovieClick = { (videoDic) -> Void in
                    let viewcontroller = VideoDetailsFromOtherVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.VideoListData = videoDic
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            
            return cell
        }else{
            
            let cell = ActorDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorData?.projectsProduced?.count ?? 0 > 0{
                cell.actorDetail = actorData?.projectsProduced
                cell.isActorDetails = true
                cell.index = indexPath.row
                cell.cvCategory.reloadData()
                
                let title = "Projects Produced"
                let count = actorData?.projectsProduced?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.MovieClick = { (videoDic) -> Void in
                    let viewcontroller = VideoDetailsFromOtherVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.VideoListData = videoDic
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            
            return cell
        }
        
        
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if isCellExpanded{
               return UITableView.automaticDimension
            }else{
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.kActorDetailTableViewCell) as? ActorDetailTableViewCell else {
                    return UITableView.automaticDimension
                }
                cell.lblDesc.text = actorData?.info ?? ""
                let maxSize = CGSize(width: cell.lblDesc.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
                let labelSize = (cell.lblDesc.text! as NSString).boundingRect(with: maxSize,
                                                                         options: .usesLineFragmentOrigin,
                                                                         attributes: [NSAttributedString.Key.font: cell.lblDesc.font],
                                                                         context: nil).size
                let textHeight = ceil(labelSize.height)
                print("Cell OutSide : \(textHeight)")
                if (textHeight + 41) < 370 {
                    return 700
                }else{
                    return 850
                }
            }
            //return isCellExpanded ? UITableView.automaticDimension : 850
        }else if indexPath.row == 1 {
            if actorData?.projectsActed?.count ?? 0 > 0{
                return 400
            }
            return 0
        }else if indexPath.row == 2 {
            if actorData?.projectsDirected?.count ?? 0 > 0{
                return 400
            }
            return 0
        }else{
            if actorData?.projectsProduced?.count ?? 0 > 0{
                return 400
            }
            return 0
        }
        
    }
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
extension ActorDetailsVC {
    func GetActorDetail(){

        let params = [ : ] as [String : Any]
        //print(params)
        start_loading()
        
        self.get_api_request("\(BaseURLOffice)person/\(actorID)/view\(loadContents)", headers: headersCommon).responseDecodable(of: ActorDetailsModel.self) { response in
            //print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(ActorDetailsModel.self, from: responseData)
                        self.actorData = welcome
                        self.ActorDetailsTBL.isHidden = false
                        self.ActorDetailsTBL.reloadData()
                    } catch {
                        self.ShowAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
}
