//
//  VideoPlayerTableViewCell.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/23/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit

let FATAL_ERROR_MESSAGE = "init(coder:) has not been implemented"

class PodcastTableViewCell: UITableViewCell {
    
    var videoTitle: String?
    var videoTitleLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.font = UIFont(name: "Futura-Bold", size: 19)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        return textLabel
    }()
    
    var videoImage: UIImage?
    var videoImageView: CustomImageView = {
       var imgView = CustomImageView()
        imgView.backgroundColor = UIColor.lightGray
        imgView.layer.cornerRadius = 20
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    var item: RSSVideoItem! {
        didSet {
            videoTitle = item.itemTitle
            videoImageView.loadImageUsingURLString(string: item.itemImage)
        }
    }

    override func prepareForReuse() {
        self.videoTitleLabel.text = ""
        self.videoImageView.image = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(videoImageView)
        self.addSubview(videoTitleLabel)
        setUpViewsConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let title = videoTitle {
            videoTitleLabel.text = title
        }
        if let image = videoImage {
            videoImageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(FATAL_ERROR_MESSAGE)
    }
    
    func setUpViewsConstraints() -> Void {
        videoImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        videoImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        videoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        videoImageView.bottomAnchor.constraint(equalTo: self.videoTitleLabel.topAnchor, constant: -5).isActive = true
        videoImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        videoTitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        videoTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        videoTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }

}

