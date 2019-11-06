//
//  UserPodcastsViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/28/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit
import Photos

class UserPodcastsViewController: UITableViewController {

    let VIDEO_CELL_IDENTIFIER: String = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts.removeAll()
        getAssetFromPhoto()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VIDEO_CELL_IDENTIFIER, for: indexPath) as! PodcastTableViewCell

        let asset = podcasts[indexPath.row]
        let width: CGFloat = 500
        let height: CGFloat = 500
        let size = CGSize(width:width, height:height)
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, userInfo) -> Void in
        cell.videoImageView.image = image
        cell.videoTitleLabel.text = "Title"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            podcasts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "playVideoFromCameraRoll", sender: self)
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideoFromCameraRoll" {
            let destinationVC: CaptureVideoViewController = segue.destination as! CaptureVideoViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
               
                let asset = podcasts[indexPath.row]
                guard(asset.mediaType == PHAssetMediaType.video)
                    else {
                        print("Not a valid video media type")
                        return
                    }
                
                PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (avAsset, audioMix, info) in
                    let asset = avAsset as!AVURLAsset
                    print(asset.url)
                    destinationVC.videoURL = asset.url.absoluteString
                }
            }
        }
    }
    
    //MARK: - Photos
    
    var podcasts = [PHAsset]()
    
    func getAssetFromPhoto() {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let photos = PHAsset.fetchAssets(with: options)
        photos.enumerateObjects { (asset, idx, stop) in
            self.podcasts.append(asset)
        }
    }

    //MARK: - SetUp's
    
    func setUpTableView() {
        self.tableView.decelerationRate = .normal
        self.tableView.separatorStyle = .none
        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: VIDEO_CELL_IDENTIFIER)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
    }
}
