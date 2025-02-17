//
//  VideoViewController.swift
//  
//
//  Created by Jaydip Godhani on 29/01/25.
//

import UIKit
import AVKit
import Alamofire
import AVFoundation

public class VideoViewController: UIViewController {
    
    static func storyboardInstance() -> VideoViewController {
        return mainStoryboard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
    }
    
    @IBOutlet weak var VovimageView: UIImageView!
    @IBOutlet weak var backgroundVideoContainer: UIView!
    @IBOutlet weak var viewBgSeekBar: UIView!
    @IBOutlet weak var cloaseUV: UIView!
    @IBOutlet weak var userProfileIMG: UIImageViewX!
    @IBOutlet weak var videoTitleLB: UILabel!
    @IBOutlet weak var ButtonPlay: UIButton!
    @IBOutlet weak var playIMG: UIImageView!
    //@IBOutlet weak var playbackSlider: UIProgressView!
    @IBOutlet weak var playbackSlider: TvOSSlider!
    @IBOutlet weak var lblOverallDuration: UILabel!
    @IBOutlet weak var cartBackUV: UIView!
    @IBOutlet weak var cartCountBTN: UIButtonX!
    @IBOutlet weak var productCV: UICollectionView!
    @IBOutlet weak var dotCollectionView: UICollectionView!
    @IBOutlet weak var vovBTN: UIButton!
    @IBOutlet weak var smallVideoUV: UIView!
    @IBOutlet weak var tembIMG: UIImageView!
    @IBOutlet weak var introVideoUV: UIView!
    @IBOutlet weak var skipIntroUV: UIView!
    @IBOutlet weak var skipIntroProgressUV: UIView!
    @IBOutlet weak var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var introReplayUV: UIView!
    @IBOutlet weak var isProductAvailableUV: UIView!
    @IBOutlet weak var isProductIMG: UIImageView!
    @IBOutlet weak var productTitleLBL: UILabel!
    @IBOutlet weak var isProdcutAvblUVWidth: NSLayoutConstraint!
    
//    @IBOutlet weak var volumeSlider: UISlider!
//    @IBOutlet weak var volumeUV: UIViewX!

    var VideoString = ""
    var VideoListDic : HomeListModel?
    var VideoData : VideoDataModel?
    var ProductVideoData : ProductVideoModel?
    var mappingData : MappingDataModel?
    var player:AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem:AVPlayerItem?
    var sliderDragToPlayPause = false
    var isShown = false
    var LiveTBLStaticHeight = CGFloat(0.0)
    var ind = 0
    var isFirst = true
    var timer: Timer?
    var elapsedTime: TimeInterval = 0.0
    var CTTime = CMTime()
    var productIDArray = [Int]()
    var RRect : CGRect?
    var brandID = ""
    var prodcutARY = [Product]()
    var prodcutARYForCheck = [Product]()
    var dotARYForCheck = [Product]()
    var tempARY = [String]()
    var currentVideoTime : Double = 0.0
    var videoTouchPoint = CGPoint()
    var filterEventData = [String? : [Event]]()
    var cartData : CartData?
    var currentVolumeValue:Float = 0.0
    var dispatchWorkItem: DispatchWorkItem?
    var acdispatchWorkItem: DispatchWorkItem?
    var productData : Product?
    var draggedCell: UICollectionViewCell?
    var initialIndexPath: IndexPath?
    var dragPlaceholderView: UIView?
    var fakeTapTimer: Timer?
    var productRemoveARY = NSMutableArray()
    var currentlySelectedProductID: Int?
    var isOpenItemARY = [Int]()

    public struct Identifiers {
        static let kVideoProductCVCell = "VideoProductCVCell"
    }
    var IsActor = false
    var currentItemId = ""
    var isVideoCompeted = false
    
    var originalFrame: CGRect!
    var splayer:AVPlayer?
    var splayerLayer: AVPlayerLayer?
    var playerViewController: AVPlayerViewController!
    var smallVideoString = ""

    var IntroPlayer:AVPlayer?
    var IntroPlayerLayer: AVPlayerLayer?
    var IntroPlayerViewController: AVPlayerViewController!
    var IntroVideoString = "https://touche-backoffice.s3.amazonaws.com/videos/1735188471755_08208397907939027.mp4"
    var timeObserver: Any?
    var hasAnimated = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.module.loadNibNamed("VideoViewController", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        VovimageView.isHidden = true
        vovBTN.isHidden = true
        playbackSlider.isHidden = true
        cloaseUV.isHidden = false
        viewBgSeekBar.isHidden = false
        
        dotCollectionView.layer.borderWidth = 4
        dotCollectionView.layer.borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1).cgColor
        dotCollectionView.layer.cornerRadius = 10
        dotCollectionView.clipsToBounds = true
        
        
        
        let borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
        //playbackSlider.addTarget(self, action: #selector(sliderValueChanges), for: .valueChanged)
        playbackSlider.minimumValue = 0
        playbackSlider.maximumValue = 100
        playbackSlider.stepValue = 10
        playbackSlider.minimumTrackTintColor = borderColor
        
       //originalFrame = smallVideoUV.frame
        smallVideoUV.layer.borderWidth = 4
        smallVideoUV.layer.borderColor = UIColor.white.cgColor
        smallVideoUV.isHidden = true
        
        
        self.GetVideoDetail(id: "\(self.VideoListDic?.id ?? 0)")
        self.GetEntitiesDetail(id: "\(self.VideoListDic?.id ?? 0)")
        
