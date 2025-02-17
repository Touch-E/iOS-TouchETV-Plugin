//
//  CategoriesTableViewCell.swift
//  TouchE TV
//
//  Created by Parth on 21/08/24.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var lblVideoCount: UILabel!
    @IBOutlet weak var cvCategory: UICollectionView!
    public struct Identifiers {
        static let kcategoriesCollectionViewCell = "categoriesCollectionViewCell"
    }
    
    var VideoList : HomeData?
    var MovieClick : ((_ dic:HomeListModel)-> Void)?
    var ActorClick : ((_ id : Int)-> Void)?
    var brandClick : ((_ id : Int)-> Void)?
    var index = 0
    var VideoDetail : HomeListModel?
    var actorDetail : [HomeListModel]?
    var userARY : [Actor]?
    var brandARY : [Brand]?
    
    var isVideoDetail = false
    var isActorDetails = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Configurecollection()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        cvCategory.layoutIfNeeded()
        cvCategory.layoutSubviews()
//        vcCategoryHeight.constant = cvCategory.layer.bounds.width  / 2 + 44
    }
    func Configurecollection(){
        cvCategory.delegate = self
        cvCategory.dataSource = self
        cvCategory.register(UINib(nibName: Identifiers.kcategoriesCollectionViewCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kcategoriesCollectionViewCell)
        cvCategory.contentInsetAdjustmentBehavior = .never
    }

}
extension CategoriesTableViewCell : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isActorDetails{
            return  actorDetail?.count ?? 0
        }else if isVideoDetail {
            return  index == 4 ? brandARY?.count ?? 0 : userARY?.count ?? 0
        }else {
            return VideoList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cvCategory.dequeueReusableCell(withReuseIdentifier: Identifiers.kcategoriesCollectionViewCell, for: indexPath) as! categoriesCollectionViewCell
        
        if isActorDetails{
            var image = ""
            let Dic = actorDetail?[indexPath.row]
            image = Dic?.images?.first?.url ?? ""
            cell.lblName.text = Dic?.name ?? ""
            
            if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                // Use the encoded URL string
                print(encodedUrlString)
                cell.imgVideo.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                cell.imgVideo.contentMode = .scaleAspectFill
            } else {
                // Handle the case where encoding fails
                print("Failed to encode URL string")
            }
            
        }else if isVideoDetail {
            
            if index == 4 {
                
                let Dic = brandARY?[indexPath.row]
                let image = Dic?.images?.first?.url ?? ""
                if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    // Use the encoded URL string
                    print(encodedUrlString)
                    cell.imgVideo.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                    cell.imgVideo.contentMode = .scaleAspectFill
                } else {
                    // Handle the case where encoding fails
                    print("Failed to encode URL string")
                }
                cell.lblName.text = Dic?.name ?? ""
                
            }else {
                
                let Dic = userARY?[indexPath.row]
                let image = Dic?.images?.first?.url ?? ""
                if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    // Use the encoded URL string
                    print(encodedUrlString)
                    cell.imgVideo.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                    cell.imgVideo.contentMode = .scaleAspectFill
                } else {
                    // Handle the case where encoding fails
                    print("Failed to encode URL string")
                }
                cell.lblName.text = Dic?.name ?? ""
            }
            
        }else {
            let Dic = VideoList?[indexPath.row]
            let image = Dic?.images?.first?.url ?? ""
            if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                cell.imgVideo.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                cell.imgVideo.contentMode = .scaleAspectFill
                cell.imgVideo.layer.cornerRadius = 4
            } else {
                print("Failed to encode URL string")
            }
            cell.nameHeightCON.constant = 0
            cell.lblName.text = ""//Dic?.name ?? ""
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isActorDetails{
           if let action = MovieClick {
                if let videoItem = actorDetail?[indexPath.row] {
                    action(videoItem)
                }
            }
        }else if isVideoDetail {
            if index != 4 {
                print(index)
                if let action = ActorClick {
                    let Dic = userARY?[indexPath.row]
                    let actorID = Dic?.id ?? 0
                    action(actorID)
                }
            }else{
                print(index)
                if let action = brandClick {
                    let Dic = brandARY?[indexPath.row]
                    let actorID = Dic?.id ?? 0
                    action(actorID)
                }
            }
        }else {
            if let action = MovieClick {
                if let videoItem = VideoList?[indexPath.row] {
                    action(videoItem)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: cvCategory.layer.bounds.height / 1.7 , height: cvCategory.layer.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
}
