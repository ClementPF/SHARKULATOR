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
    @NSManaged var scratched : Bool
    @NSManaged var winnerScore : Float
    @NSManaged var loserScore : Float
    @NSManaged var value : Float
    @NSManaged var date : Date
    @NSManaged var titleGame : Bool
    @NSManaged var titleHolder : Player
    
    func encodeWithCoder(_ aCoder: NSCoder!) {
        aCoder.encode(winner, forKey:kWinner)
        aCoder.encode(loser, forKey:kLoser)
        aCoder.encode(loser, forKey:kBreaker)
        aCoder.encode(value, forKey:kValue)
        aCoder.encode(date, forKey:kDate)
        aCoder.encode(loserScore, forKey:kLoserScore)
        aCoder.encode(winnerScore, forKey:kWinnerScore)
        aCoder.encode(scratched, forKey:kScratched)
        aCoder.encode(titleGame, forKey:kTitleGame)
        aCoder.encode(titleHolder, forKey:kTitleHolder)
    }
    
    convenience init(Match entity: NSEntityDescription,
                insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertInto: context)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = Date()
    }
    
    var formattedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.string(from: self.date)
        }
    }
}
