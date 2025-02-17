//
//  OrderListVC.swift
//  
//
//  Created by Jaydip Godhani on 28/01/25.
//

import UIKit
import Alamofire

public class OrderListVC: UIViewController {

    static func storyboardInstance() -> OrderListVC {
        return profileStoryboard.instantiateViewController(withIdentifier: "OrderListVC") as! OrderListVC
    }
    public struct Identifiers {
        static let kStoreTitleCell = "StoreTitleCell"
        static let kOrderListHeaderCell = "OrderListHeaderCell"
        static let kOrderListCell = "OrderListCell"
        static let kOrderStatusCell = "OrderStatusCellj"
        static let kSelectedFilterCell = "SelectedFilterCell"
    }
    @IBOutlet weak var tctfromPrice: UITextField!
    @IBOutlet weak var txtToPrice: UITextField!
    @IBOutlet weak var orderDataTBL: UITableView!
    @IBOutlet weak var periodStackUV: UIStackView!
    @IBOutlet weak var fromDateTF: UITextFieldX!
    @IBOutlet weak var toDateTF: UITextFieldX!
    @IBOutlet weak var searchTF: UITextFieldX!
    @IBOutlet var periodUV: [UIViewX]!
    @IBOutlet weak var filterUV: UIView!
    @IBOutlet weak var storeListCV: UICollectionView!
    @IBOutlet weak var statusCV: UICollectionView!
    @IBOutlet weak var selectedFilterCV: UICollectionView!
    @IBOutlet weak var noOrderLBL: UILabel!
    @IBOutlet weak var selectStatusLBL: UILabel!
    @IBOutlet weak var lblStatusTopConstarint: NSLayoutConstraint!
    @IBOutlet weak var customDateIconHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var customeStackViewHeightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var customStack: UIStackView!
    //    override var shouldAutorotate: Bool {
//        return true
//    }
//
    var orderData : OrderData?
    var searchOrderData : OrderData?
    var storeSelectedIndex = [Int]()
    var stausSelected = ""
    
//    let datePicker = UIDatePicker()
//    let datePicker1 = UIDatePicker()
    
    var customStartDate = ""
    var customeEndDate = ""
    var fminValue: String? = nil
    var fmaxValue:String? = nil
    var fselectedStatus:String? = nil
    var fbrandARY = [Int]()
    var seletedTimePeriod = 0
    
    var statusDic = [String? : [OrderDataModel]]()
    var brandDic = [String? : [OrderDataModel]]()
    var filterARY = NSMutableArray()
    var isFilterApply = false
    var isPriceModifiy = false
    var isSearching = false
    
    
  
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("OrderListVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        // Do any additional setup after loading the view.
        ConfigureTableView()
        GetOrderList()
        priceRangeSetup()
        Configurecollection()
        setupDatePicker()
        
        lblStatusTopConstarint.constant = 50
        customStack.isHidden = true
        customDateIconHeightConstarint.constant = 0
        customeStackViewHeightConstaraint.constant = 0
    }
    
    func updateRatingReload() {
        GetFilterOrderList()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
    }
    func priceRangeSetup(){
        periodStackUV.layer.cornerRadius = 17.5
        periodStackUV.clipsToBounds = true
    }
        
