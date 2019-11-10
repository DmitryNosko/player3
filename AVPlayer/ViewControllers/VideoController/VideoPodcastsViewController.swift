//
//  VideoPlayerViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/23/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit

class VideoPodcastsViewController: UITableViewController {

    let VPVC_TITLE: String = "Video Podcasts"
    let TED_TALKS_VIDEO_RESOURCE_URL: String = "https://feeds.feedburner.com/tedtalks_video"
    let VIDEO_CELL_IDENTIFIER: String = "Cell"
    
    private var displayedVideoItems: [PodcastItem]?
    private var videoItem: PodcastItem?
    let feedParser = FeedParser()
    let coreDataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = VPVC_TITLE
        setUpTableView()
        setUpNavigationItem()
        displayedVideoItems = [PodcastItem]()
        
        feedParser.itemDownloadedHandler = { (videoItem) in
            self.addParsedFeedItemToFeeds(item: videoItem)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        coreDataManager.deleteAllFeedItems()
        feedParser.parseFeed(url: TED_TALKS_VIDEO_RESOURCE_URL)
        
        feedParser.parserDidEndDocumentHandler = {() in
            print("parserDidEndDocumentHandler")
            self.coreDataManager.deletedItems()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let videoItems = displayedVideoItems else {
            return 0
        }
        return videoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VIDEO_CELL_IDENTIFIER, for: indexPath) as! PodcastTableViewCell
        
        if let item = displayedVideoItems?[indexPath.row] {
            cell.item = item
        }
        cell.layoutSubviews()
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                displayedVideoItems?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetails" {
            let destinationVC: DetailsViewController = segue.destination as! DetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    let customCell = cell as? PodcastTableViewCell
                    if let item = customCell!.item {
                        destinationVC.podcastImage = customCell!.videoImageView.image
                        destinationVC.podcastTitle = item.itemTitle
                        destinationVC.podcastDescription = item.itemDescription
                        destinationVC.podcastPubDate = item.itemPubDate
                        destinationVC.podcastDuration = item.itemDuration
                        destinationVC.podcastAuthor = item.itemAuthor
                        destinationVC.podcastURL = item.itemURL
                    }
                }
            }
        }
    }
    
    // Mark: - SetUp's
    
    func setUpTableView() {
        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: VIDEO_CELL_IDENTIFIER)
        self.tableView.estimatedRowHeight = 200
    }
    
    func setUpNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
    }
    
    @objc func refreshData() {
        self.displayedVideoItems?.removeAll()
        feedParser.parseFeed(url: TED_TALKS_VIDEO_RESOURCE_URL)
    }
    
    //MARK: - Block's
    
    func addParsedFeedItemToFeeds(item: PodcastItem) {
        coreDataManager.addFeedItem(item: item)
        displayedVideoItems?.append(item)
    }
    
}
