        DispatchQueue.main.async { [self] in
            IntroPlayerLayer?.frame = self.introVideoUV.bounds
            
            // Get the path to the local video
            guard let fileURL = Bundle.module.url(forResource: "pre-roll-02", withExtension: "mp4") else {
                print("❌ Local video file not found in Swift Package!")
                return
            }
            print("✅ Video file found: \(fileURL)")
            
            //let fileURL = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem(url: fileURL)
            IntroPlayer = AVPlayer(playerItem: playerItem)
            IntroPlayerLayer = AVPlayerLayer(player: IntroPlayer)
            IntroPlayerLayer?.videoGravity = .resizeAspect
            self.introVideoUV.layer.addSublayer(IntroPlayerLayer!)
            IntroPlayer?.play()

            // Add observer for video completion
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(videoDidFinishPlaying(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: playerItem
            )
            
            // Add periodic time observer
            let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = IntroPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
                guard let self = self, let duration = self.IntroPlayer?.currentItem?.duration else { return }
                let totalSeconds = CMTimeGetSeconds(duration)
                let currentSeconds = CMTimeGetSeconds(currentTime)
                
                if totalSeconds > 0 {
                    let progress = CGFloat(currentSeconds / totalSeconds)
                    self.updateProgressView(progress: progress)
                }
            }
        }
    }
    @objc func videoDidFinishPlaying(_ notification: Notification) {
       mainVideoLoad()
    }
    func mainVideoLoad(){
        
        introVideoUV.isHidden = true
        skipIntroUV.isHidden = true
        introReplayUV.isHidden = true
        
        cloaseUV.isHidden = false
        viewBgSeekBar.isHidden = false
        playbackSlider.isHidden = false
        scheduleDispatch(after: 8)
        
        DispatchQueue.main.async {
            
            var image = ""
            image = profileData.value(forKey: "imageUrl") as? String ?? ""
            if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                self.userProfileIMG.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                self.userProfileIMG.contentMode = .scaleAspectFill
            }
            self.videoTitleLB.text = self.VideoListDic?.name ?? ""
            self.start_loading()
            self.pastVideoPlayer()
            self.Configurecollection()
            self.GetCartDetail()
        }
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = self.backgroundVideoContainer.bounds
        splayerLayer?.frame = self.smallVideoUV.bounds
        IntroPlayerLayer?.frame = self.introVideoUV.bounds
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        cloaseUV.isHidden = false
        viewBgSeekBar.isHidden = false
        dotCollectionView.isHidden = dotARYForCheck.isEmpty
        printNotHideSubviews(view: backgroundVideoContainer)
        scheduleDispatch(after: 4)
        
        if let status = player?.timeControlStatus {
            switch status {
            case .playing:
                print("Player is playing")
            case .paused:
                player!.play()
               // ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
                playIMG.image = UIImage(named: "pause", in: Bundle.module, with: nil)
                resumeTimer()
            case .waitingToPlayAtSpecifiedRate:
                print("Player is waiting to play at specified rate")
            @unknown default:
                print("Unknown timeControlStatus: \(status)")
            }
        } else {
            print("Player is nil")
        }
    }
    public override func viewWillDisappear(_ animated: Bool) {
        playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
        pauseTimer()
        player!.pause()
    
    }
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        // Check if focus has changed
        if let nextFocusedView = context.nextFocusedView as? UICollectionViewCell,
           let indexPath = dotCollectionView.indexPath(for: nextFocusedView) {
            print("Currently focused index: \(indexPath.row)")
            dotFocusChange(arrayIndex: indexPath.row)
        }
    }
    func dotFocusChange(arrayIndex : Int){
        let selectProductID = dotARYForCheck[arrayIndex]
        
        for subview in backgroundVideoContainer.subviews {
            for i in 0..<dotARYForCheck.count{
                let productID = dotARYForCheck[i]
                if subview.tag == (productID.id ?? 0) + 1000{
                    if productID.id == selectProductID.id{
                        if let viewToRemove = subview.viewWithTag((productID.id ?? 0) + 1000) {
                            if let dotIMGView = viewToRemove.viewWithTag(115) as? UIImageView {
                                dotIMGView.image = UIImage(named: "ic_focus", in: Bundle.module, with: nil)
                            }
                        }
                    }else{
                        if let viewToRemove = subview.viewWithTag((productID.id ?? 0) + 1000) {
                            if let dotIMGView = viewToRemove.viewWithTag(115) as? UIImageView {
                                dotIMGView.image = UIImage(named: "ic_hotspot", in: Bundle.module, with: nil)
                            }
                        }
                    }
                }
            }
        }

        for subview in backgroundVideoContainer.subviews {
            for i in 0..<dotARYForCheck.count{
                let productID = dotARYForCheck[i]
                if subview.tag == (productID.id ?? 0){
                    if productID.id == selectProductID.id{
                        if let viewToRemove = subview.viewWithTag((productID.id ?? 0)) {
                            if let backView = viewToRemove.viewWithTag(120){
                                backView.layer.borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1).cgColor
                            }
                        }
                    }else{
                        if let viewToRemove = subview.viewWithTag((productID.id ?? 0)) {
                            if let backView = viewToRemove.viewWithTag(120){
                                backView.layer.borderColor = UIColor.white.cgColor
                            }
                        }
                    }
                }
            }
        }
    }
    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
          super.pressesBegan(presses, with: event)
          
          for press in presses {
              switch press.type {
              case .playPause:
                  print("Play/Pause button pressed")
                  // Handle play/pause button action here
                  
              case .menu:
                  print("Menu button pressed")
                  // Handle menu button action here
                  
              case .select:
                  print("Select button pressed")
                  // Handle select (touchpad click) action here
                  
              case .upArrow:
                  self.viewHideShowHandle()
                  // Handle up arrow press
                  
              case .downArrow:
                  self.viewHideShowHandle()
                  // Handle down arrow press
                  
              case .leftArrow:
                  self.viewHideShowHandle()
                  // Handle left arrow press
                  
              case .rightArrow:
                  self.viewHideShowHandle()
                  // Handle right arrow press
                  
              default:
                  break
              }
          }
      }
    func viewHideShowHandle(){
        if cloaseUV.isHidden {
            cloaseUV.isHidden = false
            viewBgSeekBar.isHidden = false
            //productCV.isHidden = false
            dotCollectionView.isHidden = dotARYForCheck.isEmpty
            VovimageView.isHidden = false
            vovBTN.isHidden = false
            printNotHideSubviews(view: backgroundVideoContainer)
            scheduleDispatch(after: 4)
        } else {
            scheduleDispatch(after: 4)
        }
    }

    func updateProgressView(progress: CGFloat) {
        let maxWidth = skipIntroUV.bounds.width
        progressViewWidth.constant = maxWidth * progress
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func removeTimeObserver() {
        if let timeObserver = timeObserver {
            IntroPlayer?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
//    let viewcontroller = VovVC.storyboardInstance()
        let viewcontroller = VovVC()
        viewcontroller.modalPresentationStyle = .custom
        viewcontroller.VideoString = smallVideoString
        rotate_flag = true
        let nav = UINavigationController(rootViewController: viewcontroller)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
 
    func configrationSmallVideoView(){
        
        if let videoURL = URL(string: smallVideoString) {
            generateThumbnail(from: videoURL) { thumbnail in
                if let thumbnail = thumbnail {
                    self.tembIMG.image = thumbnail
                    self.tembIMG.contentMode = .scaleAspectFill
                } else {
                    print("Failed to generate thumbnail")
                }
            }
        }
    
    }
    func Configurecollection(){
        productCV.delegate = self
        productCV.dataSource = self
        productCV.register(UINib(nibName: Identifiers.kVideoProductCVCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kVideoProductCVCell)
        productCV.contentInsetAdjustmentBehavior = .never
        
        
        dotCollectionView.delegate = self
        dotCollectionView.dataSource = self
        dotCollectionView.register(UINib(nibName: Identifiers.kVideoProductCVCell, bundle: Bundle.module), forCellWithReuseIdentifier: Identifiers.kVideoProductCVCell)
        dotCollectionView.contentInsetAdjustmentBehavior = .never
        
    }
    @IBAction func skipIntroClick_Action(_ sender: UIButton) {
        IntroPlayer?.pause()
        IntroPlayer?.replaceCurrentItem(with: nil)
        mainVideoLoad()
    }
    @IBAction func replayIntroClick_Action(_ sender: Any) {
        IntroPlayer?.seek(to: .zero) { [weak self] completed in
              if completed {
                  // Play the video from the beginning
                  self?.IntroPlayer?.play()
              }
          }
    }
    @IBAction func cartClick_Action(_ sender: Any) {
//        let viewcontroller = MyCartVC.storyboardInstance()
        let viewcontroller = MyCartVC()
        viewcontroller.modalPresentationStyle = .custom
        viewcontroller.isfromVideo = true
        rotate_flag = false

        let nav = UINavigationController(rootViewController: viewcontroller)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    @IBAction func profileClick_Action(_ sender: Any) {
//        let vc = profileStoryboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//        vc.modalPresentationStyle = .custom
//        vc.isfromVideo = true
//        rotate_flag = false
//
//        let nav = UINavigationController(rootViewController: vc)
//        nav.isNavigationBarHidden = true
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true)
      
    }
    @IBAction func volumeClick_Actiom(_ sender: UIButton) {
//        volumeUV.isHidden = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            //if self.volumeSlider.value == self.currentVolumeValue{
//                self.volumeUV.isHidden = true
//            //}
//        }
      
    }
    @IBAction func actorBrandClick_Action(_ sender: UIButton) {
        if IsActor{
//            let viewcontroller = ActorDetailsVC.storyboardInstance()
            let viewcontroller = ActorDetailsVC()
            viewcontroller.modalPresentationStyle = .custom
            viewcontroller.actorID = currentItemId
            viewcontroller.isfromVideo = true
            rotate_flag = false
            
            let nav = UINavigationController(rootViewController: viewcontroller)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            //self.navigationController?.pushViewController(viewcontroller, animated: true)
        }else{
//            let viewcontroller = BrandDetailsVC.storyboardInstance()
            let viewcontroller = BrandDetailsVC()
            viewcontroller.modalPresentationStyle = .custom
            viewcontroller.brandID = currentItemId
            viewcontroller.isfromVideo = true
            rotate_flag = false
            
            let nav = UINavigationController(rootViewController: viewcontroller)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateVideoDetail), userInfo: nil, repeats: true)
    }
    
    @objc func updateVideoDetail() {
        elapsedTime += 0.5
        let currentTimeInSeconds = CMTimeGetSeconds(CTTime)
        
//        if currentTimeInSeconds.isFinite {
//            let currentFrameNumber = Int(currentTimeInSeconds * Double(30)) + 1
//            checkVOVAvailable(currentFrame: currentFrameNumber)
//        }
        
        //self.findEventOnTouch()
         updateEventFrames(CTTime)
        DispatchQueue.main.async {
            self.checkIsProductNeedToRemove()
            self.checkIsProductAvailableOnScreen()
        }
         
        
    }
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        
        fakeTapTimer?.invalidate()
        fakeTapTimer = nil
    }
    
    func resumeTimer() {
        // Check if the timer is not already running
        //if timer == nil {
            startTimer()
            startFakeTapSimulation()
            print("Timer resumed")
       // }
    }
    
    func stopTimer() {
        // Stop the timer when needed (e.g., when the view controller is about to be deallocated)
        timer?.invalidate()
        fakeTapTimer?.invalidate()
    }
    
    deinit {
        // Make sure to stop the timer when the view controller is deallocated
        stopTimer()
    }
    
    
    @IBAction func ButtonPlay(_ sender: Any) {
        print("play Button")
        if player?.rate == 0
        {
            player!.play()
            // self.ButtonPlay.isHidden = true
            //ButtonPlay.setBackgroundImage(UIImage(named: "pause"), for: UIControl.State.normal)
            playIMG.image = UIImage(named: "pause", in: Bundle.module, with: nil)
            resumeTimer()
        } else {
            player!.pause()
            //ButtonPlay.setBackgroundImage(UIImage(named: "play"), for: UIControl.State.normal)
            playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
            pauseTimer()
        }
    }
    
    @IBAction func dismissClick(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
       // ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
        pauseTimer()
        player!.pause()
        rotate_flag = false
        self.dismiss(animated: true)
       // self.navigationController?.popViewController(animated: true)
    }
    @objc func dismissPlayerViewController() {
        // Dismiss the AVPlayerViewController
        dismiss(animated: true, completion: nil)
    }
    
    func updateFrames(_ time: CMTime) {
        
    }
    
    func calculateFrameRate(totalFrameCount: Int, duration: Double) -> Double {
        return Double(totalFrameCount) / duration
    }
    
    func hideImage() {
        VovimageView.isHidden = true
        vovBTN.isHidden = true
    }
    
    func showImage(image: String?) {
        if let encodedUrlString = image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // Use the encoded URL string
           // print(encodedUrlString)
            VovimageView.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
            
            if cloaseUV.isHidden == true{
                VovimageView.isHidden = true
                vovBTN.isHidden = true
            }else{
                VovimageView.isHidden = false
                vovBTN.isHidden = false
            }
            
            // Schedule the image to hide after the specified duration
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.hideImage()
            }
        } else {
            // Handle the case where encoding fails
            print("Failed to encode URL string")
        }
    }
 
