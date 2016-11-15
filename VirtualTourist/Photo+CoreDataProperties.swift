//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/14/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imagePath: String?
    @NSManaged public var photoURL: String?
    @NSManaged public var pin: Pin?

}
