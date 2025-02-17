// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TouchETVPlugin",
    platforms: [
            .tvOS(.v13)
    ],
    products: [
       .library(
            name: "TouchETVPlugin",
            targets: ["TouchETVPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kishan-Italiya/SDWebImage.git", branch: "main"),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "4.8.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/evgenyneu/Cosmos.git", from: "23.0.0")
    ],
    targets: [
        
        .target(
            name: "TouchETVPlugin",
            dependencies: ["SDWebImage","NVActivityIndicatorView","Alamofire","Cosmos"],
            path: "Sources",
            resources: [
                //MARK: - AllCell
                .copy("Cell/AccountDetailsCell.xib"),
                .copy("Cell/ActorDetailTableViewCell.xib"),
                .copy("Cell/ActorimageCollectionViewCell.xib"),
                .copy("Cell/AddressCell.xib"),
                .copy("Cell/AddressCVCell.xib"),
                .copy("Cell/AttributeCell.xib"),
                .copy("Cell/AttributeItemCell.xib"),
                .copy("Cell/BrandImageCell.xib"),
                .copy("Cell/CardCVCell.xib"),
                .copy("Cell/CartAttributeCVCell.xib"),
                .copy("Cell/CartHeaderView.xib"),
                .copy("Cell/CartItemCell.xib"),
                .copy("Cell/CartSectionCell.xib"),
                .copy("Cell/categoriesCollectionViewCell.xib"),
                .copy("Cell/CategoriesTableViewCell.xib"),
                .copy("Cell/customerReviewCVCell.xib"),
                .copy("Cell/CustomerReviewTBLCell.xib"),
                .copy("Cell/GenresTBLCell.xib"),
                .copy("Cell/ItemTBLCell.xib"),
                .copy("Cell/LangAndCurencyCollectionViewCell.xib"),
                .copy("Cell/MoreProductCell.xib"),
                .copy("Cell/MoreProductTBLCell.xib"),
                .copy("Cell/MovieItemCVCell.xib"),
                .copy("Cell/OrderCell.xib"),
                .copy("Cell/OrderDetailTBLCell.xib"),
                .copy("Cell/OrderListCell.xib"),
                .copy("Cell/OrderListHeaderCell.xib"),
                .copy("Cell/OrderStatusCell.xib"),
                .copy("Cell/OrderStatusCellj.xib"),
                .copy("Cell/OrderSummearyCell.xib"),
                .copy("Cell/PaymentCardCell.xib"),
                .copy("Cell/PaymentDetailsTBLCell.xib"),
                .copy("Cell/PersonalinformationTBLCell.xib"),
                .copy("Cell/PosttoTBLCell.xib"),
                .copy("Cell/PriceShippingCell.xib"),
                .copy("Cell/ProductImageDetailsCell.xib"),
                .copy("Cell/RecentMovieCell.xib"),
                .copy("Cell/SelectedFilterCell.xib"),
                .copy("Cell/StoreTitleCell.xib"),
                .copy("Cell/VideoProductCVCell.xib"),
                
                
                //MARK: - ViewController
                .copy("Controller/AddAddressVC.xib"),
                .copy("Controller/ChangePasswordVC.xib"),
                .copy("Controller/EditProfileVC.xib"),
                .copy("Controller/LogoutPopupViewController.xib"),
                .copy("Controller/OrderDetailVC.xib"),
                .copy("Controller/OrderListVC.xib"),
                .copy("Controller/ProfileVC.xib"),
                .copy("Controller/RatePopupViewController.xib"),
                .copy("Controller/VideoDetailViewController.xib"),
                .copy("Controller/VideoViewController.xib"),
                .copy("TouchETVPlugin/pre-roll-02.mp4"),
            ]),
        .testTarget(
            name: "TouchETVPluginTests",
            dependencies: ["TouchETVPlugin"]),
    ]
)