//    func pastVideoPlayer() {
//
//        let url = URL(string: VideoString)
//        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
//        player = AVPlayer(playerItem: playerItem)
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.videoGravity = .resizeAspect
//
////        self.backgroundVideoContainer.backgroundColor = .yellow
//        self.backgroundVideoContainer.layer.addSublayer(playerLayer!)
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        self.backgroundVideoContainer.addGestureRecognizer(tapGesture)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//        } catch(let error) {
//            print(error.localizedDescription)
//        }
//        // Add playback slider
//        playbackSlider.progress = 0
//
//        playbackSlider.addTarget(self, action: #selector(VideoViewController.playbackSliderValueChanged(_:)), for: .valueChanged)
//
//        playbackSlider.isContinuous = true
//        playbackSlider.tintColor = UIColor.white
//
//        start_loading()
//
//        if self.sliderDragToPlayPause == false {
//            player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { (CMTime) -> Void in
//                if self.player!.currentItem?.status == .readyToPlay {
//                    let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
//                    self.playbackSlider.value = Float ( time );
//                    self.lblcurrentText.text = self.stringFromTimeInterval(interval: time)
//                    if (time > 0) {
//                        self.CTTime = CMTime
//                        self.updateFrames(CMTime)
//                        self.stop_loading()
//                    }
//                }
//
//                self.playbackSlider.isContinuous = true
//                let duration : CMTime = playerItem.asset.duration
//                let seconds : Float64 = CMTimeGetSeconds(duration)
//                self.lblOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
//                self.playbackSlider.maximumValue = Float(seconds)
//
//                let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
//                if playbackLikelyToKeepUp == false{
//                    //debugPrint("IsBuffering")
//                } else {
//                   // debugPrint("Buffering completed")
//                }
//            }
//            player?.play()
//            ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
//            startTimer()
//
//
//
//            // Added For vloume
//            player!.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: nil)
//            player!.volume = 0.5
//
//            volumeSlider.minimumValue = 0.0
//            volumeSlider.maximumValue = 1.0
//            volumeSlider.value = player!.volume // Set initial value to current volume
//            currentVolumeValue = player!.volume
//            volumeSlider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
//
//        }
//    }
    
    func pastVideoPlayer() {
        let url = URL(string: VideoString)
        let playerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        self.backgroundVideoContainer.layer.addSublayer(playerLayer!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.backgroundVideoContainer.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        // Add progress view
        // Add playback slider
        playbackSlider.minimumValue = 0
        
        playbackSlider.addTarget(self, action: #selector(VideoViewController.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        playbackSlider.isContinuous = true
        playbackSlider.tintColor = UIColor.white
        
        start_loading()
        
        if self.sliderDragToPlayPause == false {
            player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { (CMTime) -> Void in
                if self.player!.currentItem?.status == .readyToPlay {
                    let currentTime: Float64 = CMTimeGetSeconds(self.player!.currentTime())
                    let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                    self.playbackSlider.value = Float ( time );
                    //self.lblcurrentText.text = self.stringFromTimeInterval(interval: time)
                    
                    let duration: CMTime = self.player!.currentItem!.duration
                    let totalSeconds: Float64 = CMTimeGetSeconds(duration)
                    let remainingTime: Float64 = totalSeconds - currentTime
                    
                    self.lblOverallDuration.text = "-\(self.stringFromTimeInterval(interval: remainingTime))"
                    if (time > 0) {
                        self.CTTime = CMTime
                        self.updateFrames(CMTime)
                        self.stop_loading()
                    }
                }
                
                self.playbackSlider.isContinuous = true
                let duration : CMTime = playerItem.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                //self.lblOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
                self.playbackSlider.maximumValue = Float(seconds)
                
                let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
                if playbackLikelyToKeepUp == false{
                    //debugPrint("IsBuffering")
                } else {
                   // debugPrint("Buffering completed")
                }
            }
            player?.play()
            //ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
            playIMG.image = UIImage(named: "pause", in: Bundle.module, with: nil)
            startTimer()
            startFakeTapSimulation()
            
            // Volume handling
            player!.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: nil)
            player!.volume = 0.5
          
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let player = player else { return }
        
        let location = gesture.location(in: playbackSlider)
        let progress = min(max(Float(location.x / playbackSlider.bounds.width), 0), 1)
        let duration = player.currentItem?.duration
        let newTime = CMTime(seconds: Double(progress) * CMTimeGetSeconds(duration!), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        switch gesture.state {
        case .began, .changed:
            // Update progress as the user scrubs
            player.pause()
            player.seek(to: newTime)
        case .ended:
            // Resume playback when scrubbing ends
            player.play()
        default:
            break
        }
    }

    
    // Observer method to handle player status changes
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        if keyPath == #keyPath(AVPlayer.status) {
            // When player status changes to ready to play, start playing the audio
            if player!.status == .readyToPlay {
                player!.play()
            }
        }
    }
  
    func scheduleDispatch(after interval: TimeInterval) {
        cancelDispatch()

        let workItem = DispatchWorkItem { [weak self] in
            self?.hideViews()
        }
        
        dispatchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem)
    }

    func cancelDispatch() {
        if let workItem = dispatchWorkItem {
            workItem.cancel()
        }
    }

    @objc func hideViews() {
        self.cloaseUV.isHidden = true
        self.viewBgSeekBar.isHidden = true
        //self.productCV.isHidden = true
        self.dotCollectionView.isHidden = true
        self.VovimageView.isHidden = true
        self.vovBTN.isHidden = true
        self.printSubviews(view: backgroundVideoContainer)
    }
    
    func startFakeTapSimulation() {
        fakeTapTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(simulateFakeTap), userInfo: nil, repeats: true)
    }

    func stopFakeTapSimulation() {
        fakeTapTimer?.invalidate()
        fakeTapTimer = nil
    }

    @objc func simulateFakeTap() {
        
        let simulatedTouchPoint = CGPoint(x: backgroundVideoContainer.bounds.midX, y: backgroundVideoContainer.bounds.midY)
        let fakeTapGesture = UITapGestureRecognizer()
        fakeTapGesture.setValue(backgroundVideoContainer, forKey: "view")
        fakeTapGesture.setValue(simulatedTouchPoint, forKey: "locationInView")
        handleTap(fakeTapGesture)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        
        let touchPointInBackgroundContainer = gesture.location(in: backgroundVideoContainer)
        var videoFrame = CGRect()
        videoFrame = playerLayer!.videoRect
        
        if let hitLayer = findHitLayer(at: touchPointInBackgroundContainer) {
            let touchPointInHitLayer = hitLayer.convert(touchPointInBackgroundContainer, from: backgroundVideoContainer.layer)
            videoTouchPoint = touchPointInHitLayer
            self.findEventOnTouch()
        }
//        if videoFrame.contains(touchPointInBackgroundContainer) {
//            if let hitLayer = findHitLayer(at: touchPointInBackgroundContainer) {
//                let touchPointInHitLayer = hitLayer.convert(touchPointInBackgroundContainer, from: backgroundVideoContainer.layer)
//                videoTouchPoint = touchPointInHitLayer
//                self.findEventOnTouch()
//            }
//        }
        
    }
    
    func findHitLayer(at point: CGPoint) -> CALayer? {
        for sublayer in playerLayer?.sublayers ?? [] {
            if let hitLayer = sublayer.hitTest(point) {
                if let templayer = hitLayer.hitTest(point) {
                    return templayer
                }
                return hitLayer
            }
        }
        return nil
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        //ButtonPlay.setImage(UIImage(named: "play"), for: .normal)
        //ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        stopTimer()
        playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
        playbackSlider.setValue(0, animated: true)
        playbackSliderValueChanged(playbackSlider)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:TvOSSlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        prodcutARY.removeAll()
        prodcutARYForCheck.removeAll()
        backgroundVideoContainer.subviews.forEach { $0.removeFromSuperview() }
        dotARYForCheck.removeAll()
        isOpenItemARY.removeAll()
        
        productCV.reloadData()
        
        dotCollectionView.isHidden = dotARYForCheck.isEmpty
        dotCollectionView.reloadData()
    }
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d",hours, minutes, seconds)
    }
    
    func convertLastDigitToDecimalPoint(number: Int) -> String {
        var numberString = String(number)
        if let lastCharacter = numberString.last {
            numberString = String(numberString.dropLast()) + "." + String(lastCharacter)
        }
        return numberString
    }

}
extension VideoViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productCV{
            return prodcutARY.count
        }else{
            return dotARYForCheck.count
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == productCV{
            let cell = productCV.dequeueReusableCell(withReuseIdentifier: Identifiers.kVideoProductCVCell, for: indexPath) as! VideoProductCVCell
            let productDic = prodcutARY[indexPath.row]
            let image = productDic.mainImage?.url ?? ""
            if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                cell.productImageIMG.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                cell.productImageIMG.contentMode = .scaleAspectFill
            } else {
                print("Failed to encode URL string")
            }
            cell.titleLBL.text = "$\(productDic.productSkus?.first?.price ?? 0)"
            cell.countLBL.text = "\(indexPath.row + 1)"
            
            return cell
        }else{
            let cell = dotCollectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.kVideoProductCVCell, for: indexPath) as! VideoProductCVCell
            let productDic = dotARYForCheck[indexPath.row]
            let image = productDic.mainImage?.url ?? ""
            if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                cell.productImageIMG.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                cell.productImageIMG.contentMode = .scaleAspectFill
            } else {
                print("Failed to encode URL string")
            }
            cell.titleLBL.text = "$\(productDic.productSkus?.first?.price ?? 0)"
            cell.countLBL.isHidden = true//text = "\(indexPath.row + 1)"
            
            return cell
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == productCV{
            
            let productDic = prodcutARY[indexPath.row]
//            let viewcontroller = ProdutDetailsVC.storyboardInstance()
            let viewcontroller = ProdutDetailsVC()
            viewcontroller.modalPresentationStyle = .custom
            viewcontroller.productID = "\(productDic.id!)"
            viewcontroller.isfromVideo = true
            rotate_flag = false
            
            let nav = UINavigationController(rootViewController: viewcontroller)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }else{
            let selectProductID = dotARYForCheck[indexPath.row]
            let selectedID = selectProductID.id ?? 0
            let isAvailable = isOpenItemARY.contains(selectedID)
            
            if isAvailable == true{
                
                let productDic = dotARYForCheck[indexPath.row]
//                let viewcontroller = ProdutDetailsVC.storyboardInstance()
                let viewcontroller = ProdutDetailsVC()
                viewcontroller.modalPresentationStyle = .custom
                viewcontroller.productID = "\(productDic.id!)"
                viewcontroller.isfromVideo = true
                rotate_flag = false
                
                let nav = UINavigationController(rootViewController: viewcontroller)
                nav.isNavigationBarHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }else{
                currentlySelectedProductID = selectProductID.id
                isOpenItemARY.append(selectProductID.id ?? 0)
                for subview in backgroundVideoContainer.subviews {
                    for i in 0..<dotARYForCheck.count{
                        let productID = dotARYForCheck[i]
                        if subview.tag == (productID.id ?? 0){
                            if productID.id == selectProductID.id{
                                if let viewToRemove = subview.viewWithTag((productID.id ?? 0)) {
                                    viewToRemove.isHidden = false // Or any color you want to set
                                }
                            }
//                            else{
//                                if let viewToRemove = subview.viewWithTag((productID.id ?? 0)) {
//                                    viewToRemove.isHidden = true
//
//                                }
//                            }
                        }
                    }
                }
                
                for subview in backgroundVideoContainer.subviews {
                    for i in 0..<dotARYForCheck.count{
                        let productID = dotARYForCheck[i]
                        if subview.tag == (productID.id ?? 0) + 1000{
                            if productID.id == selectProductID.id{
                                if let viewToRemove = subview.viewWithTag((productID.id ?? 0) + 1000) {
                                    viewToRemove.isHidden = true  // Or any color you want to set
                                }
                            }
//                            else{
//                                if let viewToRemove = subview.viewWithTag((productID.id ?? 0) + 1000) {
//                                    viewToRemove.isHidden = false // Or any color you want to set
//
//                                }
//                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == productCV{
            return CGSize(width: 100 , height: 100)
        }else{
            return CGSize(width: 100 , height: 100)
        }
    }
    
}
//MARK :- Show Product on touch
extension VideoViewController{
    
    func findEventOnTouch(){
        let tempTime:Double = currentVideoTime
        for (_, models) in filterEventData {

            for index in 0..<models.count - 1 {
                let currentEvent = models[index]
                let nextEvent = models[index + 1]

                if let currentEventTime = currentEvent.t, let nextEventTime = nextEvent.t {

                    let formattedEventTime = convertLastDigitToDecimalPoint(number: currentEventTime)
                    let timeRangeStart = Double(formattedEventTime)

                    let EformattedEventTime = convertLastDigitToDecimalPoint(number: nextEventTime)
                    let timeRangeEnd = Double(EformattedEventTime)

                    if tempTime >= timeRangeStart! && tempTime <= timeRangeEnd! {

                        if models[index].type?.rawValue == "I" {
                            var tempEventARY = [Event]()
                            if let events = VideoData?.events {
                                for event in events {
                                    guard let eventID = event.id, let eventTime = event.t else {
                                        continue
                                    }

                                    if eventID == currentEvent.id && eventTime >= currentEventTime && eventTime <= nextEventTime {
                                        tempEventARY.append(event)
                                    }
                                }
                            }
                           
                            for j in 0..<(tempEventARY.count - 1){
                                let fEvent = tempEventARY[j]
                                let nEvent = tempEventARY[j + 1]

                                if let fEventT = fEvent.t, let eEventT = nEvent.t {
                                    let fEventTime = convertLastDigitToDecimalPoint(number: fEventT)
                                    let fStart = Double(fEventTime)

                                    let eEventTime = convertLastDigitToDecimalPoint(number: eEventT)
                                    let eEnd = Double(eEventTime)

                                    if tempTime >= fStart! && tempTime <= eEnd! {
                                        DispatchQueue.main.async {
                                            self.matchEventFrame(event: fEvent)
                                        }
                                    }

                                }

                            }

                        }
                    }

                }
            }

        }

    }
    func matchEventFrame(event : Event){
        self.checkTouchDataWithMapping(eventId: Int(event.id ?? 0), orignalEventId: Int(event.eventID ?? 0))
    }
    func checkTouchDataWithMapping(eventId:Int, orignalEventId : Int){
  
        mappingData?.mapping.flatMap { mappingData in
            mappingData.first { $0.interactiveAreaID == eventId }
        }.map { mappingObject in
            if let objectType = mappingObject.type, let entityId = mappingObject.entityID {
                if objectType == "Product" {
                   findTouchProductObject(id: entityId, eventID: eventId, orignalEventId: orignalEventId)
                } else {
                   findPersonObject(id: entityId, eventID: eventId)
                }
            }
        }
    }
    
    func findTouchProductObject(id:Int, eventID: Int, orignalEventId : Int){
        ProductVideoData?.products.flatMap { products in
            products.first { $0.id == id }
        }.map { product in
            findTouchEventForObject(id: id, product: product, eventID: eventID, orignalEventId: orignalEventId)
        }

    }
    
    func findTouchEventForObject(id:Int, product : Product, eventID: Int, orignalEventId : Int){
        VideoData?.events?.compactMap { event in
            guard let proId = event.eventID else {
                return nil
            }

            if proId == orignalEventId {
                return event
            }

            return nil
        }.forEach { validEvent in
            showProduct(id: id, eventObj: validEvent, tempProduct: product, eventID: eventID)
        }

    }
    
    func isDevicePortrait() -> Bool {
        return UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width
    }

    func isDeviceLandscape() -> Bool {
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}
//MARK :- Show Product by time
extension VideoViewController{
    
    func updateEventFrames(_ time: CMTime) {
        let currentFrame = Double(time.seconds)
        let formattedString = String(format: "%.1f", currentFrame)
        let currentDoubleSecond = Double(formattedString)
        //print("Video Current Second \(currentDoubleSecond)")
        currentVideoTime = currentDoubleSecond ?? 0
        let minTime = currentDoubleSecond!// + 1
        // let maxTime = currentDoubleSecond!
        
        if let events = VideoData?.events {
            for (_, event) in events.enumerated() {
                let eventTime = Int(event.t ?? 0)
                let formattedEventTime = convertLastDigitToDecimalPoint(number: eventTime)
                let eventTimeDouble = Double(formattedEventTime)

                if event.type?.rawValue == "I" {
//                    if eventTimeDouble! == minTime {//maxTime && eventTimeDouble! <= minTime {
//                        //print(Int(event.id ?? 0))
//                        DispatchQueue.main.async {
//                            self.checkDataWithMapping(eventId: Int(event.id ?? 0), etime: eventTime)
//                        }
//                    }
                }else{
                    if event.type?.rawValue == "O"{
                        if eventTimeDouble! == minTime {
                            self.checkDataWithMappingForRemoveItem(id: Int(event.id ?? 0), etime: eventTime)
                        }
                    }

                }
            }
        }
        
    }
    func checkDataWithMapping(eventId:Int, etime: Int){
        
        mappingData?.mapping.flatMap { mappingData in
            mappingData.first { $0.interactiveAreaID == eventId }
        }.map { mappingObject in
            if let objectType = mappingObject.type, let entityId = mappingObject.entityID {
                if objectType == "Product" {
                    findProductObject(id: entityId, etime: etime, eventID: eventId)
                } else {
                    findPersonObject(id: entityId, eventID: eventId)
                }
            }
        }
    }
    
    func findProductObject(id:Int, etime: Int, eventID: Int){
        ProductVideoData?.products.flatMap { products in
            products.first { $0.id == id }
        }.map { product in
            findEventForObject(id: id, product: product, etime: etime, eventID: eventID)
        }
        
    }
    func findEventForObject(id:Int, product : Product, etime: Int, eventID: Int){
        
        VideoData?.events?.compactMap { event in
            guard let proId = event.id, let ctime = event.t else {
                return nil
            }
            
            if proId == eventID && ctime == etime {
                return event
            }
            return nil
        }.forEach { validEvent in
            showProduct(id: id, eventObj: validEvent, tempProduct: product, eventID: eventID)
        }
        
        
    }
    func findPersonObject(id:Int, eventID : Int){
        var isfound = false
        if let foundPerson = ProductVideoData?.directors?.first(where: { $0.id == id }) {
            findPersonEventObject(id: id, person: foundPerson, eventID: eventID)
            isfound = true
        }
        
        if isfound == false{
            if let foundPerson = ProductVideoData?.actors?.first(where: { $0.id == id }) {
                findPersonEventObject(id: id, person: foundPerson, eventID: eventID)
                isfound = true
            }
        }
        
    }
    func findPersonEventObject(id:Int, person : Ctor, eventID : Int){
        if let events = VideoData?.events {
            for (_, event) in events.enumerated() {
                let ceventID = Int(event.id ?? 0)
                if ceventID == eventID{
                    //print(eventID)
                    showPerson(person: person)
                }
            }
        }
    }
    
    //MARK :- Remove Product Step
    
    func checkDataWithMappingForRemoveItem(id:Int, etime: Int){
        
        mappingData?.mapping.flatMap { mappingData in
            mappingData.first { $0.interactiveAreaID == id }
        }.map { mappingObject in
            if let objectType = mappingObject.type, let entityId = mappingObject.entityID {
                if objectType == "Product" {
                    findRemoveProductObject(id: entityId, etime: etime, eventID: id)
                } else {
                    removePerson(id: id)
                }
            }
        }
    }
    
    func findRemoveProductObject(id:Int, etime: Int, eventID: Int){
        ProductVideoData?.products.flatMap { products in
            products.first { $0.id == id }
        }.map { product in
            removeProduct(id: id, eventID: eventID, prodcut: product)
        }
        
    }
    
    func showPerson(person : Ctor){
        let image = person.mainImage?.url ?? ""
        if self.cloaseUV.isHidden == true {
            VovimageView.isHidden = true
            vovBTN.isHidden = true
        }else{
            VovimageView.isHidden = false
            vovBTN.isHidden = false
        }
        IsActor = true
        currentItemId = "\(person.id ?? 0)"
        if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            VovimageView.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
            VovimageView.contentMode = .scaleAspectFill
        }
    }
    func removePerson(id:Int){
        VovimageView.image = nil
    }
    
    func showProduct(id:Int, eventObj : Event, tempProduct : Product, eventID :Int){
        
        let imageUrl = tempProduct.mainImage?.url ?? ""
        if let encodedUrlString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            let widhth = eventObj.r?[2] ?? 0.0
            let Height = eventObj.r?[3] ?? 0.0
            let ViewX = eventObj.r?[0] ?? 0.0
            let ViewY = eventObj.r?[1] ?? 0.0
            
            let serverCoordinates = CGRect(x: ViewX, y: ViewY, width: widhth, height: Height)

            let videoHeight = VideoData?.height ?? 0
            let videoWidth = VideoData?.width ?? 0
            
            if !prodcutARYForCheck.contains(where: { $0.id == tempProduct.id }) {//isAvaialable == false{
                prodcutARYForCheck.append(tempProduct)
                var videoFrame = CGRect()
                videoFrame = playerLayer!.videoRect
                
                
                let subX = (videoFrame.width * serverCoordinates.origin.x) / CGFloat(videoWidth)
                let subY = (videoFrame.height * serverCoordinates.origin.y) / CGFloat(videoHeight)
                
                var mainX = (backgroundVideoContainer.frame.width * subX) / CGFloat(videoFrame.width) //- 30
                var mainY = (backgroundVideoContainer.frame.height * subY) / CGFloat(videoFrame.height) //- 30
                

                
                if mainX <= 0{
                    mainX = 0
                }else if mainX >= videoFrame.width{
                    mainX = videoFrame.width //- 50
                }
                
                if mainY <= videoFrame.origin.y{
                    mainY = videoFrame.origin.y + 8
                }else if mainY >= (videoFrame.height + videoFrame.origin.y){
                    mainY = (videoFrame.height + videoFrame.origin.y) //- 50
                }
                
                
                var  customView = TopImageBottomLabelView()
                customView = TopImageBottomLabelView(frame: CGRect(x: mainX, y: mainY, width: 160, height: 160))
                
                
                let deviceCoordinates = CGRect(x: mainX, y: mainY, width: 80, height: 80)
                customView.configure(image: encodedUrlString, productDic: tempProduct, Const: deviceCoordinates)
                customView.tag = id
                
                
                if self.cloaseUV.isHidden == true{
                    customView.isHidden = true
                }else{
                    customView.isHidden = true //false //anb
                }
                
                let mainDX = (backgroundVideoContainer.frame.width * subX) / CGFloat(videoFrame.width) //- 30
                let mainDY = (backgroundVideoContainer.frame.height * subY) / CGFloat(videoFrame.height) //- 30
                
                let subWidth = (serverCoordinates.size.width * videoFrame.width) / CGFloat(videoWidth)
                let subHeight = (serverCoordinates.size.height * videoFrame.height) / CGFloat(videoHeight)
                let mainWidth = (subWidth * backgroundVideoContainer.frame.width) / videoFrame.width
                let mainHeight = (subHeight * backgroundVideoContainer.frame.height) / videoFrame.height
                
                var  dotView = dotUIView()
                dotView = dotUIView(frame: CGRect(x: (mainDX + mainWidth/2), y: (mainDY + mainHeight/2), width: 60, height: 60))
        
                let deviceDotCoordinates = CGRect(x: mainDX, y: mainDY, width: 60, height: 60)
                dotView.configure(image: encodedUrlString, productDic: tempProduct, Const: deviceDotCoordinates)
                dotView.tag = id + 1000
                
//                dotView.layer.cornerRadius = 10
//                dotView.layer.borderColor = UIColor.white.cgColor
//                dotView.layer.borderWidth = 1.5
                dotView.backgroundColor = .clear
                
                
                backgroundVideoContainer.addSubview(dotView)
                backgroundVideoContainer.addSubview(customView)
                
                dotARYForCheck.append(tempProduct)
                dotCollectionView.isHidden = dotARYForCheck.isEmpty
                dotCollectionView.reloadData()
                
                if self.cloaseUV.isHidden == true{
                    dotView.isHidden = true
                }else{
                    dotView.isHidden = false
                }
                 
                let brandID = tempProduct.brandID ?? 0
                if let foundPerson = ProductVideoData?.brands?.first(where: { $0.id == brandID }) {
                    let image = (foundPerson.images?.first?.url) ?? ""
                    if cloaseUV.isHidden == true{
                        VovimageView.isHidden = true
                        vovBTN.isHidden = true
                    }else{
                        VovimageView.isHidden = false
                        vovBTN.isHidden = false
                    }
                    
                    IsActor = false
                    currentItemId = "\(brandID)"
                    if let encodedUrlString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        VovimageView.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
                    }
                }
                
                customView.tapAction = {
                    self.pauseTimer()
                    self.player!.pause()
                    //self.ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
                    self.playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
                    
//                    let viewcontroller = ProdutDetailsVC.storyboardInstance()
                    let viewcontroller = ProdutDetailsVC()
                    viewcontroller.modalPresentationStyle = .custom
                    viewcontroller.productID = "\(tempProduct.id!)"
                    viewcontroller.isfromVideo = true
                    rotate_flag = false
                    
                    let nav = UINavigationController(rootViewController: viewcontroller)
                    nav.isNavigationBarHidden = true
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                }
                
//                customView.panAction = {
//                    let targetRadius: CGFloat = 50.0 // Set your desired radius
//                    if self.isView(customView, withinRadius: targetRadius, of: self.bigCartIMG) {
//                        print("within")
//                        customView.removeFromSuperview()
//                        self.productData = tempProduct
//                        self.bigCartIMG.sd_setImage(with: URL(string: encodedUrlString), placeholderImage: placeholderImg)
//                        self.addToCart(qty: "1") { success in
//                            if success {
//                                self.bigCartIMG.isHidden = true
//                                self.addToCartMessageLBL.text = "Product was added in your cart!"
//                                self.GetCartDetail()
//                                self.acscheduleDispatch(after: 2)
//                            } else {
//
//                            }
//                        }
//                    } else {
//                        self.hideAddCartAll()
//                    }
//
//                }
                
//                customView.productDragCountinueAction = {
//                    self.cloaseUV.isHidden = false
//                    self.addtoCartBackUV.isHidden = false
//                    self.safeArayUV.isHidden = false
//                    self.viewBgSeekBar.isHidden = true
//                }
                
            }
            
        } else {
            print("Failed to encode URL string")
        }
        
    }
    
    func removeProduct(id:Int, eventID: Int, prodcut:Product){
        for subview in backgroundVideoContainer.subviews {
            
            if subview.tag == id + 1000{
                if let viewToRemove = subview.viewWithTag(id + 1000) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        viewToRemove.removeFromSuperview()
                    }
                } else {
                    print("View with tag \(id) not found.")
                }
            }
            
            // DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if subview.tag == id{
                if let viewToRemove = subview.viewWithTag(id) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        //self.acscheduleDispatch(after: 2)
                        if let index = self.dotARYForCheck.firstIndex(where: { $0.id == prodcut.id }) {
                            self.dotARYForCheck.remove(at: index)
                            self.dotCollectionView.isHidden = self.dotARYForCheck.isEmpty
                            self.dotCollectionView.reloadData()
                        }
                        
                        self.animatePositionChange(tempView: viewToRemove, tempProduct: prodcut)
                    }
                } else {
                    print("View with tag \(id) not found.")
                }
            }
            //}
        }
    }
    func animatePositionChange(tempView:UIView, tempProduct : Product) {
        

        let newX: CGFloat = 20//50 + CGFloat(self.prodcutARY.count * 50)
        let newY: CGFloat = 50 + CGFloat(self.prodcutARY.count * 50)//self.cloaseUV.frame.origin.y
        
        UIView.animate(withDuration: 1.0, animations: {
            tempView.frame.origin = CGPoint(x: newX, y: newY)
        }) { (completed) in
            if completed {
                tempView.removeFromSuperview()
                var isAvaialable = false
                
                for i in 0..<self.prodcutARY.count{
                    let pid = self.prodcutARY[i].id
                    if pid == tempProduct.id{
                        isAvaialable = true
                        break
                    }
                }
                let selectedID = tempProduct.id ?? 0
                let isAvailableInOpen = self.isOpenItemARY.contains(selectedID)
                
                if isAvaialable == false && isAvailableInOpen == true {
                    var tempProduct = tempProduct
                    let currentTimeInSeconds = CMTimeGetSeconds(self.CTTime)
                    tempProduct.updateRemoveTime(to: currentTimeInSeconds + 20.0)
                    self.prodcutARY.insert(tempProduct, at: 0)
                    self.productCV.reloadData()
                }
                
                if let index = self.isOpenItemARY.firstIndex(where: { $0 == tempProduct.id }) {
                    self.isOpenItemARY.remove(at: index)
                }

//                DispatchQueue.main.asyncAfter(deadline: .now() + 8) { // 0.01 seconds delay (10 milliseconds)
//                    if let indexToRemove = self.prodcutARY.firstIndex(where: { $0.id == tempProduct.id }) {
//                        self.prodcutARY.remove(at: indexToRemove)
//                        self.productCV.reloadData()
//                    }
//                    if let indexToRemove = self.prodcutARYForCheck.firstIndex(where: { $0.id == tempProduct.id }) {
//                        self.prodcutARYForCheck.remove(at: indexToRemove)
//
//                    }
//
//                }
                
            }
        }
    }
