//
//  OrderDetailVC.swift
//  
//
//  Created by Jaydip Godhani on 28/01/25.
//

import UIKit
import Cosmos

protocol UpdateRatingDelegate: AnyObject {
    func updateRatingReload()
}

public class OrderDetailVC: UIViewController {

    static func storyboardInstance() -> OrderDetailVC {
        return profileStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
    }
    
    weak var ratingDelegate: UpdateRatingDelegate?
    @IBOutlet weak var tblOrderDetailList: UITableView!
    @IBOutlet weak var lblProductCount: UILabel!
    @IBOutlet weak var lblproductSubCount: UILabel!
    @IBOutlet weak var lblButtomProductCount: UILabel!
    @IBOutlet weak var lblButtomShippingCount: UILabel!
    @IBOutlet weak var lblItemsPrices: UILabel!
    @IBOutlet weak var lblShippingPrices: UILabel!
    @IBOutlet weak var lblTotlePay: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTotlePaid: UILabel!
    @IBOutlet weak var brandRatingUV: CosmosView!
    @IBOutlet weak var orderStatusIMG: UIImageViewX!
    @IBOutlet weak var brandNameLBL: UILabel!
    
    var arrproduct = [ProductElement]()
    var orderData : OrderDataModel?
    var productIndex = 0
    var isBrand = false
    var orderId: Int?
    var status: String?
    var date: String?
    var totlePaid: Int?
    var shippingPrices: Int?
    let placeholderLabel = UILabel()
    var rateText = ""
    var ratingReview = 0.0
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("OrderDetailVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        cellConfigure()
        setFillData()
    }
    
    func setFillData(){
        lblProductCount.text = "\(arrproduct.count) product"
        lblproductSubCount.text = "(\(arrproduct.count) items)"
        lblButtomProductCount.text = "Items (\(arrproduct.count))"
        lblButtomShippingCount.text = "Shipping fee (\(arrproduct.count))"
        lblOrderID.text = "# \(orderData?.number ?? 0)"
        lblStatus.text = "\(status ?? "")"
        lblTotlePaid.text = "US $\(totlePaid ?? 0)"
        
        let itemCost = (totlePaid ?? 0) - (shippingPrices ?? 0)
        lblItemsPrices.text = "US $\(itemCost)"
        lblShippingPrices.text = "US$ \(shippingPrices ?? 0)"
        lblTotlePay.text = "US $\(totlePaid ?? 0)"
        brandNameLBL.text = orderData?.brand?.name ?? ""
        
        
        if orderData?.processStatus == "charged"{
            orderStatusIMG.backgroundColor = .green
        }else if orderData?.processStatus == "processing"{
            orderStatusIMG.backgroundColor = .orange
        }else{
            orderStatusIMG.backgroundColor = .red
        }
        
        if let dateString = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: dateString) {
                self.lblDate.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            }
        }
        
        if let brandRating = orderData?.brandReview?.rating{
            self.brandRatingUV.rating = Double(brandRating)
        }
    }
    
    func cellConfigure(){
        tblOrderDetailList.delegate = self
        tblOrderDetailList.dataSource = self
        tblOrderDetailList.register(UINib(nibName: "OrderDetailTBLCell", bundle: Bundle.module), forCellReuseIdentifier: "OrderDetailTBLCell")
    }
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


    @IBAction func brandRatingClick_Action(_ sender: UIButton) {
        
        if orderData?.processStatus == "charged"{
            if let rating = orderData?.brandReview?.rating{
                self.ratingReview = Double(rating)
            }
            
            let reviewText = orderData?.brandReview?.review ?? ""
            if reviewText != ""{
                self.rateText = reviewText
                self.placeholderLabel.text = ""
            }else{
                self.rateText = ""
                self.placeholderLabel.text = "Type here..."
            }
            
            isBrand = true
            
//            let vc = profileStoryboard.instantiateViewController(withIdentifier: "RatePopupViewController") as! RatePopupViewController
            let vc = RatePopupViewController()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            vc.onDismissBottomSheetClosure = { isDismiss in
                blurredEffectView.removeFromSuperview()
            }
            vc.onDismissWithRateClosure = { strDesc, rateValue in
                blurredEffectView.removeFromSuperview()
                self.ratingReview = rateValue
                self.rateText = strDesc
                self.setRateingView()
            }
            vc.titleName = self.brandNameLBL.text ?? ""
            self.navigationController?.view.addSubview(blurredEffectView)
            self.navigationController?.view.bringSubviewToFront(blurredEffectView)
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.present(vc, animated: true)
        }else{
            self.ShowAlert(title: "Error", message: "Sorry, your order is \(orderData?.processStatus ?? "NA")")
        }
        
    }

}


