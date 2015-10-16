//
//  Word+CoreDataProperties.swift
//  Dictionary words
//
//  Created by Alexsander  on 10/13/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Word {

    @NSManaged var wordOriginal: String?
    @NSManaged var wordTranslation: String?
    @NSManaged var wordDate: NSDate?

}
