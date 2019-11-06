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

struct RSSVideoItem {
    var itemTitle: String
    var itemDescription: String
    var itemLink: String
    var itemPubDate: String
    var itemDuration: String
    var itemVideoURL: String
    var itemAudioURL: String
    var itemImage: String
    var itemAuthor: String
}

class FeedParser: NSObject, XMLParserDelegate {
    
    
    private var rssItems: [RSSVideoItem] = []
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
    private var currentAudioURL: String = EMPTY_STRING {
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
            currentImage = currentImage.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var parserComplitionHandler: (([RSSVideoItem]) -> Void)?
    
    func parseFeed(url: String, complitionHandler: (([RSSVideoItem]) -> Void)?) {
        self.parserComplitionHandler = complitionHandler
        
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
            currentLink = EMPTY_STRING
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
                currentAudioURL = url
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title" : currentTitle += string
            case "itunes:summary" : currentDescription += string
            case "link" : currentLink += string
            case "pubDate" : currentPubDate += string
            case "itunes:image" : currentImage += string
            case "itunes:duration" : currentDuration += string
            case "itunes:author" : currentAuthor += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSVideoItem(itemTitle: currentTitle, itemDescription: currentDescription, itemLink: currentLink, itemPubDate: currentPubDate, itemDuration: currentDuration, itemVideoURL: currentVideoURL, itemAudioURL: currentAudioURL, itemImage: currentImage, itemAuthor: currentAuthor)
            self.rssItems.append(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserComplitionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