extension OrderDetailVC: UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrproduct.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblOrderDetailList.dequeueReusableCell(withIdentifier: "OrderDetailTBLCell", for: indexPath) as! OrderDetailTBLCell
        cell.productData = arrproduct[indexPath.row]
        cell.attributeCV.reloadData()
        cell.heightCalculate()
        
        if let rating = arrproduct[indexPath.row].review?.rating{
            cell.ratingUV.rating = Double(rating)
            cell.ratingUV.isHidden = false
            cell.btnRateProduct.setTitle("", for: .normal)
        }else{
            cell.ratingUV.isHidden = true
            cell.btnRateProduct.setTitle("Rate product", for: .normal)
        }
        cell.cellRateProduct = {
            
            guard let orderStatus = self.orderData?.processStatus else {
                self.ShowAlert(title: "Error", message: "Order status unavailable")
                return
            }
            
            if orderStatus != "charged" {
                self.ShowAlert(title: "Error", message: "Sorry, your order is \(orderStatus)")
                return
            }
            
            self.productIndex = indexPath.row
            if let rating = self.arrproduct[indexPath.row].review?.rating{
               // self.reviewStartUV.rating = Double(rating)
                self.ratingReview = Double(rating)
            }else{
               // self.reviewStartUV.rating = 0
                self.ratingReview = 0.0
                cell.ratingUV.isHidden = true
                cell.btnRateProduct.setTitle("Rate product", for: .normal)
               
            }
            
            let reviewText = self.arrproduct[indexPath.row].review?.review ?? ""
            if reviewText != ""{
                self.rateText = reviewText
                self.placeholderLabel.text = ""
            }else{
                self.rateText = ""
                self.placeholderLabel.text = "Type here..."
            }
            
//            let vc = profileStoryboard.instantiateViewController(withIdentifier: "RatePopupViewController") as! RatePopupViewController
            let vc = RatePopupViewController()
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            vc.onDismissBottomSheetClosure = { isDismiss in
                blurredEffectView.removeFromSuperview()
                self.isBrand = false
            }
            vc.onDismissWithRateClosure = { strDesc, rateValue in
                blurredEffectView.removeFromSuperview()
                self.ratingReview = rateValue
                self.rateText = strDesc
                self.setRateingView()
            }
            vc.titleName = self.brandNameLBL.text ?? ""
            self.navigationController?.view.addSubview(blurredEffectView)
            self.navigationController?.view.bringSubviewToFront(blurredEffectView)
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.present(vc, animated: true)
        }
        return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if arrproduct[indexPath.row].sku?.attributes?.count ?? 0 > 0{
//            return 350
//        }else{
//            return 250
//        }
        
        if arrproduct[indexPath.row].sku?.attributes?.count ?? 0 > 0{
            
            let cvWidth = (UIScreen.main.bounds.size.width - 26)
            var rowCount = 1
            if let attARY = arrproduct[indexPath.row].sku?.attributes{
                var itemWidth: Double = 0
                for i in 0..<attARY.count{
                    let name = "\(attARY[i].attributeName ?? "") :"
                    let valuse = " \(attARY[i].name ?? "")"
                    
                    let nameWidth = getTextWidth(text: name, font: .systemFont(ofSize: 13))
                    let valueWidth = getTextWidth(text: valuse, font: .systemFont(ofSize: 13))
                    
                    let nametempwidth = Double(nameWidth + valueWidth)
                    itemWidth = itemWidth + nametempwidth + 10
                    
                    if itemWidth > cvWidth{
                        rowCount = rowCount + 1
                        itemWidth = 0
                    }
                }
            }
            let rowValue = 100 * rowCount
            return CGFloat(250 + rowValue)
        }else{
            return 250
        }
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func getTextWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = NSString(string: text).size(withAttributes: attributes)
        return ceil(textSize.width)
    }
    
    func setRateingView(){
        if isBrand{
            isBrand = false
            if let review = orderData?.brandReview{
                updateReviewtoBrand(reveiwobj: review)
            }else{
                giveReviewtoBrand()
            }
        }else{
            if let review = arrproduct[productIndex].review{
                updateReviewtoProduct(reveiwobj: review)
            }else{
                giveReviewtoProduct()
            }
        }
    }
}

