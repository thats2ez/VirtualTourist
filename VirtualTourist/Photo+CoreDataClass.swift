//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/14/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
public class Photo: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)
        super.init(entity: entity!, insertInto: context)
        self.photoURL = photoURL
        self.pin = pin
    }
    
    var image : UIImage? {
        if imagePath != nil {
            let fileURL = getFileURL()
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    // MARK: - Private
    
    private func getFileURL() -> URL {
        let filename = (imagePath! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray : [String] = [dirPath, filename]
        let fileURL = NSURL.fileURL(withPathComponents: pathArray)
        return fileURL!
    }
}