    func setupDatePicker(){
   }
    func Configurecollection(){
        storeListCV.delegate = self
        storeListCV.dataSource = self
        storeListCV.register(UINib(nibName: Identifiers.kStoreTitleCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kStoreTitleCell)
        storeListCV.reloadData()
       
        statusCV.delegate = self
        statusCV.dataSource = self
        statusCV.register(UINib(nibName: Identifiers.kOrderStatusCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kOrderStatusCell)
        statusCV.reloadData()
        
        selectedFilterCV.delegate = self
        selectedFilterCV.dataSource = self
        selectedFilterCV.register(UINib(nibName: Identifiers.kSelectedFilterCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kSelectedFilterCell)
        selectedFilterCV.reloadData()
        
        
    }
    func ConfigureTableView(){
        orderDataTBL.delegate = self
        orderDataTBL.dataSource = self
        orderDataTBL.register(UINib(nibName: Identifiers.kOrderListHeaderCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kOrderListHeaderCell)
        orderDataTBL.register(UINib(nibName: Identifiers.kOrderListCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kOrderListCell)
        //orderDataTBL.separatorStyle = .none
    }
    
    @IBAction func backClick_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func periodClick_Action(_ sender: UIButton) {
        _ = UIColor(red: 148/255, green: 160/255, blue: 167/255, alpha: 1)
        let backgroundColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
        let defaultBackgroundColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 1)
        
        for i in 0..<periodUV.count{
            if periodUV[i].tag == sender.tag{
                periodUV[i].backgroundColor = backgroundColor
                
            }else{
                periodUV[i].backgroundColor = defaultBackgroundColor
                
            }
        }
        
        if sender.tag == 4{
            customStack.isHidden = false
            lblStatusTopConstarint.constant = 150
            customDateIconHeightConstarint.constant = 40
            customeStackViewHeightConstaraint.constant = 100
            seletedTimePeriod = 4
        }else{
            lblStatusTopConstarint.constant = 50
            customStack.isHidden = true
            customDateIconHeightConstarint.constant = 0
            customeStackViewHeightConstaraint.constant = 0
        }
        
        if sender.tag == 0{
            seletedTimePeriod = 0
            customeEndDate = ""
            customStartDate = ""
            
            if isFilterApply{
                GetFilterOrderList()
            }else{
                GetOrderList()
            }
            
        }else if sender.tag == 1{
            seletedTimePeriod = 1
            //customStartDate = getCurrentDate()
            
            let calendar = Calendar.current
            let currentDate = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: currentDate)

            if let startOfDay = calendar.date(from: components) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let startOfDayString = dateFormatter.string(from: startOfDay)
                customStartDate = startOfDayString
            }
            customeEndDate = getCurrentDate()
            GetFilterOrderList()
            
        }else if sender.tag == 2{
            seletedTimePeriod = 2
            customeEndDate = getCurrentDate()
            
            let currentDate = Date()
            let yesterdayDate = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            customStartDate = dateFormatter.string(from: yesterdayDate)
            
            GetFilterOrderList()
        }else if sender.tag == 3{
            seletedTimePeriod = 3
            customeEndDate = getCurrentDate()
            
            let currentDate = Date()
            let yesterdayDate = Calendar.current.date(byAdding: .day, value: -60, to: currentDate)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            customStartDate  = dateFormatter.string(from: yesterdayDate)
            
            GetFilterOrderList()
        }
        
    }
    
    @IBAction func filterClick_Action(_ sender: UIButton) {
        //self.GetOrderList()
        self.filterUV.isHidden = false
        storeListCV.reloadData()
        statusCV.reloadData()
    }
    @IBAction func filterCancelAction(_ sender: Any) {
        filterUV.isHidden = true
//        if searchTF.text!.isEmpty == true{
//            isSearching = false
//        }
    }
    @IBAction func applyCustomClic_Action(_ sender: UIButtonX) {
        GetFilterOrderList()
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
       // fromDateTF.text = dateFormatter.string(from: datePicker.date)
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      //  customStartDate = dateFormatter1.string(from: datePicker.date)
    }
    
    @objc func todoneButtonTapped() {
        view.endEditing(true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
     //   toDateTF.text = dateFormatter.string(from: datePicker1.date)
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      //  customeEndDate = dateFormatter1.string(from: datePicker1.date)
    }
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)

        return formattedDate
    }
    func getStatusList(){
        statusDic = Dictionary(grouping: orderData!, by: { $0.processStatus })
        print(statusDic.count)
        
        
        let sortedOrders = sortOrdersByDateAscending(orders: orderData!)
        sortedOrders.forEach { order in
            print("Date: \(order.date ?? "N/A")")
        }
        orderData = sortedOrders
        statusCV.reloadData()
//        for (processStatus, models) in groupedByStatus {
//            print("Status: \(processStatus), Models: \(models)")
//        }
    }
    
    func sortOrdersByDateAscending(orders: OrderData) -> OrderData{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return orders.sorted { order1, order2 in
            guard let dateString1 = order1.date,
                  let dateString2 = order2.date,
                  let date1 = dateFormatter.date(from: dateString1),
                  let date2 = dateFormatter.date(from: dateString2) else {
                      return false
                  }
            return date1 > date2
            
        }
    }
    func filterBrandBystatus(){
        let filteredArray = orderData!.filter { $0.processStatus == stausSelected }
        brandDic = Dictionary(grouping: filteredArray, by: { $0.brand?.name })
        storeSelectedIndex.removeAll()
        selectStatusLBL.isHidden = true
        storeListCV.reloadData()
    }
    @IBAction func applyFilterClick_Action(_ sender: UIButton) {
        filterARY.removeAllObjects()
               fbrandARY.removeAll()
               if stausSelected != ""{
                   fselectedStatus = stausSelected
                   let tempDic = NSMutableDictionary()
                   tempDic["title"] = "status"
                   tempDic["value"] = stausSelected
                   filterARY.add(tempDic)
               }
               for i in 0..<storeSelectedIndex.count{
                   let index = storeSelectedIndex[i]
                   let objectARY = Array(brandDic.keys)[index]
                   if let models = brandDic[objectARY] {
                       let model = models[0]
                       let tempDic = NSMutableDictionary()
                       tempDic["title"] = "store"
                       tempDic["id"] = model.brand?.id ?? 0
                       tempDic["value"] = model.brand?.name ?? ""
                       filterARY.add(tempDic)
                       fbrandARY.append(model.brand?.id ?? 0)
                   }
               }
               if isPriceModifiy {
                   let priceRange = "\(tctfromPrice.text!) - \(txtToPrice.text!)"
                   let tempDic = NSMutableDictionary()
                   tempDic["title"] = "price"
                   tempDic["value"] = priceRange
                   filterARY.add(tempDic)
                   
                   let minString = "\(tctfromPrice.text!)"
                   fminValue = String(minString.dropFirst())
                   let maxString = "\(txtToPrice.text!)"
                   fmaxValue = String(maxString.dropFirst())
               }
               
               selectedFilterCV.reloadData()
               filterUV.isHidden = true
               if filterARY.count > 0{
                   isFilterApply = true
               }
        
        if searchTF.text!.isEmpty == true{
            isSearching = false
        }
        
        if seletedTimePeriod == 0{
            if isFilterApply{
                GetFilterOrderList()
            }else{
                GetOrderList()
            }
        }else{
            GetFilterOrderList()
        }
               

    }
    
    @objc func searcButtonTapped() {
        view.endEditing(true)
        if searchTF.text!.isEmpty == true{
            isSearching = false
            orderDataTBL.reloadData()
        }
    }
    func updateSearchResults(for query: String) {
        searchOrderData = orderFilterObjects(with: query)
        isSearching = true
        orderDataTBL.reloadData()
        
        // Reload your UI or update it accordingly
    }
    func orderFilterObjects(with query: String) -> [OrderDataModel] {
        return orderData!.filter { order in
            if let number = order.number {
                let numberString = String(number)
                return numberString.range(of: query) != nil
            }
            return false
        }
    }
}
extension OrderListVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == storeListCV{
            return  brandDic.count
        }else if collectionView == statusCV{
            return  statusDic.count
        }else{
            return filterARY.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == storeListCV{
            let cell = storeListCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kStoreTitleCell, for: indexPath) as! StoreTitleCell
            cell.index = indexPath.row
            let objectARY = Array(brandDic.keys)[indexPath.row]
            if let models = brandDic[objectARY] {
                let model = models[0]
                cell.storeNameLBL.text = model.brand?.name ?? ""
            }
            let textColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
            
            if storeSelectedIndex.contains(indexPath.row) {
                cell.storeNameLBL.textColor = textColor
            } else {
                cell.storeNameLBL.textColor = UIColor.white
            }
            
            cell.storAction = { index in
                if self.storeSelectedIndex.count > 0 {
                    if let indexFound = self.storeSelectedIndex.firstIndex(of: index) {
                        self.storeSelectedIndex.remove(at: indexFound)
                    } else {
                        self.storeSelectedIndex.append(index)
                    }
                } else {
                    self.storeSelectedIndex.append(index)
                }
                self.storeListCV.reloadData()
            }
            cell.layoutIfNeeded()
            return cell
        }else if collectionView == statusCV{
            let cell = statusCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kOrderStatusCell, for: indexPath) as! OrderStatusCellj
            
