//
//  Match.swift
//  ELO
//
//  Created by clement perez on 4/11/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import CoreData

@objc(Match)
class Match : NSManagedObject {
    
    @NSManaged var winner : Player
    @NSManaged var loser : Player
    @NSManaged var breaker : Player
    @NSManaged var winnerScore : Float
    @NSManaged var loserScore : Float
    @NSManaged var value : Float
    @NSManaged var date : NSDate
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(winner, forKey:kWinner)
        aCoder.encodeObject(loser, forKey:kLoser)
        aCoder.encodeObject(loser, forKey:kBreaker)
        aCoder.encodeObject(value, forKey:kValue)
        aCoder.encodeObject(date, forKey:kDate)
        aCoder.encodeObject(loserScore, forKey:kLoserScore)
        aCoder.encodeObject(winnerScore, forKey:kWinnerScore)
    }
    
    convenience init(Match entity: NSEntityDescription,
                insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
    
    var formattedDate: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.stringFromDate(self.date)
        }
    }
}