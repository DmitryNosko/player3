//
//  CoreDataController.swift
//  AVPlayer
//
//  Created by USER on 11/7/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AVPlayer")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let url = documentsDirectory?.appendingPathComponent("AVPlayer.sqlite")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url!)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    let podcastName = "Item"
    
    func addFeedItem(item: PodcastItem) {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: podcastName, into: self.persistentContainer.viewContext)
        newItem.setValue(item.identifier, forKey: "identifier")
        newItem.setValue(item.itemIsDownloaded, forKey: "isDownloaded")
        newItem.setValue(item.itemAuthor, forKey: "itemAuthor")
        newItem.setValue(item.itemDescription, forKey: "itemDescription")
        newItem.setValue(item.itemDuration, forKey: "itemDuration")
        newItem.setValue(item.itemImage, forKey: "itemImage")
        newItem.setValue(item.itemPubDate, forKey: "itemPubDate")
        newItem.setValue(item.itemTitle, forKey: "itemTitle")
        newItem.setValue(item.itemURL, forKey: "itemURL")
        do {
            try self.persistentContainer.viewContext.save()
            print("saved item \(item)")
        } catch {
            print(error)
        }
    }
    
    func deleteAllFeedItems() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: podcastName)
        //fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                self.persistentContainer.viewContext.delete(objectData)
                print("deleted object = \(object)")
            }
        } catch let error {
            print("Detele all data in \(podcastName) error :", error)
        }
    }
    
    func deletedItems() -> [PodcastItem] {
        var deleted = [PodcastItem]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: podcastName)
        request.predicate = NSPredicate(format: "itemAuthor = %@", "Patrick Chappatte")
        request.returnsObjectsAsFaults = false
        do {
            let result = try persistentContainer.viewContext.fetch(request)
            for data in result as! [NSManagedObject] {
                let deletedItem = PodcastItem(identifier: data.value(forKey: "identifier") as! UUID, itemTitle: data.value(forKey: "itemTitle") as! String, itemDescription: data.value(forKey: "itemDescription") as! String, itemPubDate: data.value(forKey: "itemPubDate") as! String, itemDuration: data.value(forKey: "itemDuration") as! String, itemURL: data.value(forKey: "itemURL") as! String, itemImage: data.value(forKey: "itemImage") as! String, itemAuthor: data.value(forKey: "itemAuthor") as! String, itemIsDownloaded: (data.value(forKey: "isDownloaded") != nil))
                deleted.append(deletedItem)
            }
        } catch {
            print("Failed")
        }
        
        return deleted
    }
    
}