            let objectARY = Array(statusDic.keys)[indexPath.row]
            cell.statusName.text = objectARY
            cell.index = indexPath.row
            
            if objectARY == "charged"{
                cell.dotUV.backgroundColor = UIColor.green
            }else{
                cell.dotUV.backgroundColor = UIColor.red
            }
            
            let borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
            if stausSelected == objectARY {
//                cell.backUV.borderColor = borderColor
                cell.backUV.layer.borderWidth = 1.0
                cell.backUV.layer.borderColor = borderColor.cgColor
                
            } else {
//                cell.backUV.borderColor = UIColor.clear
                cell.backUV.layer.borderWidth = 1.0
                cell.backUV.layer.borderColor = UIColor.clear.cgColor
            }
            
            cell.statusAction = { index in
                let objectARY = Array(self.statusDic.keys)[index]
                self.stausSelected = objectARY!
                self.statusCV.reloadData()
                self.filterBrandBystatus()
            }
            
            return cell
        }else{
            let cell = selectedFilterCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kSelectedFilterCell, for: indexPath) as! SelectedFilterCell
            let tempDic = filterARY.object(at: indexPath.row) as! NSDictionary
            cell.itemNameLBL.text = "\(tempDic.value(forKey: "value")!)"
            cell.closeAction = {
                let removeItem = "\(tempDic.value(forKey: "title")!)"
                if removeItem == "status"{
                    self.fselectedStatus = nil
                    self.stausSelected = ""
                }else if removeItem == "price"{
                    self.fminValue = nil
                    self.fmaxValue = nil
                }else{
                    let removeStoreId = Int("\(tempDic.value(forKey: "id")!)")
                    if let indexFound = self.fbrandARY.firstIndex(of: removeStoreId!) {
                        self.fbrandARY.remove(at: indexFound)
                    } else {
                        self.fbrandARY.append(indexPath.row)
                    }
                    
                    if let index = self.storeSelectedIndex.firstIndex(where: { index in
                        let objectARY = Array(self.brandDic.keys)[index]
                        if let models = self.brandDic[objectARY], let model = models.first {
                            return model.brand?.id == removeStoreId
                        }
                        return false
                    }) {
                        self.storeSelectedIndex.remove(at: index)
                    }
                    
                }
                self.filterARY.removeObject(at: indexPath.row)
                DispatchQueue.main.async {
                    self.selectedFilterCV.reloadData()
                    if self.filterARY.count > 0{
                    let indexPath = IndexPath(item: 0, section: 0)
                    self.selectedFilterCV.scrollToItem(at: indexPath, at: .top, animated: true)
                    }
                }
                
                self.GetFilterOrderList()
            }
            return cell
        }
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == storeListCV{
            if storeSelectedIndex.count > 0 {
                if let indexFound = storeSelectedIndex.firstIndex(of: indexPath.row) {
                    storeSelectedIndex.remove(at: indexFound)
                } else {
                    storeSelectedIndex.append(indexPath.row)
                }
            } else {
                storeSelectedIndex.append(indexPath.row)
            }
            storeListCV.reloadData()
        }else if collectionView == statusCV{
            let objectARY = Array(statusDic.keys)[indexPath.row]
            stausSelected = objectARY!
            statusCV.reloadData()
            filterBrandBystatus()
            
        }else{
            
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == storeListCV{
            let cell = storeListCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kStoreTitleCell, for: indexPath) as! StoreTitleCell
            
            let objectARY = Array(brandDic.keys)[indexPath.row]
            if let models = brandDic[objectARY] {
                let model = models[0]
                cell.storeNameLBL.text = model.brand?.name ?? ""
            }
            let labelWidth = cell.storeNameLBL.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: cell.storeNameLBL.frame.height)).width
            let padding: CGFloat = 16.0
            
            return CGSize(width: labelWidth + padding , height: 40)
        }else if collectionView == statusCV{
            
            let cell = statusCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kOrderStatusCell, for: indexPath) as! OrderStatusCellj
            
            let objectARY = Array(statusDic.keys)[indexPath.row]
            cell.statusName.text = objectARY
            
            let labelWidth = cell.statusName.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: cell.statusName.frame.height)).width
            let padding: CGFloat = 45.0
            
            return CGSize(width: labelWidth + padding , height: 40)
        }else{
            
            let cell = selectedFilterCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kSelectedFilterCell, for: indexPath) as! SelectedFilterCell
            let tempDic = filterARY.object(at: indexPath.row) as! NSDictionary
            cell.itemNameLBL.text = "\(tempDic.value(forKey: "value")!)"
            
            let labelWidth = cell.itemNameLBL.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: cell.itemNameLBL.frame.height)).width
            let padding: CGFloat = 45.0
            
            return CGSize(width: labelWidth + padding , height: 80)
        }
    }

}
//MARK: - TextFiald Delegate Methods
extension OrderListVC: UITextFieldDelegate{
    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == fromDateTF {
//            datePicker.date = Date()
//            datePicker.maximumDate = Date()
//        }else if textField == toDateTF{
//            datePicker1.date = Date() // Set initial date if needed
//            datePicker1.maximumDate = Date()
//        }
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == searchTF {
            let currentText = (searchTF.text ?? "") + string
            updateSearchResults(for: currentText)
            return true
        }
        return true
    }
    
}