//    func checkIsProductNeedToRemove(){
//        let currentTimeInSeconds = CMTimeGetSeconds(self.CTTime)
//        for i in 0..<productRemoveARY.count{
//            let ctime = (productRemoveARY[i] as! NSDictionary).value(forKey: "removeTime") as! Double
//            if ctime <= currentTimeInSeconds{
//                let productID = (productRemoveARY[i] as! NSDictionary).value(forKey: "productID") as! Int
//                removeProdcutFromArrayByTime(productID: productID, indexARY: i)
//            }
//        }
//    }
    func checkIsProductNeedToRemove() {
        let currentTimeInSeconds = CMTimeGetSeconds(self.CTTime)
        for i in stride(from: prodcutARY.count - 1, through: 0, by: -1) {
            let ctime = prodcutARY[i].removeTime
            if ctime! <= currentTimeInSeconds {
                removeProdcutFromArrayByTime(productID: prodcutARY[i].id!, indexARY: i)
                self.prodcutARY.remove(at: i)
            }
        }
       self.productCV.reloadData()
    }
    func checkIsProductAvailableOnScreen(){
        var tempCount = 0
        for subview in self.backgroundVideoContainer.subviews {
            tempCount += 1
        }
        if tempCount > 0{
            if self.isProductIMG.image != UIImage(named: "ic_blueScan", in: Bundle.module, with: nil) {
                self.isProductIMG.image = UIImage(named: "ic_blueScan", in: Bundle.module, with: nil)
                if !hasAnimated{
                    self.inAnimateView()
                }
             }
        }else{
            if self.isProductIMG.image != UIImage(named: "ic_whiteScan", in: Bundle.module, with: nil) {
                self.isProductIMG.image = UIImage(named: "ic_whiteScan", in: Bundle.module, with: nil)
//                self.deAnimateView()
            }
        }
    }
    func inAnimateView() {
        //First animation: Increase the width
        hasAnimated = true
        isProdcutAvblUVWidth.constant = 225
        UIView.animate(withDuration: 2.0, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Add a 3-second delay before the second animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Second animation: Reduce the width
                self.isProdcutAvblUVWidth.constant = 75
                UIView.animate(withDuration: 2.0) {
                    self.view.layoutIfNeeded()
                }
            }
        })
    }
    func removeProdcutFromArrayByTime(productID:Int, indexARY : Int){
        if let indexToRemove = self.prodcutARYForCheck.firstIndex(where: { $0.id == productID }) {
            self.prodcutARYForCheck.remove(at: indexToRemove)
        }
    }
    func printSubviews(view: UIView, indent: String = "") {
        for subview in view.subviews {
            subview.isHidden = true //anb
            print("Hiding \(subview)")
        }
    }
    func printNotHideSubviews(view: UIView, indent: String = "") {
//        for subview in view.subviews {
//            subview.isHidden = false //anb
//            print("Unhiding \(subview)")
//        }
        
        for subview in view.subviews {
            for productID in dotARYForCheck {
                let productIDValue = productID.id ?? 0
                if subview.tag == (productIDValue + 1000) {
                    subview.isHidden = isOpenItemARY.contains(productIDValue)
                }
            }
        }
       
        for subview in view.subviews {
            for productID in dotARYForCheck {
                let productIDValue = productID.id ?? 0
                
                if subview.tag == productIDValue,
                   let viewToRemove = subview.viewWithTag(productIDValue) {
                    viewToRemove.isHidden = !isOpenItemARY.contains(productIDValue)
                }
            }
        }
    }
    func isView(_ view: UIView, withinRadius radius: CGFloat, of targetView: UIView) -> Bool {
        let viewCenter = backgroundVideoContainer.convert(view.center, from: view.superview)
        let targetCenter = backgroundVideoContainer.convert(targetView.center, from: targetView.superview)
        
        let distance = sqrt(pow(viewCenter.x - targetCenter.x, 2) + pow(viewCenter.y - targetCenter.y, 2))
        
        return distance <= radius
    }
}
extension VideoViewController {
    
