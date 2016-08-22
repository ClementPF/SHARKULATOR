//
//  ScoresBoard.swift
//  ELO
//
//  Created by clement perez on 3/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import CoreData

let kPath:String = "/scoretable.plist"

class ScoresBoard {
    
    var players: [Player] = []
    var matchs: [Match] = []
    
    var managedContext : NSManagedObjectContext = NSManagedObjectContext.new()
    
    class var sharedInstance: ScoresBoard {
        struct Static {
            static var instance: ScoresBoard?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ScoresBoard()
        }
        
        return Static.instance!
    }
    
    func sortByELOAscending(){
        players.sortInPlace({ $0.score > $1.score})
    }
    
    func restore( appDelegate : AppDelegate){
        
        managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Player")
        let fetchRequest2 = NSFetchRequest(entityName: "Match")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let results2 = try managedContext.executeFetchRequest(fetchRequest2)
            players = results as! [Player]
            matchs = results2 as! [Match]
            
            sortByELOAscending()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func store(appDelegate : AppDelegate){
        do {
            try managedContext.save()
        }catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        sortByELOAscending()
    }
    
    func addPlayerWithName(name: String, appDelegate : AppDelegate){
        
        addPlayerWithName(name, score: 1000, appDelegate: appDelegate)
    }
    
    func addPlayerWithName(name: String, score: Float, appDelegate : AppDelegate){
        
        let entity =  NSEntityDescription.entityForName("Player", inManagedObjectContext:managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        
        let entityStats =  NSEntityDescription.entityForName("Stats", inManagedObjectContext:managedContext)
        let stats = NSManagedObject(entity: entityStats!, insertIntoManagedObjectContext: managedContext)
        
        person.setValue(name.capitalizeFirst, forKey: kName)
        person.setValue(score, forKey: kScore)
        person.setValue(false, forKey: kIsRetired)
        person.setValue(stats, forKey: kStats)
        do {
            try managedContext.save()
            players.append(person as! Player)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        sortByELOAscending()
    }
    
    func addMatch(winner: Player, loser: Player, breaker: Player, scratch: Bool, appDelegate : AppDelegate){
        
        let entity =  NSEntityDescription.entityForName("Match", inManagedObjectContext:managedContext)
        let match = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        match.setValue(winner, forKey:kWinner)
        match.setValue(loser, forKey:kLoser)
        match.setValue(breaker, forKey:kBreaker)
        match.setValue(winner.score, forKey:kWinnerScore)
        match.setValue(loser.score, forKey:kLoserScore)
        match.setValue(scratch, forKey:kScratched)
        
        let matchValue = ELOCalculator.getMatchValue(winner.score, loserScore: loser.score)
        
        ELOCalculator.calculateEloRating(&winner.score,loserScore: &loser.score) //changes the values
        
        var stats = winner.valueForKey(kStats)
        stats!.setValue(((stats?.valueForKey(kWinCount))! as! Int) + 1, forKey: kWinCount)
        var stats2 = loser.valueForKey(kStats)
        stats2!.setValue(((stats2?.valueForKey(kLoseCount))! as! Int) + 1, forKey: kLoseCount)
        
        match.setValue(matchValue, forKey:kValue)
        do {
            try managedContext.save()
            matchs.append(match as! Match)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getMatchsForUser(player: Player) -> [Match]{
    
        var fetchRequest = NSFetchRequest(entityName: "Match")
        //fetchRequest.fetchLimit = 20
        fetchRequest.predicate = NSPredicate(format: "winner == %@ OR loser == %@ ", player,player)
        
        do {
            var fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Match]
            fetchedEntities.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending})
            return fetchedEntities;
            // Do something with fetchedEntities
        } catch {
            // Do something in response to error condition
        }
        return []
    }
        
    func removeMatch(match: Match){
        
        do {
            managedContext.deleteObject(match);
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            // Do something with fetchedEntities
        } catch {
            // Do something in response to error condition
        }
    }
    
    func isPlayerNameValid(name : String) -> Bool{
        return !name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty
    }
    
    func playerWithName(name : String) -> Player{
        let trimmedName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for player in players{
            let playerName = player.valueForKey(kName) as! String
            if(playerName.caseInsensitiveCompare(trimmedName) == NSComparisonResult.OrderedSame){
                return player
            }
        }
        assert(false)
    }
    
    func containsPlayerWithName(name : String) -> Bool{
        let trimmedName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for player in players{
            let playerName = player.valueForKey(kName) as! String
            if(playerName.caseInsensitiveCompare(trimmedName) == NSComparisonResult.OrderedSame){
                return true
            }
        }
        return false
    }
}