//extension OrderListVC: RangeSeekSliderDelegate {
//
//    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
//        if slider === priceSliderUV {
//            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
//            self.tctfromPrice.text = "$\(Int(round(minValue)))"
//            self.txtToPrice.text = "$\(Int(round(maxValue)))"
//            self.isPriceModifiy = true
//        }
//    }
//
//    func didStartTouches(in slider: RangeSeekSlider) {
//        print("did start touches")
//    }
//
//    func didEndTouches(in slider: RangeSeekSlider) {
//        print("did end touches")
//    }
//}

extension OrderListVC : UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = orderDataTBL.dequeueReusableCell(withIdentifier: Identifiers.kOrderListHeaderCell) as! OrderListHeaderCell
        return headerCell
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchOrderData?.count ?? 0 : orderData?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orderDataTBL.dequeueReusableCell(withIdentifier: Identifiers.kOrderListCell, for: indexPath) as! OrderListCell
        cell.selectionStyle = .none
        cell.index = indexPath.row
        if isSearching {
            if searchOrderData == nil {
                return cell
            }
        } else {
            if orderData == nil {
                return cell
            }
        }
        let tempOrderData = isSearching ? searchOrderData?[indexPath.row] : orderData?[indexPath.row]
        cell.orderNOLBL.text = "# \(tempOrderData?.number ?? 0)"
        
        let dateString = "\(tempOrderData?.date ?? "")"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            if let year = components.year, let day = components.day {
                let monthName = calendar.monthSymbols[calendar.component(.month, from: date) - 1]

                cell.orderDateLBL.text = "\(day) \(monthName) \(year)"
            }
        }
       // cell.orderStatusLBL.text = tempOrderData?.processStatus ?? ""
        var totalCount = 0
        for i in 0..<tempOrderData!.products!.count{
            totalCount += tempOrderData?.products?[i].count ?? 0
            
        }
        cell.totalPurchaseLBL.text = "$\(tempOrderData?.total ?? 0) for \(totalCount) items"
        
        if isiPhoneSE() {
            cell.orderNOLBL.font = UIFont.systemFont(ofSize: 28)
            cell.orderDateLBL.font = UIFont.systemFont(ofSize: 28)
            cell.totalPurchaseLBL.font = UIFont.systemFont(ofSize: 28)
        } else {
            cell.orderNOLBL.font = UIFont.systemFont(ofSize: 30)
            cell.orderDateLBL.font = UIFont.systemFont(ofSize: 30)
            cell.totalPurchaseLBL.font = UIFont.systemFont(ofSize: 30)
        }
    
       // cell.storeLBL.text = tempOrderData?.brand?.name ?? ""
        