    func GetEntitiesDetail(id:String){
        
        let headers: HTTPHeaders = [
            "Authorization": AuthToken ,
            "content-type": "application/json;charset=UTF-8"
        ]
        
        start_loading()
        self.get_api_request("\(BaseURLOffice)video/\(id)/entities\(loadContents)", headers: headersCommon).responseDecodable(of: ProductVideoModel.self) { response in
           //             print(response)
            if response.error != nil {
                //self.ShowAlert(title: "Error", message: response.error?.localizedDescription ?? "Something Went Wrong")
            }else{
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(ProductVideoModel.self, from: responseData)
                        self.ProductVideoData = welcome
                     } catch {
                       // self.ShowAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                    }
                }else{
                   // self.ShowAlert(title: "Error", message: "Something Went Wrong")
                }
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    
    func GetProductMappingDetail(productmappingID : Int){
        
        let headers: HTTPHeaders = [
            "Authorization": AuthToken
        ]
        start_loading()
        self.get_api_request("\(BaseURLOffice)product-mapping/\(productmappingID)\(loadContents)", headers: headersCommon).responseDecodable(of: MappingDataModel.self) { response in
           // print(response.result)
            switch response.result {
            case .success:
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(MappingDataModel.self, from: responseData)
                        self.mappingData = welcome
                    } catch {
                        //self.ShowAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
               // self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
                print("\(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    
    func GetVideoDetail(id:String){
        
        let headers: HTTPHeaders = [
            "Authorization": AuthToken ,
            "content-type": "application/json;charset=UTF-8"
        ]
        
        var params = [String : Any]()
        params["operatorId"] = "1"
        
//        if id == "22"{
//            params["cachedScreeningFileId"] = "7"
//        }else{
//            params["cachedScreeningFileId"] = "3"
//        }
        
     //   print(params)
        self.post_api_request_withJson("\(BaseURLOffice)video/\(id)\(loadContents)", params: params, headers: headersCommon).responseDecodable(of: VideoDataModel.self) { response in
            //           print(response)
            if response.error != nil {
                //self.ShowAlert(title: "Error", message: response.error?.localizedDescription ?? "Something Went Wrong")
            }else{
                if let responseData = response.data {
                    do {
                        let welcome = try JSONDecoder().decode(VideoDataModel.self, from: responseData)
                        self.isFirst = false
                        self.VideoData = welcome
                        let productmappingID = self.VideoData?.screeningFile?.productMappingID ?? 0
                        self.GetProductMappingDetail(productmappingID: productmappingID)
                        self.getStatusList()
                    } catch {
                        //self.ShowAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                    }
                    
                }else{
                    //self.ShowAlert(title: "Error", message: "Something Went Wrong")
                }
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
    func getStatusList() {
        filterEventData = Dictionary(grouping: VideoData?.events ?? [], by: { String($0.id ?? 0) })
        for (processStatus, models) in filterEventData {
            let filteredModels = models.filter {
                $0.type != .empty && $0.id != nil && $0.t != nil && $0.type != nil
            }
            let sortedModels = filteredModels.sorted { (model1, model2) in
                return (model1.t ?? 0) < (model2.t ?? 0)
            }
//            if processStatus == "3" {
//                print("Sorted Models: \(sortedModels)")
//            }
            filterEventData[processStatus] = sortedModels
        }
    }
    func GetCartDetail(){
        start_loading()
        APIManager.shared.getCartDetail(userID: UserID) { result in
            switch result {
            case .success(let cartData):
                self.cartData = cartData
                self.cartCountBTN.setTitle("\(self.cartData?.count ?? 0)", for: .normal)
            case .failure(let error):
               // self.ShowAlert(title: "Error", message: "\(error.localizedDescription)")
                print("\(error)")
            }
            DispatchQueue.main.async {
                self.stop_loading()
            }
        }
    }
}


import UIKit

class TopImageBottomLabelView: UIView {
    var Cordi: CGRect?
    var tapAction: (() -> Void)?
    var panAction: (() -> Void)?
    var productDragCountinueAction: (() -> Void)?
    
    func isDevicePortrait() -> Bool {
        return UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width
    }

    func isDeviceLandscape() -> Bool {
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
    
    let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
       // view.layer.borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1).cgColor
        //view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
        view.tag = 120
        view.layer.borderWidth = 1.5
        return view
    }()
    
    let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let labelsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 1
        
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 1
        return label
    }()
    
    let PriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.numberOfLines = 1
        label.backgroundColor = .black
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupGesture()
    }
    
    private func commonInit() {
        // Add the content view
        addSubview(contentView)
        
        // Add the top image view to the content view
        contentView.addSubview(topImageView)
        
        // Add the labels container view to the content view
        contentView.addSubview(labelsContainerView)
        contentView.addSubview(PriceLabel)
        
        // Add both labels to the labels container view
        labelsContainerView.addSubview(bottomLabel)
        labelsContainerView.addSubview(descLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        PriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if isDevicePortrait() {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Cordi?.origin.x ?? 0.0),
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: Cordi?.origin.y ?? 0.0),
                contentView.widthAnchor.constraint(equalTo: widthAnchor, constant: Cordi?.size.width ?? 0.0),
                contentView.heightAnchor.constraint(equalTo: heightAnchor, constant: Cordi?.size.height ?? 0.0 + 20),
                
                topImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                topImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                topImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                topImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
                
                PriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                PriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
                PriceLabel.widthAnchor.constraint(equalToConstant: 80),
                PriceLabel.heightAnchor.constraint(equalToConstant: 40),
                
                labelsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  4),
                labelsContainerView.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 4),
                labelsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -4),
                labelsContainerView.heightAnchor.constraint(equalToConstant: 0),
                
                bottomLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor),
                bottomLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor,constant: 0),
                bottomLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor),
                bottomLabel.heightAnchor.constraint(equalToConstant: 0),
                
                descLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor),
                descLabel.topAnchor.constraint(equalTo: bottomLabel.topAnchor,constant: 15),
                descLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor),
                descLabel.heightAnchor.constraint(equalToConstant: 0),
            ])
        }else{
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Cordi?.origin.x ?? 0.0),
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: Cordi?.origin.y ?? 0.0),
                contentView.widthAnchor.constraint(equalTo: widthAnchor, constant: Cordi?.size.width ?? 0.0),
                contentView.heightAnchor.constraint(equalTo: heightAnchor, constant: Cordi?.size.height ?? 0.0 + 20),
                
                topImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                topImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                topImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                topImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant:  -30),
                
                PriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                PriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -35),
                PriceLabel.widthAnchor.constraint(equalToConstant: 60),
                PriceLabel.heightAnchor.constraint(equalToConstant: 30),
                
                labelsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  4),
                labelsContainerView.topAnchor.constraint(equalTo: topImageView.bottomAnchor),
                labelsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -4),
                labelsContainerView.heightAnchor.constraint(equalToConstant: 30),
                
                bottomLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor),
                bottomLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor,constant: 0),
                bottomLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor),
                bottomLabel.heightAnchor.constraint(equalToConstant: 30),
                
                descLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor),
                descLabel.topAnchor.constraint(equalTo: bottomLabel.topAnchor,constant: 15),
                descLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor),
                descLabel.heightAnchor.constraint(equalToConstant: 0),
            ])
        }
        
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: view.superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gestureRecognizer.setTranslation(.zero, in: view.superview)
        
        if gestureRecognizer.state == .ended {
            panAction?()
        }else{
            productDragCountinueAction?()
        }
        
    }
    @objc private func viewTapped() {
        // Handle tap action here
        tapAction?()
        // You can perform any action you want when the view is tapped
    }
    
    func configure(image: String, productDic: Product, Const: CGRect) {
        topImageView.sd_setImage(with: URL(string: image), placeholderImage: placeholderImg)
        topImageView.contentMode = .scaleAspectFit
        bottomLabel.text = productDic.name ?? ""
        descLabel.text = productDic.brandName ?? ""
        PriceLabel.text = "$\(productDic.productSkus?.first?.price ?? 0)"
        Cordi = Const
        setupConstraints()
        
    }
}

