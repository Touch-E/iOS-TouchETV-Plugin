//
//  MyCartVC.swift
//  
//
//  Created by Parth on 27/01/25.
//

import UIKit
public class MyCartVC: UIViewController {
    
    static func storyboardInstance() -> MyCartVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "MyCartVC") as! MyCartVC
    }

    @IBOutlet weak var totalItemTitleLBL: UILabel!
    @IBOutlet weak var itemPriceLBL: UILabel!
    @IBOutlet weak var shippingfeeLBL: UILabel!
    @IBOutlet weak var checkOutBTN: UIButtonX!
    @IBOutlet weak var cartDataTBL: UITableView!
    @IBOutlet weak var noDataAvlbLBL: UILabel!
    @IBOutlet weak var shippingCartLBL: UILabel!
    
    public struct Identifiers {
        static let kCartSectionCell = "CartSectionCell"
        static let kCartItemCell = "CartItemCell"
        
    }
    var addressListData : AddressData?
    var cartData : CartData?
    var customDataARY = NSMutableArray()
    var jsonResponseARY = NSMutableArray()
    var selectedCartDataID: [Int] = []
    
    var totalCost = 0
    var itemTotalPrice = 0
    var shippingCost = 0
    var totalItemSelect = 0
    var expandCellIndex = -1
    var expandCellSection = -1
    var isCellExpanded = false
    var isfromVideo = false

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let view = Bundle.module.loadNibNamed("MyCartVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
       // self.customDataARY.removeAllObjects()
        GetCartDetail()
        ConfigureTableView()
        GetAddressList()
    }
    public override func viewWillAppear(_ animated: Bool) {
       
      
    }
    @IBAction func closeClick_Action(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        if isfromVideo{
            rotate_flag = true
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    func ConfigureTableView(){
        cartDataTBL.delegate = self
        cartDataTBL.dataSource = self
        cartDataTBL.register(UINib(nibName: Identifiers.kCartSectionCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCartSectionCell)
        cartDataTBL.register(UINib(nibName: Identifiers.kCartItemCell, bundle: Bundle.module), forCellReuseIdentifier: Identifiers.kCartItemCell)

        cartDataTBL.contentInsetAdjustmentBehavior = .never
        cartDataTBL.insetsContentViewsToSafeArea = false
        cartDataTBL.insetsLayoutMarginsFromSafeArea = false
        cartDataTBL.preservesSuperviewLayoutMargins = false
        
    }
    @IBAction func btnProceedToCheckout(_ sender: UIButtonX) {
        let dic = profileData
        let fname = "\(dic.value(forKey: "firstName") ?? "NA")"
        let lname = "\(dic.value(forKey: "lastName") ?? "NA")"
        
        if addressListData?.count == nil || addressListData?.count == 0{
            self.ShowAlert(title: "Error", message: "No shipping address is provided. Go to My Profile > Addresses to add one.")
        } else if fname == "<null>" || lname == "<null>"{
            self.ShowAlert(title: "Error", message: "Please complete profile details.")
        } else {
            self.totalCostCalculate()
            if selectedCartDataID.count > 0{
                let vc = CheckOutVC()
                vc.modalPresentationStyle = .custom
                vc.selectedCartDataId = selectedCartDataID
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.ShowAlert(title: "Error", message: "Please select product for checkout!")
            }
        }
    }
    func customArrayCreate(){
        for i in 0..<self.cartData!.count{
            var isUpdate = false
            let brandName = self.cartData?[i].product?.brandName ?? ""
            let qtyCount = self.cartData?[i].count ?? 0
            var addShippingIndex = ""
            let selectShippingId = self.cartData?[i].shipping?.id ?? 0
            for j in 0..<(self.cartData?[i].product?.shippings?.count)!{
                let shippingid = self.cartData?[i].product?.shippings?[j].id ?? 0
                if shippingid == selectShippingId{
                    addShippingIndex = "\(j)"
                }
            }
            
            if self.customDataARY.count > 0{
                for k in 0..<self.customDataARY.count{
                    
                    let tempdic = self.customDataARY.object(at: k) as! NSDictionary
                    let customBrand = "\(tempdic.value(forKey: "brandName")!)"
                    if customBrand == brandName{
                        let currentARY = tempdic.value(forKey: "productsARY") as! NSMutableArray
                        let ProductDic = NSMutableDictionary()
                        ProductDic["products"] = self.cartData?[i]
                        ProductDic["isSelected"] = "0"
                        ProductDic["shippingCost"] = addShippingIndex
                        ProductDic["qty"] = "\(qtyCount)"
                        currentARY.add(ProductDic)
                        
                        let tempdic = NSMutableDictionary()
                        tempdic["isAllSelect"] = "0"
                        tempdic["brandName"] = customBrand
                        tempdic["productsARY"] = currentARY
                        self.customDataARY.replaceObject(at: k, with: tempdic)
                        isUpdate = true
                    }
                }
                if isUpdate == false{
                    let tempdic = NSMutableDictionary()
                    tempdic["isAllSelect"] = "0"
                    tempdic["brandName"] = brandName
                    
                    let ProductDic = NSMutableDictionary()
                    ProductDic["products"] = self.cartData?[i]
                    ProductDic["isSelected"] = "0"
                    ProductDic["shippingCost"] = addShippingIndex
                    ProductDic["qty"] = "\(qtyCount)"
                    
                    let productARY = NSMutableArray()
                    productARY.add(ProductDic)
                    
                    tempdic["productsARY"] = productARY
                    self.customDataARY.add(tempdic)
                }
            }else{
                let tempdic = NSMutableDictionary()
                tempdic["isAllSelect"] = "0"
                tempdic["brandName"] = brandName
                
                let ProductDic = NSMutableDictionary()
                ProductDic["products"] = self.cartData?[i]
                ProductDic["isSelected"] = "0"
                ProductDic["shippingCost"] = addShippingIndex
                ProductDic["qty"] = "\(qtyCount)"
                
                let productARY = NSMutableArray()
                productARY.add(ProductDic)
                
                tempdic["productsARY"] = productARY
                self.customDataARY.add(tempdic)
                
            }
            
        }
        print(self.customDataARY)
        self.cartDataTBL.reloadData()
       // self.cartDataTBL.layoutIfNeeded()
    }
    
    func totalCostCalculate(){
         totalCost = 0
         itemTotalPrice = 0
         shippingCost = 0
         totalItemSelect = 0
         selectedCartDataID.removeAll()
        
        for i in 0..<self.customDataARY.count{
            
            let currentDic = self.customDataARY.object(at: i) as! NSDictionary
            let dataARY = currentDic.value(forKey: "productsARY") as! NSMutableArray
            
            for k in 0..<dataARY.count{
                let productDic = dataARY.object(at: k) as! NSMutableDictionary
                if productDic.value(forKey: "isSelected") as! String == "1"{
                    let cartTempData = productDic.value(forKey: "products") as! CartDataModel
                    let price = cartTempData.sku?.price ?? 0
                    let qty = Int(productDic.value(forKey: "qty") as! String) ?? 0
                    let itemCost = price * qty
                    itemTotalPrice += itemCost
                    
                    var shippingARY :[Shipping]?
                    shippingARY = cartTempData.product?.shippings
                    let shippingIndex = Int(productDic.value(forKey: "shippingCost") as! String) ?? 0
                    let shippingPrice = shippingARY?[shippingIndex].price ?? 0
                    
                    shippingCost += shippingPrice
                    totalCost = itemTotalPrice + shippingCost
                    totalItemSelect += 1
                    
                    selectedCartDataID.append(cartTempData.id ?? 0)
                }
                
            }
           
        }
        
        itemPriceLBL.text = "US $\(itemTotalPrice)"
        shippingfeeLBL.text = "US $\(shippingCost)"
        totalItemTitleLBL.text = "Items (\(totalItemSelect))"
        checkOutBTN.setTitle("Pay $\(totalCost) USD", for: .normal)
        print(customDataARY.count)
        cartDataTBL.isHidden = customDataARY.count > 0 ? false : true
        noDataAvlbLBL.isHidden = customDataARY.count > 0 ? true : false
       // cartDataTBL.reloadData() //anb last commet
    }
}
extension MyCartVC : UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.customDataARY.count //+ 1
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = cartDataTBL.dequeueReusableCell(withIdentifier: Identifiers.kCartSectionCell) as! CartSectionCell
        
        headerCell.layoutMargins = UIEdgeInsets.zero
        headerCell.preservesSuperviewLayoutMargins = false
        if section != self.customDataARY.count{
            let currentDic = self.customDataARY.object(at: section) as! NSDictionary
            headerCell.brandNameLBL.text = "\(currentDic.value(forKey: "brandName")!)"
            
            if currentDic.value(forKey: "isAllSelect") as! String == "0"{
                headerCell.checkIMG.image = UIImage(named: "check-box-empty", in: Bundle.module, with: nil)
            }else{
                headerCell.checkIMG.image = UIImage(named: "check-box", in: Bundle.module, with: nil)
            }
            headerCell.brandSelectChange = { status in
                if status{
                   headerCell.checkIMG.image = UIImage(named: "check-box", in: Bundle.module, with: nil)
                    currentDic.setValue("1", forKey: "isAllSelect")
                    let dataARY = currentDic.value(forKey: "productsARY") as! NSMutableArray
                    for i in 0..<dataARY.count{
                        let productDic = dataARY.object(at: i) as! NSMutableDictionary
                        productDic.setValue("1", forKey: "isSelected")
                        dataARY.replaceObject(at: i, with: productDic)
                        currentDic.setValue(dataARY, forKey: "productsARY")
                        self.customDataARY.replaceObject(at: section, with: currentDic)
                    }
                    self.totalCostCalculate()
                    self.cartDataTBL.reloadData()
                    
                    
                }else{
                    headerCell.checkIMG.image = UIImage(named: "check-box-empty", in: Bundle.module, with: nil)
                    currentDic.setValue("0", forKey: "isAllSelect")
                    //self.customDataARY.replaceObject(at: section, with: currentDic)
                    
                    let dataARY = currentDic.value(forKey: "productsARY") as! NSMutableArray
                    for i in 0..<dataARY.count{
                        let productDic = dataARY.object(at: i) as! NSMutableDictionary
                        productDic.setValue("0", forKey: "isSelected")
                        dataARY.replaceObject(at: i, with: productDic)
                        currentDic.setValue(dataARY, forKey: "productsARY")
                        self.customDataARY.replaceObject(at: section, with: currentDic)
                    }
                    self.totalCostCalculate()
                    self.cartDataTBL.reloadData()
                }
                
            }
            
        }else{
            headerCell.checkBTN.setImage(UIImage(named: "ic_mycart", in: Bundle.module, with: nil), for: .normal)
            headerCell.brandNameLBL.text = "Order summary"
        }
        
        return headerCell.contentView
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != self.customDataARY.count{
            let currentDic = self.customDataARY.object(at: section) as! NSMutableDictionary
            let dataARY = currentDic.value(forKey: "productsARY") as! NSArray
            return dataARY.count
        }else{
            return 1
        }
        
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = cartDataTBL.dequeueReusableCell(withIdentifier: Identifiers.kCartItemCell, for: indexPath) as! CartItemCell
        cell.selectionStyle = .none
        let currentDic = self.customDataARY.object(at: indexPath.section) as! NSDictionary
        let dataARY = currentDic.value(forKey: "productsARY") as! NSMutableArray
        
        let productDic = dataARY.object(at: indexPath.row) as! NSMutableDictionary
        let cartTempData = productDic.value(forKey: "products") as! CartDataModel
        cell.nameLBL.text = cartTempData.product?.name
        cell.skuLBL.text = "SKU:\(cartTempData.sku?.sku ?? "")"
        cell.attributeARY = cartTempData.sku?.attributes
        cell.attributeCV.reloadData()
        cell.heightCalculate()
        
        if cartTempData.product?.shippings!.count ?? 0 > 0{
            let shippingIndex = Int(productDic.value(forKey: "shippingCost") as! String) ?? 0
            let shippingName = cartTempData.product?.shippings?[shippingIndex].name
            let price = cartTempData.product?.shippings?[shippingIndex].price ?? 0
            cell.shippingTF.text = "\(shippingName!) - $\(price)"
        }else{
            cell.shippingTF.text = " Free Shipping"
        }
        
        let image = cartTempData.product?.images?[0].url ?? ""
        if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // Use the encoded URL string
            print(encodedUrlString)
            cell.productIMG.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
            cell.productIMG.contentMode = .scaleAspectFill
        } else {
            // Handle the case where encoding fails
            print("Failed to encode URL string")
        }
        
        cell.shippingARY = cartTempData.product?.shippings
        
        let price = cartTempData.sku?.price ?? 0
        let qty = Int(productDic.value(forKey: "qty") as! String) ?? 0
        let itemCost = price * qty
        cell.qtyLBL.text = "\(productDic.value(forKey: "qty")!)"
        cell.priceLBL.text = "US $\(itemCost)"
        
        cell.qtyChange = { result in
            var qtyValue = Int("\(cell.qtyLBL.text!)") ?? 0
            let stockCount = cartTempData.sku?.stock ?? 0
            if result{
                qtyValue += 1
            }else{
                if qtyValue != 1{
                    qtyValue -= 1
                }
            }
            if qtyValue > stockCount{
                let sku = "SKU:\(cartTempData.sku?.sku ?? "")"
                self.ShowAlert(title: "Error", message: "Order quantity exceeds stock for product \(sku)")
            }else{
                let shippingIndex = Int(productDic.value(forKey: "shippingCost") as! String) ?? 0
                self.addToCart(shippingaddress: shippingIndex, count: qtyValue, dic: productDic, selectItem: cartTempData, completion: { (success) -> Void in
                    if success {
                        if qtyValue != 0{
                            cell.qtyLBL.text = "\(qtyValue)"
                            productDic.setValue("\(qtyValue)", forKey: "qty")
                            dataARY.replaceObject(at: indexPath.row, with: productDic)
                            currentDic.setValue(dataARY, forKey: "productsARY")
                            self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                            self.totalCostCalculate()
                        }else{
                            
                            dataARY.removeObject(at: indexPath.row)//replaceObject(at: indexPath.row, with: productDic)
                            currentDic.setValue(dataARY, forKey: "productsARY")
                            self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                            self.totalCostCalculate()
                        }
                        
                    }
                })
            }
        }
        
        cell.removeItem = {
            self.deleteCartItem(dic: productDic, selectItem: cartTempData, completion: { (success) -> Void in
                if success {
                    if dataARY.count != 1{
                        dataARY.removeObject(at: indexPath.row)//replaceObject(at: indexPath.row, with: productDic)
                        currentDic.setValue(dataARY, forKey: "productsARY")
                        self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                        self.totalCostCalculate()
                        self.cartDataTBL.reloadData()
                    }else{
                        self.customDataARY.removeObject(at: indexPath.section)
                        self.totalCostCalculate()
                        self.cartDataTBL.reloadData()
                    }
                    
                }
            })
        }
        
        
        if currentDic.value(forKey: "isAllSelect") as! String == "0"{
            if productDic.value(forKey: "isSelected") as! String == "0"{
               cell.checkIMG.image = UIImage(named: "check-box-empty", in: Bundle.module, with: nil)
                
            }else{
               cell.checkIMG.image = UIImage(named: "check-box", in: Bundle.module, with: nil)
            }
        }else{
            cell.checkIMG.image = UIImage(named: "check-box", in: Bundle.module, with: nil)
        }
        
        
        cell.productSelectChange = { status in
            if status{
               cell.checkIMG.image = UIImage(named: "check-box", in: Bundle.module, with: nil)
                productDic.setValue("1", forKey: "isSelected")
                dataARY.replaceObject(at: indexPath.row, with: productDic)
                currentDic.setValue(dataARY, forKey: "productsARY")
                self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                
            }else{
                cell.checkIMG.image = UIImage(named: "check-box-empty", in: Bundle.module, with: nil)
                productDic.setValue("0", forKey: "isSelected")
                dataARY.replaceObject(at: indexPath.row, with: productDic)
                currentDic.setValue(dataARY, forKey: "productsARY")
                self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                
            }
            self.totalCostCalculate()
        }
        
        if indexPath.row == dataARY.count - 1{
            cell.backUV.layer.cornerRadius = 10
            cell.backUV.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.cellExpand = {
            self.expandCellIndex = indexPath.row
            self.expandCellSection = indexPath.section
            self.isCellExpanded.toggle()
            self.cartDataTBL.reloadData()
            //self.cartDataTBL.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.selectShippping = {
            
            let tempARY = cartTempData.product?.shippings
            var dataSource = [String]()
            
            if let shippings = tempARY {
                for i in 0..<shippings.count {
                    let shippingName = shippings[i].name
                    let price = shippings[i].price ?? 0
                    let shippingItem = "\(shippingName!) - $\(price)"
                    dataSource.append("\(shippingItem)")
                }
                self.presentPicker(
                    title: "Please Select Shipping Type!",
                    subtitle: "",
                    dataSource: dataSource,
                    initialSelection: 0,
                    onSelectItem: { item, index in
                        let shippingName = shippings[index].name
                        let price = shippings[index].price ?? 0
                        cell.shippingTF.text = "\(shippingName!) - $\(price)"
                        productDic.setValue("\(index)", forKey: "shippingCost")
                        dataARY.replaceObject(at: indexPath.row, with: productDic)
                        currentDic.setValue(dataARY, forKey: "productsARY")
                        self.customDataARY.replaceObject(at: indexPath.section, with: currentDic)
                        let qtyValue = Int(productDic.value(forKey: "qty") as! String) ?? 0
                        self.addToCart(shippingaddress: index, count: qtyValue, dic: productDic, selectItem: cartTempData, completion: { (success) -> Void in
                            if success {
                                self.totalCostCalculate()
                                print("shippingChange")
                            }
                        })
                    })
            }
            
        }
        return cell

    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentDic = self.customDataARY.object(at: indexPath.section) as! NSDictionary
        let dataARY = currentDic.value(forKey: "productsARY") as! NSMutableArray
        let productDic = dataARY.object(at: indexPath.row) as! NSMutableDictionary
        let cartTempData = productDic.value(forKey: "products") as! CartDataModel
        
        if cartTempData.sku?.attributes?.count ?? 0 > 0{
            return 460
        }else{
            return 380
        }
    }
    
    func getTextWidth(text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = NSString(string: text).size(withAttributes: attributes)
        return ceil(textSize.width)
    }
    
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension MyCartVC {
    func GetCartDetail(){
        start_loading()
        self.get_api_request("\(BaseURLOffice)cart/users/\(UserID)/products\(loadContents)", headers: headersCommon).responseDecodable(of: CartData.self) { response in
           // print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(CartData.self, from: responseData)
                        self.cartData = welcome
                        self.shippingCartLBL.text = "Shopping Cart (\(self.cartData?.count ?? 0))"
                        if self.cartData?.count ?? 0 > 0{
                            self.cartDataTBL.isHidden = false
                            self.noDataAvlbLBL.isHidden = true
                        }else{
                            self.cartDataTBL.isHidden = true
                            self.noDataAvlbLBL.isHidden = false
                        }
                        self.customArrayCreate()
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
    
    func addToCart(shippingaddress: Int, count: Int, dic: NSMutableDictionary ,selectItem:CartDataModel,completion: @escaping (Bool) -> Void){
        let personDict = convertToDictionary(selectItem.product)
        let skuDict = convertToDictionary(selectItem.sku)
        let shippingDict = convertToDictionary(selectItem.product?.shippings?[shippingaddress])
    
        
        let params = [
                       "count":"\(count)",
                       "id":"\(selectItem.id ?? 0)",
                       "price":"\(selectItem.sku?.price ?? 0)",
                       "product":personDict!,
                       "shipping":shippingDict!,
                       "projectId":projectID,
                       "agreement":1,
                       "sku":skuDict!,
                       "total":"\(selectItem.sku?.price ?? 0)"
        ] as [String : Any]
        start_loading()
        self.put_api_request_withJson("\(BaseURLOffice)cart/users/\(UserID)/products/\(selectItem.id ?? 0)", params: params, headers: headersCommon).responseJSON(completionHandler: { response in
           // print(response.result)
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error converting to dictionary: \(error.localizedDescription)")
                completion(false)
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        })
    }
    
    func deleteCartItem(dic: NSMutableDictionary ,selectItem:CartDataModel,completion: @escaping (Bool) -> Void){
        start_loading()
        self.delete_api_request("\(BaseURLOffice)cart/users/\(UserID)/products/\(selectItem.id ?? 0)", headers: headersCommon).responseData { response in
            //print(response.result)
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error converting to dictionary: \(error.localizedDescription)")
                completion(true)
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    
    func GetAddressList(){
//        let headers: HTTPHeaders = [
//            "Authorization": AuthToken
//        ]
        start_loading()
        self.get_api_request("https://api-cluster.system.touchetv.com/backoffice-user/api/v1/user/\(UserID)/address/", headers: headersCommon).responseDecodable(of: AddressData.self) { response in
            //print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(AddressData.self, from: responseData)
                        self.addressListData = welcome.sorted { $0.primary ?? false && !($1.primary ?? false) }
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
