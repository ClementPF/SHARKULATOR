//
//  Player.swift
//  ELO
//
//  Created by clement perez on 3/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import CoreData

@objc(Player)
class Player : NSManagedObject {
    @NSManaged var name : String
    @NSManaged var score : Float
    @NSManaged var bestScore : Float
    @NSManaged var isRetired : Bool
    @NSManaged var stats : Stats
    
    func encodeWithCoder(_ aCoder: NSCoder!) {
        aCoder.encode(name, forKey:kName)
        aCoder.encode(score, forKey:kScore)
        aCoder.encode(bestScore, forKey:kBestScore)
        aCoder.encode(isRetired, forKey:kIsRetired)
        aCoder.encode(stats, forKey:kStats)
    }
    
    convenience init(Player entity: NSEntityDescription,
                insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertInto: context)

    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        
        if key == kScore {
            if self.score > self.stats.bestScore {
                stats.setValue(score, forKey:kBestScore)
            }
        }
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.score = kdefaultELO
        self.isRetired = false
    }

  /*
    init (coder aDecoder: NSCoder!) {
        self.name = aDecoder.decodeObjectForKey(kName) as! String
        self.score = aDecoder.decodeObjectForKey(kScore) as! Float
    }*/
}
