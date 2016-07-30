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
    @NSManaged var gamesCount : Int
    @NSManaged var winCount : Int
    @NSManaged var loseCount : Int
    @NSManaged var tieCount : Int
    @NSManaged var winStreak : Int
    @NSManaged var loseStreak : Int
    @NSManaged var longestWinStreak : Int
    @NSManaged var longestLoseStreak : Int
    @NSManaged var scratchCount : Int
    @NSManaged var opponentScratchCount : Int
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(bestScore, forKey:kBestScore)
        aCoder.encodeObject(winCount, forKey:kWinCount)
        aCoder.encodeObject(loseCount, forKey:kLoseCount)
        aCoder.encodeObject(tieCount, forKey:kTieCount)
        aCoder.encodeObject(gamesCount, forKey:kGamesCount)
        aCoder.encodeObject(winStreak, forKey:kWinStreak)
        aCoder.encodeObject(loseStreak, forKey:kLoseStreak)
        aCoder.encodeObject(longestWinStreak, forKey:kLongestWinStreak)
        aCoder.encodeObject(longestLoseStreak, forKey:kLongestLoseStreak)
        aCoder.encodeObject(scratchCount, forKey:kScratchCount)
        aCoder.encodeObject(opponentScratchCount, forKey:kOpponentScratchCount)
    }
    
    convenience init(Stats entity: NSEntityDescription,
                            insertIntoManagedObjectContext context: NSManagedObjectContext?){
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
    
    override func didChangeValueForKey(key: String) {
        super.didChangeValueForKey(key)
        /*
        if key == kWinCount {
            self.gamesCount+=1
            self.winCount+=1
            if(loseStreak == 0){
                winStreak+=1
            }
            else{
                loseStreak = 0
            }
        }
        else if key == kLoseCount {
            gamesCount+=1
            loseCount+=1
            if(winStreak == 0){
                loseStreak+=1
            }
            else{
                winStreak = 0
            }
        }
        else if key == kTieCount {
            gamesCount+=1
            tieCount+=1
        }
        else if key == kLoseCount {
            if self.winStreak > self.longestWinStreak {
                self.longestWinStreak = self.winStreak
            }
        }
        else if key == kWinStreak {
            if self.winStreak > self.longestWinStreak {
                self.longestWinStreak = self.winStreak
            }
        }
        else if key == kLoseStreak {
            if self.loseStreak > self.longestLoseStreak {
                self.longestLoseStreak = self.loseStreak
            }
        }
       */
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