//        if tempOrderData?.processStatus == "charged"{
//            cell.statusDotIMG.backgroundColor = .green
//        }else if tempOrderData?.processStatus == "processing"{
//            cell.statusDotIMG.backgroundColor = .orange
//        }else{
//            cell.statusDotIMG.backgroundColor = .red
//        }

        cell.selectionAction = {index in
//            let vc = profileStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
            let vc = OrderDetailVC()
            let tempOrderData = self.isSearching ? self.searchOrderData?[index] : self.orderData?[index]
            vc.arrproduct = (tempOrderData?.products)!
            vc.orderId = tempOrderData?.id
            vc.status = tempOrderData?.processStatus ?? ""
            vc.date = tempOrderData?.date ?? ""
            vc.totlePaid = tempOrderData?.total
            vc.shippingPrices = tempOrderData?.shippingTotal
            vc.orderData = tempOrderData
            //vc.ratingDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = profileStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        let vc = OrderDetailVC()
       // vc.modalPresentationStyle = .custom
        let tempOrderData = isSearching ? searchOrderData?[indexPath.row] : orderData?[indexPath.row]
        //isSearching ? searchOrderData?.count ?? 0 : orderData?.count ?? 0
        
        vc.arrproduct = (tempOrderData?.products)!
        vc.orderId = tempOrderData?.id
        vc.status = tempOrderData?.processStatus ?? ""
        vc.date = tempOrderData?.date ?? ""
        vc.totlePaid = tempOrderData?.total
        vc.shippingPrices = tempOrderData?.shippingTotal
        vc.orderData = tempOrderData
        //vc.ratingDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}

extension OrderListVC{
    
    func GetOrderList(){
        
        start_loading()
        self.get_api_request("\(BaseURLOffice)order/\(UserID)/all", headers: headersCommon).responseDecodable(of: OrderData.self) { response in
            //print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(OrderData.self, from: responseData)
                        self.orderData = welcome
                        if self.orderData?.count ?? 0 > 0{
                            self.orderDataTBL.isHidden = false
                            self.orderDataTBL.reloadData()
                            self.noOrderLBL.isHidden = true
                            self.getStatusList()
                        }else{
                            self.orderDataTBL.isHidden = true
                            self.noOrderLBL.isHidden = false
                        }
                        
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
    
    func GetFilterOrderList(){

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        // Convert the string to Date
        if let date = dateFormatter.date(from: fromDateTF.text ?? "") {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            customStartDate = dateFormatter1.string(from: date)
        } else {
            debugPrint("Invalid date format.")
        }

        
        if let endDate = dateFormatter.date(from: toDateTF.text ?? "") {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            customeEndDate = dateFormatter1.string(from: endDate)
        } else {
            debugPrint("Invalid date format.")
        }
        
        
        
        var params = [String : Any]()
        
        if isFilterApply{
            params["endDate"] = customeEndDate
            params["startDate"] = customStartDate
            
            if fminValue != nil{
                params["minAmount"] = fminValue!
                params["maxAmount"] = fmaxValue!
            }
            
            
            if fselectedStatus != nil{
                params["status"] = fselectedStatus!
            }
            
            if fbrandARY.count > 0{
                params["brands"] = fbrandARY
            }
        }else{
            params = ["endDate":customeEndDate,
                      "startDate":customStartDate
            ]
        }
        
        debugPrint("order list oooo ---> 2222", params)
        
        start_loading()
        self.post_api_request_withJson("\(BaseURLOffice)order/\(UserID)/all", params: params, headers: headersCommon).responseDecodable(of: OrderData.self) { response in
            //print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(OrderData.self, from: responseData)
                        self.orderData = welcome
                        if self.orderData!.count > 0{
                            self.orderDataTBL.isHidden = false
                            self.orderDataTBL.reloadData()
                            self.noOrderLBL.isHidden = true
                            self.getStatusList()
                        }else{
                            self.statusDic.removeAll()
                            self.statusCV.reloadData()
                            self.orderDataTBL.isHidden = true
                            self.noOrderLBL.isHidden = false
                        }
                       
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


