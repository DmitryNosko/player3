//
//  XMLParser.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/23/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import Foundation
import UIKit

let EMPTY_STRING = ""

struct PodcastItem {
    var identifier: UUID
    var itemTitle: String
    var itemDescription: String
    var itemPubDate: String
    var itemDuration: String
    var itemURL: String
    var itemImage: String
    var itemAuthor: String
    var itemIsDownloaded: Bool
}

class FeedParser: NSObject, XMLParserDelegate {
    
    
    private var rssItems: [PodcastItem] = []
    private var currentElement = EMPTY_STRING
    private var currentTitle: String = EMPTY_STRING {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = EMPTY_STRING {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String = EMPTY_STRING {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = EMPTY_STRING {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDuration: String = EMPTY_STRING {
        didSet {
            currentDuration = currentDuration.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentVideoURL: String = EMPTY_STRING {
        didSet {
            currentVideoURL = currentVideoURL.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentImage: String = EMPTY_STRING {
        didSet {
            currentImage = currentImage.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentAuthor: String = EMPTY_STRING {
        didSet {
            currentAuthor = currentAuthor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    var itemDownloadedHandler: ((PodcastItem) -> Void)?
    var parserDidEndDocumentHandler: (() -> Void)?
    
    func parseFeed(url: String) {
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = EMPTY_STRING
            currentImage = EMPTY_STRING
            currentPubDate = EMPTY_STRING
            currentDescription = EMPTY_STRING
            currentDuration = EMPTY_STRING
            currentAuthor = EMPTY_STRING
        } else if  currentElement == "itunes:image" {
            if let image = attributeDict["href"] {
                currentImage = image
            }
        } else if currentElement == "media:content" {
            if let url = attributeDict["url"] {
                currentVideoURL = url
            }
        } else if currentElement == "enclosure" {
            if let url = attributeDict["url"] {
                currentVideoURL = url
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title" : currentTitle += string
            case "itunes:summary" : currentDescription += string
            case "pubDate" : currentPubDate += string
            case "itunes:image" : currentImage += string
            case "itunes:duration" : currentDuration += string
            case "itunes:author" : currentAuthor += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = PodcastItem(identifier:UUID(), itemTitle: currentTitle, itemDescription: currentDescription, itemPubDate: currentPubDate, itemDuration: currentDuration, itemURL: currentVideoURL, itemImage: currentImage, itemAuthor: currentAuthor, itemIsDownloaded: false)
            itemDownloadedHandler?(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserDidEndDocumentHandler?()
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