class dotUIView: UIView {
    var Cordi: CGRect?
    var tapAction: (() -> Void)?
    var panAction: (() -> Void)?
    //var productDragCountinueAction: (() -> Void)?
    

    let dotView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        //view.layer.borderColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1).cgColor
       // view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .clear//UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
        //view.layer.borderWidth = 1.5
        view.image = UIImage(named: "ic_hotspot", in: Bundle.module, with: nil)
        view.tag = 115
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.layer.cornerRadius = 10
//        self.layer.borderColor = UIColor.white.cgColor
//        self.backgroundColor = UIColor(red: 58/255, green: 171/255, blue: 242/255, alpha: 1)
//        self.layer.borderWidth = 1.5
        
        commonInit()
        setupGesture()
    }
    
    private func commonInit() {
        // Add the content view
        addSubview(dotView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        dotView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Cordi?.origin.x ?? 0.0),
            dotView.topAnchor.constraint(equalTo: topAnchor, constant: Cordi?.origin.y ?? 0.0),
            dotView.widthAnchor.constraint(equalTo: widthAnchor, constant: Cordi?.size.width ?? 0.0),
            dotView.heightAnchor.constraint(equalTo: heightAnchor, constant: Cordi?.size.height ?? 0.0),

        ])
        
        
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: view.superview)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gestureRecognizer.setTranslation(.zero, in: view.superview)
        
        if gestureRecognizer.state == .ended {
            panAction?()
        }else{
          //  productDragCountinueAction?()
        }
        
    }
    @objc private func viewTapped() {
        tapAction?()
    }
    
    func configure(image: String, productDic: Product, Const: CGRect) {
        Cordi = Const
        setupConstraints()
    }
}

