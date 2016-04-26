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
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(name, forKey:kName)
        aCoder.encodeObject(score, forKey:kScore)
        aCoder.encodeObject(bestScore, forKey:kBestScore)
    }
    
    convenience init(Player entity: NSEntityDescription,
                insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)

    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key)
        
        if key == kScore {
            if self.score > self.bestScore {
                bestScore = score
            }
        }
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.score = kdefaultELO
        self.bestScore = kdefaultELO
    }

  /*
    init (coder aDecoder: NSCoder!) {
        self.name = aDecoder.decodeObjectForKey(kName) as! String
        self.score = aDecoder.decodeObjectForKey(kScore) as! Float
    }*/
}