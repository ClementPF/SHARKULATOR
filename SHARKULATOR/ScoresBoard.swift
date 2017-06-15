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
    
    var managedContext : NSManagedObjectContext =  NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    
    static let sharedInstance = ScoresBoard()
    private init() {}
    
    
    func sortByELOAscending(){
        players.sort(by: { $0.score > $1.score})
    }
    
    func restore( _ appDelegate : AppDelegate){
        
        managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Match")
        do {
            let results = try managedContext.fetch(fetchRequest)
            let results2 = try managedContext.fetch(fetchRequest2)
            players = results as! [Player]
            matchs = results2 as! [Match]
            
            sortByELOAscending()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func store(_ appDelegate : AppDelegate){
        do {
            try managedContext.save()
        }catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        sortByELOAscending()
    }
    
    func addPlayerWithName(_ name: String, appDelegate : AppDelegate){
        
        addPlayerWithName(name, score: 1000, appDelegate: appDelegate)
    }
    
    func addPlayerWithName(_ name: String, score: Float, appDelegate : AppDelegate){
        
        let entity =  NSEntityDescription.entity(forEntityName: "Player", in:managedContext)
        let person = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        
        let entityStats =  NSEntityDescription.entity(forEntityName: "Stats", in:managedContext)
        let stats = NSManagedObject(entity: entityStats!, insertInto: managedContext)
        
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
    
    func addMatch(_ winner: Player, loser: Player, breaker: Player, scratch: Bool, appDelegate : AppDelegate){
        
        addMatch(winner, loser: loser, breaker: breaker, scratch: scratch, titleGame: false, appDelegate: appDelegate)
    }
    
    func addMatch(_ winner: Player, loser: Player, breaker: Player, scratch: Bool, titleGame: Bool, appDelegate : AppDelegate){
        
        let entity =  NSEntityDescription.entity(forEntityName: "Match", in:managedContext)
        let match = NSManagedObject(entity: entity!, insertInto: managedContext)
        match.setValue(winner, forKey:kWinner)
        match.setValue(loser, forKey:kLoser)
        match.setValue(breaker, forKey:kBreaker)
        match.setValue(winner.score, forKey:kWinnerScore)
        match.setValue(loser.score, forKey:kLoserScore)
        match.setValue(scratch, forKey:kScratched)
        match.setValue(titleGame, forKey:kTitleGame)
        if(titleGame){
            match.setValue(winner.stats.titleHolder ? winner : loser, forKey:kTitleHolder)
        }
        
        var matchValue = ELOCalculator.getMatchValue(winner.score, loserScore: loser.score)
        
        if(titleGame && winner.stats.titleHolder){
            matchValue = matchValue * 2
        }
        
        winner.setValue(winner.score + matchValue, forKey: kScore)
        loser.setValue(loser.score - matchValue, forKey: kScore)
        
        var stats = winner.value(forKey: kStats) as AnyObject
        stats.setValue(((stats.value(forKey: kWinCount))! as! Int) + 1, forKey: kWinCount)
        var stats2 = loser.value(forKey: kStats) as AnyObject
        stats2.setValue(((stats2.value(forKey: kLoseCount))! as! Int) + 1, forKey: kLoseCount)
        
        if(scratch){
            stats.setValue(((stats.value(forKey: kOpponentScratchCount))! as! Int) + 1, forKey: kOpponentScratchCount)
            stats2.setValue(((stats2.value(forKey: kScratchCount))! as! Int) + 1, forKey: kScratchCount)
        }
        if(titleGame){
            stats.setValue(true, forKey: kTitleHolder)
            stats2.setValue(false, forKey: kTitleHolder)
        }
        
        match.setValue(matchValue, forKey:kValue)
        do {
            try managedContext.save()
            matchs.append(match as! Match)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getMatchsForUser(_ player: Player) -> [Match]{
    
        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Match")
        //fetchRequest.fetchLimit = 20
        fetchRequest.predicate = NSPredicate(format: "winner == %@ OR loser == %@ ", player,player)
        
        do {
            var fetchedEntities = try managedContext.fetch(fetchRequest) as! [Match]
            fetchedEntities.sort(by: { $0.date.compare($1.date) == .orderedDescending})
            return fetchedEntities;
            // Do something with fetchedEntities
        } catch {
            // Do something in response to error condition
        }
        return []
    }
        
    func removeMatch(_ match: Match){
        
        do {
            managedContext.delete(match);
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
    
    func isPlayerNameValid(_ name : String) -> Bool{
        return !name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    func playerWithName(_ name : String) -> Player{
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespaces)
        for player in players{
            let playerName = player.value(forKey: kName) as! String
            if(playerName.caseInsensitiveCompare(trimmedName) == ComparisonResult.orderedSame){
                return player
            }
        }
        let playerNil:Player? = nil
        return playerNil!
    }
    
    func containsPlayerWithName(_ name : String) -> Bool{
        let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespaces)
        for player in players{
            let playerName = player.value(forKey: kName) as! String
            if(playerName.caseInsensitiveCompare(trimmedName) == ComparisonResult.orderedSame){
                return true
            }
        }
        return false
    }
}
