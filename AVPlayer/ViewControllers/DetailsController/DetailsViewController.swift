//
//  DetailsViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/28/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit
import Photos

class DetailsViewController: UIViewController {
    
    var podcastImage: UIImage?
    var podcastAuthor: String = ""
    var podcastDuration: String = ""
    var podcastPubDate: String = ""
    var podcastTitle: String = ""
    var podcastDescription: String = ""
    var podcastURL: String = ""
    
    @IBOutlet weak var podcastStreamButton: UIButton!
    @IBOutlet weak var podcastDownloadButton: UIButton!
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var podcastAuthorLabel: UILabel!
    @IBOutlet weak var podcastDurationLabel: UILabel!
    @IBOutlet weak var podcastPubDateLabel: UILabel!
    @IBOutlet weak var podastIsDownloadedLabel: UILabel!
    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var podcastDescriptionLabel: UILabel!
    
    @IBAction func downloadResourceAction(_ sender: Any) {
        podcastDownloadButton.setTitle("Downloading...", for: .normal)
        downloadVideoLinkAndCreateAsset(podcastURL)
    }
    
    @IBAction func streamAudio(_ sender: Any) {
        if podcastURL.last != "4" {
            performSegue(withIdentifier: "showAudioPlayer", sender: self)
        } else {
            performSegue(withIdentifier: "presentResource", sender: self)
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
                                        self.performSelector(onMainThread: #selector(self.videoWasDownloadedHandler), with: nil, waitUntilDone: false)
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
    
    @objc func videoWasDownloadedHandler() {
        podastIsDownloadedLabel.text = "downloaded"
        podcastDownloadButton.isHidden = true
        podcastStreamButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "presentResource" {
            let destinationVC: VideoViewController = segue.destination as! VideoViewController
            destinationVC.videoURL = podcastURL
        } else if segue.identifier == "showAudioPlayer" {
            let destinationVC: AudioPlayerViewController = segue.destination as! AudioPlayerViewController
            destinationVC.audioURL = podcastURL
            destinationVC.podcstPlayerImage = podcastImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        podcastImageView.layer.cornerRadius = podcastImageView.frame.width / 2
        podcastImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let videoURL = URL(string: podcastURL) else {
            return
        }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        if FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            podastIsDownloadedLabel.text = "downloaded"
            podcastDownloadButton.isHidden = true
        } else {
            podastIsDownloadedLabel.text = "not downloaded"
            podcastDownloadButton.isHidden = false
        }
        
        if let image = podcastImage {
            podcastImageView.image = image
        }
        
        podcastAuthorLabel.text = podcastAuthor
        podcastDurationLabel.text = podcastDuration
        podcastPubDateLabel.text = podcastPubDate
        podcastTitleLabel.text = podcastTitle
        podcastDescriptionLabel.text = podcastDescription
    }
    
}
