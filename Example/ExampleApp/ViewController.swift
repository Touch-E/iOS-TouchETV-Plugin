//
//  ViewController.swift
//  ExampleApp
//
//  Created by Parth on 24/01/25.
//

import UIKit
import TouchETVPlugin
class ViewController: UIViewController {

    @IBOutlet weak var profileIMG: UIImageView!
    @IBOutlet weak var cartCountBTN: UIButton!
    @IBOutlet weak var dataTBL: UITableView!
    var VideoListData : HomeData?
    var CartDataARY : CartData?
    
    public struct Identifiers {
        static let kRecentMovieCell = "RecentMovieCell"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ConfigureTableView()
        GetMovieDetail()
        GetCartDataCount()
    }

    @IBAction func profileClick_Action(_ sender: Any) {
        let viewcontroller = ProfileVC()
        viewcontroller.modalPresentationStyle = .custom
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    @IBAction func CartClick_Action(_ sender: Any) {
        let viewcontroller = MyCartVC()
        viewcontroller.modalPresentationStyle = .custom
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    func ConfigureTableView(){
        dataTBL.delegate = self
        dataTBL.dataSource = self
        dataTBL.register(UINib(nibName: Identifiers.kRecentMovieCell, bundle: nil), forCellReuseIdentifier: Identifiers.kRecentMovieCell)
    }
    func GetMovieDetail(){
        TouchETVPluginVC.shared.getMovieDetail { result in
            switch result {
            case .success(let homeData):
                self.VideoListData = homeData
                self.dataTBL.reloadData()
            case .failure(let error):
                self.ShowAlert1(title: "Error", message: "\(error.localizedDescription)")
            }
        }
    }
    func GetCartDataCount(){
        TouchETVPluginVC.shared.getCartDataCount { result in
            switch result {
            case .success(let cartData):
                self.CartDataARY = cartData
                self.cartCountBTN.setTitle("\(self.CartDataARY?.count ?? 0)", for: .normal)
            case .failure(let error):
                self.ShowAlert1(title: "Error", message: "\(error.localizedDescription)")
            }
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataTBL.dequeueReusableCell(withIdentifier: Identifiers.kRecentMovieCell, for: indexPath) as! RecentMovieCell
        cell.selectionStyle = .none
        cell.VideoList = VideoListData
        cell.categoryCV.reloadData()
        cell.MovieClick = { (videoDic) -> Void in
            let viewcontroller = VideoDetailViewController()
            viewcontroller.modalPresentationStyle = .custom
            viewcontroller.VideoListData = videoDic
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
        return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
