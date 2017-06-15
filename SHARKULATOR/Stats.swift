//
//  Stats.swift
//  SHARKULATOR
//
//  Created by clement perez on 7/29/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import CoreData

@objc(Stats)
class Stats : NSManagedObject {
    @NSManaged var bestScore : Float
    @NSManaged var gamesCount : Float
    @NSManaged var winCount : Float
    @NSManaged var loseCount : Float
    @NSManaged var tieCount : Float
    @NSManaged var winStreak : Float
    @NSManaged var loseStreak : Float
    @NSManaged var longestWinStreak : Float
    @NSManaged var longestLoseStreak : Float
    @NSManaged var scratchCount : Float
    @NSManaged var opponentScratchCount : Float
    @NSManaged var titleHolder : Bool
    
    func encodeWithCoder(_ aCoder: NSCoder!) {
        aCoder.encode(bestScore, forKey:kBestScore)
        aCoder.encode(winCount, forKey:kWinCount)
        aCoder.encode(loseCount, forKey:kLoseCount)
        aCoder.encode(tieCount, forKey:kTieCount)
        aCoder.encode(gamesCount, forKey:kGamesCount)
        aCoder.encode(winStreak, forKey:kWinStreak)
        aCoder.encode(loseStreak, forKey:kLoseStreak)
        aCoder.encode(longestWinStreak, forKey:kLongestWinStreak)
        aCoder.encode(longestLoseStreak, forKey:kLongestLoseStreak)
        aCoder.encode(scratchCount, forKey:kScratchCount)
        aCoder.encode(opponentScratchCount, forKey:kOpponentScratchCount)
        aCoder.encode(titleHolder, forKey:kTitleHolder)
    }
    
    convenience init(Stats entity: NSEntityDescription,
                            insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertInto: context)
        
    }
    
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        if key == kWinCount {
            self.gamesCount+=1
            self.winStreak+=1
            self.loseStreak = Float.init(0.0)
        }
        else if key == kLoseCount {
            self.gamesCount+=1
            self.loseStreak+=1
            self.winStreak = Float.init(0.0)
        }
        else if key == kTieCount {
            self.gamesCount+=1
            //self.tieCount+=1
        }
        else if key == kWinStreak {
            var ws = Float.init(0.0)
            ws = self.winStreak
            var lws = Float.init(0.0)
            lws = self.longestWinStreak
            if self.winStreak > self.longestWinStreak {
                self.longestWinStreak = self.winStreak
            }
        }
        else if key == kLoseStreak {
            if self.loseStreak > self.longestLoseStreak {
                self.longestLoseStreak = self.loseStreak
            }
        }
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.bestScore = kdefaultELO
        //self.gamesCount = 0
        //self.winStreak = 0
        //self.longestWinStreak = 0
        //self.loseStreak = 0
        //self.longestLoseStreak = 0
    }
    
    /*
     init (coder aDecoder: NSCoder!) {
     self.name = aDecoder.decodeObjectForKey(kName) as! String
     self.score = aDecoder.decodeObjectForKey(kScore) as! Float
     }*/
}
