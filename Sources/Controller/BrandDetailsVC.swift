//
//  BrandDetailsVC.swift
//  
//
//  Created by Parth on 27/01/25.
//

import UIKit

public class BrandDetailsVC: UIViewController {

    static func storyboardInstance() -> BrandDetailsVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "BrandDetailsVC") as! BrandDetailsVC
    }
    public struct Identifiers {
        static let kBrandImageCell = "BrandImageCell"
        static let kMoreProductTBLCell = "MoreProductTBLCell"
        static let kCustomerReviewTBLCell = "CustomerReviewTBLCell"
        static let kCategoriesTableViewCell = "CategoriesTableViewCell"
    }
    @IBOutlet weak var brandDetailsTBL: UITableView!
    var brandID = ""
    var brandData : BrandDataModel?
    var isCellExpanded = false
    var isfromVideo = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let view = Bundle.module.loadNibNamed("BrandDetailsVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        GetBrandDetail(brandid: brandID)
        ConfigureTableView()
    }
    @IBAction func backClick_Action(_ sender: UIButton) {
        if isfromVideo{
            rotate_flag = true
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func ConfigureTableView(){
        
        brandDetailsTBL.delegate = self
        brandDetailsTBL.dataSource = self
        brandDetailsTBL.register(UINib(nibName: Identifiers.kBrandImageCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kBrandImageCell)
        brandDetailsTBL.register(UINib(nibName: Identifiers.kMoreProductTBLCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kMoreProductTBLCell)
        brandDetailsTBL.register(UINib(nibName: Identifiers.kCustomerReviewTBLCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCustomerReviewTBLCell)
        brandDetailsTBL.register(UINib(nibName: Identifiers.kCategoriesTableViewCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCategoriesTableViewCell)
//        brandDetailsTBL.separatorStyle = .none
        brandDetailsTBL.isHidden = true
        
        brandDetailsTBL.estimatedRowHeight = 850
        brandDetailsTBL.rowHeight = UITableView.automaticDimension
        
        brandDetailsTBL.contentInsetAdjustmentBehavior = .never
        brandDetailsTBL.insetsContentViewsToSafeArea = false
        brandDetailsTBL.insetsLayoutMarginsFromSafeArea = false
        brandDetailsTBL.preservesSuperviewLayoutMargins = false
        
    }
}
extension BrandDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = brandDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kBrandImageCell, for: indexPath) as! BrandImageCell
            cell.selectionStyle = .none
            
            cell.desLBL.text = brandData?.info ?? ""
            let maxSize = CGSize(width: cell.desLBL.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            let labelSize = (cell.desLBL.text! as NSString).boundingRect(with: maxSize,
                                                                         options: .usesLineFragmentOrigin,
                                                                         attributes: [NSAttributedString.Key.font: cell.desLBL.font],
                                                                         context: nil).size
            let textHeight = ceil(labelSize.height)
            cell.readMoreUV.isHidden = textHeight < 370 ? true : false
            
            cell.brandNameLBL.text = brandData?.name ?? ""
            cell.brandRating.rating = Double(brandData?.rating ?? 0)
            cell.reviewLBL.text =  "\(brandData?.rating ?? 0) (\(Int(brandData?.reviewsCnt ?? 0)) Review)"
            cell.imageArr = brandData?.images
            cell.brandImgCV.reloadData()
            
            cell.readMoreTapped = { [weak self] in
                self?.isCellExpanded.toggle()
                self?.brandDetailsTBL.beginUpdates()
                self?.brandDetailsTBL.endUpdates()
                self?.brandDetailsTBL.reloadData()
            }
            
            return cell
        }else if indexPath.row == 1{
            let cell = brandDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kMoreProductTBLCell, for: indexPath) as! MoreProductTBLCell
            cell.selectionStyle = .none
            cell.productARY = brandData?.products
            cell.productCV.reloadData()
            cell.gotoSotreBTN.isHidden = true
            
            cell.prodcutClick = { indexp in
                let viewcontroller = ProdutDetailsVC()
                viewcontroller.modalPresentationStyle = .custom
                let prodID = self.brandData?.products?[indexp].id ?? 0
                viewcontroller.productID = "\(prodID)"
                self.navigationController?.pushViewController(viewcontroller, animated: true)
            }
            return cell
        }else if indexPath.row == 2{
            let cell = brandDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kCustomerReviewTBLCell, for: indexPath) as! CustomerReviewTBLCell
            cell.selectionStyle = .none
            cell.reviewCountLBL.text = "Customer Reviews (\(Int( brandData?.reviewsCnt ?? 0)))"
            cell.reviewARY = brandData?.reviews
            cell.reviewCV.reloadData()
            return cell
        }else{
            let cell = brandDetailsTBL.dequeueReusableCell(withIdentifier: Identifiers.kCategoriesTableViewCell, for: indexPath) as! CategoriesTableViewCell
            cell.VideoList = brandData?.projects
            cell.lblVideoCount.text = "Movies(\(brandData?.projects?.count ?? 0))"
            cell.cvCategory.reloadData()
            
            cell.MovieClick = { (videoDic) -> Void in
                let viewcontroller = VideoDetailsFromOtherVC()
                viewcontroller.modalPresentationStyle = .custom
                viewcontroller.VideoListData = videoDic
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
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.kBrandImageCell) as? BrandImageCell else {
                    return UITableView.automaticDimension
                }
                cell.desLBL.text = brandData?.info ?? ""
                let maxSize = CGSize(width: cell.desLBL.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
                let labelSize = (cell.desLBL.text! as NSString).boundingRect(with: maxSize,
                                                                         options: .usesLineFragmentOrigin,
                                                                         attributes: [NSAttributedString.Key.font: cell.desLBL.font],
                                                                         context: nil).size
                let textHeight = ceil(labelSize.height)
                if textHeight < 370 {
                    return 700
                }else{
                    return 850
                }
            }
            
           //return isCellExpanded ? UITableView.automaticDimension : 250
        }else if indexPath.row == 1{
            return 400.0
        }else if indexPath.row == 2{
            return 250.0
        }else{
            return 400.0
        }
      }
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension BrandDetailsVC {
    func GetBrandDetail(brandid : String){

        let params = [ : ] as [String : Any]
        print(params)
        start_loading()
    
        self.get_api_request("\(BaseURLOffice)brand/\(brandid)/view\(loadContents)", headers: headersCommon).responseDecodable(of: BrandDataModel.self) { response in
            print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(BrandDataModel.self, from: responseData)
                        self.brandData = welcome
                        self.brandDetailsTBL.isHidden = false
                        self.brandDetailsTBL.reloadData()
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