extension VideoViewController {
    
    func addToCart(qty: String, completion: @escaping (Bool) -> Void) {
        guard let personDict = convertToDictionary(self.productData),
              let skuDict = convertToDictionary(self.productData?.productSkus?[0]),
              let shippingDict = convertToDictionary(self.productData?.shippings?[0]) else {
            completion(false)
            return
        }

        let params: [String: Any] = [
            "count": qty,
            "price": "\(productData?.productSkus?[0].price ?? 0)",
            "product": personDict,
            "projectId": projectID,
            "shipping": shippingDict,
            "agreement": 1,
            "sku": skuDict
        ]

       // print(params)
        start_loading()
        self.post_api_request_withJson("\(BaseURLOffice)cart/users/\(UserID)/products", params: params, headers: headersCommon).responseJSON { response in
            //print(response.result)
            DispatchQueue.main.async {
                self.stop_loading()
            }

            if response.response?.statusCode == 404 {
                DispatchQueue.main.async {
                    if let json = response.value as? [String: Any],
                       let message = json["message"] as? String {
                        self.ShowAlert(title: "Error", message: message)
                    } else {
                        self.ShowAlert(title: "Error", message: "Not found. The resource doesn't exist.")
                    }
                    completion(false)
                }
                return
            }

            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.ShowAlert(title: "Error", message: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
}

extension VideoViewController {
    
    func smallVideoPlayer() {
        
//        let url = URL(string: smallVideoString)
//        let playerItem1: AVPlayerItem = AVPlayerItem(url: url!)
//        splayer = AVPlayer(playerItem: playerItem1)
//        splayerLayer = AVPlayerLayer(player: splayer)
//        splayerLayer?.videoGravity = .resizeAspect
//
//        self.smallVideoUV.layer.addSublayer(splayerLayer!)
        
        
//        splayer?.play()
        self.configrationSmallVideoView()
     }
    
    func checkVOVAvailable(currentFrame: Int) {
        guard let vovs = VideoData?.vovs else {
            smallVideoUV.isHidden = true
            return
        }
        
        var isShow = false
        var shortVideoData: Vov?
        
        for cvov in vovs {
            guard let startFrame = cvov.startFrame, let endFrame = cvov.endFrame else {
                continue
            }
            
            if currentFrame >= startFrame && currentFrame <= endFrame {
                isShow = true
                shortVideoData = cvov
                break // Exit loop early since we found a matching VOV
            }
        }
        
        if isShow {
            if let videoURL = shortVideoData?.relatedProjects?.first?.videoURL {
                smallVideoString = videoURL
                smallVideoPlayer()
                if productCV.isHidden == true{
                    smallVideoUV.isHidden = true
                }else{
                    smallVideoUV.isHidden = false
                }
            } else {
                smallVideoUV.isHidden = true
            }
        } else {
            smallVideoUV.isHidden = true
        }
    }
    
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60) // Capture the thumbnail at the 1-second mark
        DispatchQueue.global().async {
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func getLiveVideoFrameCount(url: URL, completion: @escaping (Int?) -> Void) {
        let asset = AVURLAsset(url: url)
        
        // Load the asset asynchronously to get properties like duration and tracks
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"]) {
            var durationInSeconds: Double = 0
            var frameRate: Float = 0
            
            // Retrieve duration
            var error: NSError?
            let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
            if durationStatus == .loaded {
                durationInSeconds = CMTimeGetSeconds(asset.duration)
            } else {
                print("Failed to load duration:", error?.localizedDescription ?? "Unknown error")
            }
            
            // Retrieve frame rate
            let trackKey = "tracks"
            let tracksStatus = asset.statusOfValue(forKey: trackKey, error: &error)
            if tracksStatus == .loaded {
                if let videoTrack = asset.tracks(withMediaType: .video).first {
                    frameRate = videoTrack.nominalFrameRate
                }
            } else {
                print("Failed to load tracks:", error?.localizedDescription ?? "Unknown error")
            }
            
            // Calculate estimated frame count
            var estimatedFrameCount: Int?
            if frameRate > 0 && durationInSeconds > 0 {
                estimatedFrameCount = Int(durationInSeconds * Double(frameRate))
            }
            
            // Return the result on the main queue
            DispatchQueue.main.async {
                completion(estimatedFrameCount)
            }
        }
    }
    
}
