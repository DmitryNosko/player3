//
//  CaptureVideoViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 11/4/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CaptureVideoViewController: UIViewController {

    
    @IBOutlet weak var videoView: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoURL: String = ""
    
    //MARK: - playerElements
    
    let controlsContainerView: UIView = {
        let view = UIView()
        return view
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
    
    let saveVideoButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "saveBLACK")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    //MARK: - VCLifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setUpPlayerView(url: videoURL)
//        controlsContainerView.frame = self.view.bounds
//        self.view.addSubview(controlsContainerView)
//        configerateControlsContainerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpPlayerView(url: videoURL)
        controlsContainerView.frame = self.view.bounds
        self.view.addSubview(controlsContainerView)
        configerateControlsContainerView()
        startPlaying()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if playerLayer != nil {
            playerLayer.frame = videoView.bounds
        }
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
    
    @objc func handleSave() {
        downloadVideoLinkAndCreateAsset(videoURL)
        dismiss(animated: true) {
        }
    }
    
    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) {
                (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                    } else {
                                        print("error to load video")
                                    }
                            }
                        }
                    })
                } catch { print(error) }
                }.resume()
            
        } else {
            print("File already exists at destination url")
        }
        
    }
    
    @objc func handleCancel() {
        player.pause()
        dismiss(animated: true) {
        }
    }
    
    //MARK: - Player
    
    func startPlaying() {
        player.play()
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
            controlsContainerView.backgroundColor = UIColor.clear
            
            if counter == 0 {
                pausePlayButton.isHidden = true
                videoSlider.isHidden = true
                currentTimeLable.isHidden = true
                videoLenghtLable.isHidden = true
                cancelVideoButton.isHidden = true
                saveVideoButton.isHidden = true
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
        controlsContainerView.addSubview(pausePlayButton)
        controlsContainerView.addSubview(videoLenghtLable)
        controlsContainerView.addSubview(videoSlider)
        controlsContainerView.addSubview(currentTimeLable)
        controlsContainerView.addSubview(cancelVideoButton)
        controlsContainerView.addSubview(saveVideoButton)
        
        setUpPauseButtonContraints()
        setUpVideoLenghtLabelConstraints()
        setUpVideoSliderConstraints()
        setUpCurrentTimeLableConstraints()
        setCancelVideoButtonContraints()
        setSaveVideoButtonContraints()
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
    
    @objc func hideAllButtons() {
        pausePlayButton.isHidden = true
        videoSlider.isHidden = true
        currentTimeLable.isHidden = true
        videoLenghtLable.isHidden = true
        cancelVideoButton.isHidden = true
        saveVideoButton.isHidden = true
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
            saveVideoButton.isHidden = false
            startTimer()
        } else {
            pausePlayButton.isHidden = true
            videoSlider.isHidden = true
            currentTimeLable.isHidden = true
            videoLenghtLable.isHidden = true
            cancelVideoButton.isHidden = true
            saveVideoButton.isHidden = true
        }
    }
    
    //MARK: Constraints
    
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
        cancelVideoButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        cancelVideoButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }

    private func setSaveVideoButtonContraints() {
        saveVideoButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        saveVideoButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        saveVideoButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        saveVideoButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
}
