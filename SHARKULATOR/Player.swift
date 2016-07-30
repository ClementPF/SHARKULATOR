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
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(name, forKey:kName)
        aCoder.encodeObject(score, forKey:kScore)
        aCoder.encodeObject(bestScore, forKey:kBestScore)
        aCoder.encodeObject(isRetired, forKey:kIsRetired)
        aCoder.encodeObject(stats, forKey:kStats)
    }
    
    convenience init(Player entity: NSEntityDescription,
                insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)

    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key)
        
        if key == kScore {
            if self.score > self.stats.bestScore {
                stats.bestScore = score
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