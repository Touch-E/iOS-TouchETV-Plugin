//
//  VovVC.swift
//  
//
//  Created by Jaydip Godhani on 30/01/25.
//

import UIKit
import AVKit
import Alamofire
import AVFoundation

class VovVC: UIViewController {

    static func storyboardInstance() -> VovVC {
        return mainStoryboard.instantiateViewController(withIdentifier: "VovVC") as! VovVC
    }
    
    var VideoString = ""
    var VideoListDic : HomeListModel?
    var player:AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem:AVPlayerItem?
    var sliderDragToPlayPause = false
    var isShown = false
    var timer: Timer?
    var elapsedTime: TimeInterval = 0.0
    var CTTime = CMTime()
    var productIDArray = [Int]()
    var RRect : CGRect?
    var brandID = ""
    var tempARY = [String]()
    var currentVideoTime : Double = 0.0
    var videoTouchPoint = CGPoint()
    var filterEventData = [String? : [Event]]()
    var currentVolumeValue:Float = 0.0
    var dispatchWorkItem: DispatchWorkItem?

    var IsActor = false
    var currentItemId = ""
    var isVideoCompeted = false
    
    @IBOutlet weak var ButtonPlay: UIButton!
    @IBOutlet weak var lblOverallDuration: UILabel!
    @IBOutlet weak var viewBgSeekBar: UIView!
    @IBOutlet weak var playbackSlider: TvOSSlider!
    @IBOutlet weak var backgroundVideoContainer: UIView!
    @IBOutlet weak var cloaseUV: UIView!
    @IBOutlet weak var videoTitleLB: UILabel!
    @IBOutlet weak var playIMG: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = Bundle.module.loadNibNamed("VovVC", owner: self, options: nil)?.first as? UIView {
            self.view = view
        }
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.videoTitleLB.text = self.VideoListDic?.name ?? ""
            self.start_loading()
            self.pastVideoPlayer()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = self.backgroundVideoContainer.bounds
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        playIMG.image = UIImage(named: "play", in: Bundle.module, with: nil)
        pauseTimer()
        player!.pause()
    
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateVideoDetail), userInfo: nil, repeats: true)
    }
    
    @objc func updateVideoDetail() {
        elapsedTime += 0.5
       
    }
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        // Check if the timer is not already running
        if timer == nil {
            startTimer()
            print("Timer resumed")
        }
    }
    
    func stopTimer() {
        // Stop the timer when needed (e.g., when the view controller is about to be deallocated)
        timer?.invalidate()
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
            //ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
            playIMG.image = UIImage(named: "pause", in: Bundle.module, with: nil)
            resumeTimer()
        } else {
            player!.pause()
           // ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
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
        //rotate_flag = false
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
    
    func pastVideoPlayer() {
        
        let url = URL(string: VideoString)
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        self.backgroundVideoContainer.layer.addSublayer(playerLayer!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        // Add playback slider
        playbackSlider.minimumValue = 0
        
        playbackSlider.addTarget(self, action: #selector(VovVC.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        playbackSlider.isContinuous = true
        playbackSlider.tintColor = UIColor.white
        
        start_loading()
        
        if self.sliderDragToPlayPause == false {
            player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { (CMTime) -> Void in
                if self.player!.currentItem?.status == .readyToPlay {
                    let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                    self.playbackSlider.value = Float ( time );
                    //self.lblcurrentText.text = self.stringFromTimeInterval(interval: time)
                    if (time > 0) {
                        self.CTTime = CMTime
                        self.updateFrames(CMTime)
                        self.stop_loading()
                    }
                }
                
                self.playbackSlider.isContinuous = true
                let duration : CMTime = playerItem.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                self.lblOverallDuration.text = self.stringFromTimeInterval(interval: seconds)
                self.playbackSlider.maximumValue = Float(seconds)
                
                let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
                if playbackLikelyToKeepUp == false{
                    //debugPrint("IsBuffering")
                } else {
                   // debugPrint("Buffering completed")
                }
            }
            player?.play()
          //  ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
            playIMG.image = UIImage(named: "pause", in: Bundle.module, with: nil)
            startTimer()
            
            
            
            // Added For vloume
            player!.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: nil)
            player!.volume = 0.5

        }
    }
   
    // Observer method to handle player status changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        if keyPath == #keyPath(AVPlayer.status) {
            // When player status changes to ready to play, start playing the audio
            if player!.status == .readyToPlay {
                player!.play()
            }
        }
    }
    
   
    func cancelDispatch() {
        if let workItem = dispatchWorkItem {
            workItem.cancel()
        }
    }

                    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
//        ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
//        playbackSlider.setValue(0, animated: true)
//        playbackSliderValueChanged(playbackSlider)
        
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
        backgroundVideoContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func convertLastDigitToDecimalPoint(number: Int) -> String {
        var numberString = String(number)
        if let lastCharacter = numberString.last {
            numberString = String(numberString.dropLast()) + "." + String(lastCharacter)
        }
        return numberString
    }
}
