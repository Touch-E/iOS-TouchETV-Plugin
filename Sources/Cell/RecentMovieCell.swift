//
//  RecentMovieCell.swift
//  TouchE TV
//
//  Created by Parth on 22/08/24.
//

import UIKit

class RecentMovieCell: UITableViewCell {

    @IBOutlet weak var categoryCV: UICollectionView!
    
    public struct Identifiers {
        static let kMovieItemCVCell = "MovieItemCVCell"
    }
    
    var VideoList : HomeData?
    var MovieClick : ((_ dic:HomeListModel)-> Void)?
    var videoClick : ((_ dic:HomeListModel)-> Void)?
    var index = 0
    var userARY : [Actor]?
    

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
        categoryCV.layoutIfNeeded()
        categoryCV.layoutSubviews()
//        vcCategoryHeight.constant = cvCategory.layer.bounds.width  / 2 + 44
    }
    func Configurecollection(){
        categoryCV.delegate = self
        categoryCV.dataSource = self
        categoryCV.register(UINib(nibName: Identifiers.kMovieItemCVCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kMovieItemCVCell)
        categoryCV.contentInsetAdjustmentBehavior = .never
    }
}
extension RecentMovieCell : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = categoryCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kMovieItemCVCell, for: indexPath) as! MovieItemCVCell
        
        let Dic = VideoList?[indexPath.row]
        let image = Dic?.images?.first?.url ?? ""
        if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            cell.posterIMG?.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
            cell.posterIMG?.contentMode = .scaleAspectFill
            cell.posterIMG?.layer.cornerRadius = 8
            cell.posterIMG?.clipsToBounds = true
         } else {
            print("Failed to encode URL string")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: categoryCV.layer.bounds.width / 2.5 , height: categoryCV.layer.bounds.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = videoClick{
            if let videoItem = VideoList?[indexPath.row] {
                action(videoItem)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        true
    }
  
}
