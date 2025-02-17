//
//  VideoDetailsFromOtherVC.swift
//  
//
//  Created by Parth on 27/01/25.
//

import UIKit

public class VideoDetailsFromOtherVC: UIViewController {

    static func storyboardInstance() -> VideoDetailsFromOtherVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "VideoDetailsFromOtherVC") as! VideoDetailsFromOtherVC
    }
    
    @IBOutlet weak var tblList: UITableView!
    
    var VideoListData : HomeListModel?
    var actorDetails : EntitiesDataModel?
    var isCellExpanded = false
    public struct Identifiers {
        static let kActorDetailTableViewCell = "ActorDetailTableViewCell"
        static let kCategoriesTableViewCell = "CategoriesTableViewCell"
    }
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let view = Bundle.module.loadNibNamed("VideoDetailsFromOtherVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        projectID = "\(VideoListData?.id ?? 0)"
        GetActorDetail(videoID: "\(self.VideoListData?.id ?? 0)")
    }

    @IBAction func backClick_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func ConfigureTableView(){
        
        tblList.delegate = self
        tblList.dataSource = self
        tblList.register(UINib(nibName: Identifiers.kActorDetailTableViewCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kActorDetailTableViewCell)
        tblList.register(UINib(nibName: Identifiers.kCategoriesTableViewCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCategoriesTableViewCell)
        
        tblList.estimatedRowHeight = 850
        tblList.rowHeight = UITableView.automaticDimension
        
        tblList.contentInsetAdjustmentBehavior = .never
        tblList.insetsContentViewsToSafeArea = false
        tblList.insetsLayoutMarginsFromSafeArea = false
        tblList.preservesSuperviewLayoutMargins = false
        
        self.tblList.reloadData()
        
        
    }
    @IBAction func playClick_Action(_ sender: UIButton) {
//        rotate_flag = true
//        let viewcontroller = mainStoryboard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
//        viewcontroller.VideoString = self.VideoListData?.videoURL ?? ""
//        viewcontroller.VideoListDic = self.VideoListData
//        viewcontroller.brandID = "\(self.VideoListData?.brands?[0].id ?? 0)"
//        let nav = UINavigationController(rootViewController: viewcontroller)
//        nav.isNavigationBarHidden = true
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true)
        
    }
}
extension VideoDetailsFromOtherVC : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tblList.dequeueReusableCell(withIdentifier: Identifiers.kActorDetailTableViewCell, for: indexPath) as! ActorDetailTableViewCell
            
            cell.lblDesc.text = VideoListData?.info ?? ""//"\(VideoListData?.info ?? "") \(VideoListData?.info ?? "") \(VideoListData?.info ?? "")"
            
            let maxSize = CGSize(width: cell.lblDesc.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            let labelSize = (cell.lblDesc.text! as NSString).boundingRect(with: maxSize,
                                                                     options: .usesLineFragmentOrigin,
                                                                     attributes: [NSAttributedString.Key.font: cell.lblDesc.font],
                                                                     context: nil).size
            let textHeight = ceil(labelSize.height)
            
            cell.readMoreUV.isHidden = textHeight < 370 ? true : false
            cell.yearTxt = "\(VideoListData?.year ?? 0)"
            
            
            cell.gebneArr = VideoListData?.genres
            //cell.lblMoviewInfo.text = VideoListData?.type ?? ""
            cell.lblMovieTitle.text = VideoListData?.name ?? ""
            cell.pageControl.numberOfPages = VideoListData?.images?.count ?? 0
            cell.imageArr = VideoListData?.images
            cell.cvImageLIst.reloadData()
            
            cell.readMoreTapped = { [weak self] in
                self?.isCellExpanded.toggle()
                self?.tblList.beginUpdates()
                self?.tblList.endUpdates()
                self?.tblList.reloadData()
            }
            
            return cell
        }else if indexPath.row == 1{
            let cell = tblList.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorDetails?.actors?.count ?? 0 > 0{
                cell.VideoDetail = VideoListData
                cell.isVideoDetail = true
                cell.index = indexPath.row
                cell.userARY = actorDetails?.actors
                let title = "Actors"
                let count = actorDetails?.actors?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.ActorClick = { (actorID) -> Void in
                    let viewcontroller = ActorDetailsVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.actorID = "\(actorID)"
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            
            return cell
            
        }else if indexPath.row == 2{
            let cell = tblList.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorDetails?.directors?.count ?? 0 > 0{
                cell.VideoDetail = VideoListData
                cell.isVideoDetail = true
                cell.index = indexPath.row
                cell.userARY = actorDetails?.directors
                let title = "Directores"
                let count = actorDetails?.directors?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.ActorClick = { (actorID) -> Void in
                    let viewcontroller = ActorDetailsVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.actorID = "\(actorID)"
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            return cell
        }else if indexPath.row == 3{
            let cell = tblList.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            if actorDetails?.producers?.count ?? 0 > 0{
                cell.VideoDetail = VideoListData
                cell.isVideoDetail = true
                cell.index = indexPath.row
                cell.userARY = actorDetails?.producers
                let title = "Producers"
                let count = actorDetails?.producers?.count ?? 0
                cell.lblVideoCount.text = "\(title) (\(count))"
                cell.cvCategory.reloadData()
                
                cell.ActorClick = { (actorID) -> Void in
                    let viewcontroller = ActorDetailsVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.actorID = "\(actorID)"
                    self.navigationController?.pushViewController(viewcontroller, animated: true)
                }
            }
            return cell
        }else {
            
            let cell = tblList.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            cell.VideoDetail = VideoListData
            cell.isVideoDetail = true
            cell.index = indexPath.row
            let title = "Brands"
            cell.brandARY = actorDetails?.brands
            let count = actorDetails?.brands?.count ?? 0
            cell.lblVideoCount.text = "\(title) (\(count))"
            cell.cvCategory.reloadData()
            
            cell.brandClick = { (actorID) -> Void in
                let viewcontroller = BrandDetailsVC()
                viewcontroller.modalPresentationStyle = .custom
                viewcontroller.brandID = "\(actorID)"
                self.navigationController?.pushViewController(viewcontroller, animated: true)
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
                cell.lblDesc.text = VideoListData?.info ?? ""
                let maxSize = CGSize(width: cell.lblDesc.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
                let labelSize = (cell.lblDesc.text! as NSString).boundingRect(with: maxSize,
                                                                         options: .usesLineFragmentOrigin,
                                                                         attributes: [NSAttributedString.Key.font: cell.lblDesc.font],
                                                                         context: nil).size
                let textHeight = ceil(labelSize.height)
                if textHeight < 370 {
                    return 700
                }else{
                    return 850
                }
            }
             
            //return isCellExpanded ? UITableView.automaticDimension : 850
        }else if indexPath.row == 1{
            if actorDetails?.actors?.count ?? 0 > 0{
                return 400
            }
            return 0
            
        }else if indexPath.row == 2{
            if actorDetails?.directors?.count ?? 0 > 0{
                return 400
            }
            return 0
        }else if indexPath.row == 3{
            if actorDetails?.producers?.count ?? 0 > 0{
                return 400
            }
            return 0
        }else {
            return 400
        }
        
    }
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
extension VideoDetailsFromOtherVC {
    
    func GetActorDetail(videoID: String){
        start_loading()
        self.get_api_request("\(BaseURLOffice)video/\(videoID)/entities\(loadContents)", headers: headersCommon).responseDecodable(of: EntitiesDataModel.self) { response in
            print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(EntitiesDataModel.self, from: responseData)
                        self.actorDetails = welcome
                        self.ConfigureTableView()
                        
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