extension OrderDetailVC: UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension OrderDetailVC{
    
    func giveReviewtoProduct(){
        
        let dateString = getCurrentDate()
        let params = ["createdDate": dateString,
                      "productId":arrproduct[productIndex].product?.id ?? 0,
                      "rating":"\(ratingReview)",
                      "review":rateText,
                      "status":"ACTIVE",
                      "userId":UserID,
                      "userName":"\(profileData.value(forKey: "lastName") ?? "NA")"
        ] as [String : Any]
        //print(params)
        start_loading()
        self.post_api_request_withJson("\(BaseURLOffice)reviews/", params: params, headers: headersCommon).responseData { response in
            print(response.result)
            switch response.result {
            case .success:
                self.ratingDelegate?.updateRatingReload()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    func updateReviewtoProduct(reveiwobj:Review){
        
        let dateString = getCurrentDate()
        let params = ["createdDate": dateString,
                      "id":"\(reveiwobj.id ?? 0)",
                      "productId":arrproduct[productIndex].product?.id ?? 0,
                      "rating":"\(ratingReview)",
                      "review":rateText,
                      "status":"ACTIVE",
                      "userId":UserID,
                      "userName":"\(profileData.value(forKey: "lastName") ?? "NA")"
        ] as [String : Any]
        //print(params)
        start_loading()
        self.put_api_request_withJson("\(BaseURLOffice)reviews/\(reveiwobj.id ?? 0)", params: params, headers: headersCommon).responseData { response in
            print(response.result)
            switch response.result {
            case .success:
                self.ratingDelegate?.updateRatingReload()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    func giveReviewtoBrand(){
        
        let dateString = getCurrentDate()
        let params = ["createdDate": dateString,
                      "brandId":orderData?.brand?.id ?? 0,
                      "rating":"\(ratingReview)",
                      "review":rateText,
                      "status":"ACTIVE",
                      "userId":UserID,
                      "userName":"\(profileData.value(forKey: "lastName") ?? "NA")"
        ] as [String : Any]
        //print(params)
        start_loading()
        self.post_api_request_withJson("\(BaseURLOffice)reviews/", params: params, headers: headersCommon).responseData { response in
            print(response.result)
            switch response.result {
            case .success:
                self.ratingDelegate?.updateRatingReload()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    func updateReviewtoBrand(reveiwobj:Review){
        
        let dateString = getCurrentDate()
        let params = ["createdDate": dateString,
                      "id":"\(reveiwobj.id ?? 0)",
                      "brandId":orderData?.brand?.id ?? 0,
                      "rating":"\(ratingReview)",
                      "review":rateText,
                      "status": "ACTIVE",
                      "userId":UserID,
                      "userName":"\(profileData.value(forKey: "lastName") ?? "NA")"
        ] as [String : Any]
        //print(params)
        start_loading()
        self.put_api_request_withJson("\(BaseURLOffice)reviews/\(reveiwobj.id ?? 0)", params: params, headers: headersCommon).responseData { response in
            print(response.result)
            switch response.result {
            case .success:
                self.ratingDelegate?.updateRatingReload()
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    func getCurrentDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC") // Ensure UTC timezone
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
}
