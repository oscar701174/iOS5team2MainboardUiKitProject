//
//  VideoEntity+CoreDataClass.swift
//  iOS5team2MainboardUiKit
//
//  Created by Cheon on 11/14/25.
//

import UIKit
import CoreData

class VideoEntity: NSManagedObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }
}
