//
//  VideoViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/30/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit
import AVFoundation

extension CMTime {
    
    func durationTexForTime(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

class VideoViewController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoURL: String = ""
    
    //MARK: - playerElements
    
    let controlsContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    let pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.isHidden = true
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    let videoLenghtLable: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currentTimeLable: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.white
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    let cancelVideoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "cancel")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    //MARK: - VCLifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpPlayerView(url: videoURL)
        controlsContainerView.frame = self.view.bounds
        self.view.addSubview(controlsContainerView)
        configerateControlsContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPlaying()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    //MARK: - Selectors
    var isPlaying = false
    
    @objc func handlePause() {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    @objc func handleSliderChange() {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
            })
        }
    }
    
    @objc func handleCancel() {
        player.pause()
        dismiss(animated: true) {
        }
    }
    
//    var lastPlayedTimeToFloat: Float
//    var lastPlayedTime: CMTime
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        lastPlayedTime = player.currentTime()
//        lastPlayedTimeToFloat = Float(CMTimeGetSeconds(player.currentTime()))
//    }
    
    //MARK: - Player
    
    func startPlaying() {
//        if lastPlayedTimeToFloat != 0 {
//            player.seek(to: lastPlayedTime)
//        } else {
            player.play()
        //}
        
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            
            let time = CMTime()
            let seconds = CMTimeGetSeconds(progressTime)
            let totalSeconds = time.durationTexForTime(time: progressTime)
            self.currentTimeLable.text = "\(totalSeconds)"
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
    }
    
    var counter = 0
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = UIColor.clear
            
            if counter == 0 {
                pausePlayButton.isHidden = true
                videoSlider.isHidden = true
                currentTimeLable.isHidden = true
                videoLenghtLable.isHidden = true
                cancelVideoButton.isHidden = true
                isPlaying = true
                counter += 1
            }
            
            if let duration = player?.currentItem?.duration {
                let time = CMTime()
                let totalSeconds = time.durationTexForTime(time: duration)
                videoLenghtLable.text = "\(totalSeconds)"
            }
        }
    }
    
    //MARK: - PlayerConfig
    
    func configerateControlsContainerView() {
        controlsContainerView.addSubview(activityIndicatorView)
        controlsContainerView.addSubview(pausePlayButton)
        controlsContainerView.addSubview(videoLenghtLable)
        controlsContainerView.addSubview(videoSlider)
        controlsContainerView.addSubview(currentTimeLable)
        controlsContainerView.addSubview(cancelVideoButton)
        
        setUpPauseButtonContraints()
        setUpActivityIndicatorConstraints()
        setUpVideoLenghtLabelConstraints()
        setUpVideoSliderConstraints()
        setUpCurrentTimeLableConstraints()
        setCancelVideoButtonContraints()
    }
    
    private func setUpPlayerView(url: String) {
        if let url = NSURL(string: url) {
            player = AVPlayer(url: url as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resize
            videoView.layer.addSublayer(playerLayer)
        }
    }
    
    //MARK: - touches
    var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(hideAllButtons),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stop(){
        if(timer != nil){timer!.invalidate()}
    }
    
    // Timer expects @objc selector
    @objc func hideAllButtons() {
        pausePlayButton.isHidden = true
        videoSlider.isHidden = true
        currentTimeLable.isHidden = true
        videoLenghtLable.isHidden = true
        cancelVideoButton.isHidden = true
        stop()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("BeganTouch")
        if pausePlayButton.isHidden == true {
            pausePlayButton.isHidden = false
            videoSlider.isHidden = false
            currentTimeLable.isHidden = false
            videoLenghtLable.isHidden = false
            cancelVideoButton.isHidden = false
            startTimer()
        } else {
            pausePlayButton.isHidden = true
            videoSlider.isHidden = true
            currentTimeLable.isHidden = true
            videoLenghtLable.isHidden = true
            cancelVideoButton.isHidden = true
        }
    }
    
    //MARK: Constraints
    
    private func setUpActivityIndicatorConstraints() {
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    private func setUpPauseButtonContraints() {
        pausePlayButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setUpVideoLenghtLabelConstraints() {
        videoLenghtLable.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        videoLenghtLable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        videoLenghtLable.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLenghtLable.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    private func setUpVideoSliderConstraints() {
        videoSlider.rightAnchor.constraint(equalTo: videoLenghtLable.safeAreaLayoutGuide.leftAnchor, constant: -8).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLable.safeAreaLayoutGuide.rightAnchor, constant: 8).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setUpCurrentTimeLableConstraints() {
        currentTimeLable.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        currentTimeLable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        currentTimeLable.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLable.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    private func setCancelVideoButtonContraints() {
        cancelVideoButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -8).isActive = true
        cancelVideoButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        cancelVideoButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
        cancelVideoButton.heightAnchor.constraint(equalToConstant: 65).isActive = true
    }
}

