//
//  HallOfFameViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HallOfFameViewController: UIViewController,  NSFetchedResultsControllerDelegate , UITableViewDelegate, UITableViewDataSource {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    var player : Player!
    var matchs : [Match] = []
    
    @IBOutlet weak var highestScoreLabel : UILabel!
    @IBOutlet weak var longestChampion : UILabel!
    @IBOutlet weak var currentChampion : UILabel!
    @IBOutlet weak var longestWinStreak : UILabel!
    @IBOutlet weak var longestLooseStreak : UILabel!
    @IBOutlet weak var totalGames : UILabel!
    @IBOutlet weak var breakStats: UILabel!
    @IBOutlet weak var tableMatch : UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let champion = getPlayerWithHighestScore()
        let player = getPlayerWithCurrentHighestScore()
        
        currentChampion.text = "Current champion " + player.name + " with " + player.score.description
        highestScoreLabel.text = "All time champion " + champion.name + " with " + champion.stats.bestScore.description
        
        displayLonguestWinStreak()
        displayBreakStats()
        displayLonguestLoseStreak()
        
        totalGames.text = scoresBoard.matchs.count.description
    }
    
    func getPlayerWithHighestScore()-> Player{
        //need date
        //need player
        //need score
        var topPlayer = scoresBoard.players[0]
        for player in scoresBoard.players{
            if(player.stats.bestScore > topPlayer.stats.bestScore){
                topPlayer = player
            }
        }
        return topPlayer
    }
    
    func getPlayerWithCurrentHighestScore()-> Player{
        var topPlayer = scoresBoard.players[0]
        for player in scoresBoard.players{
            if(player.score > topPlayer.score){
                topPlayer = player
            }
        }
        return topPlayer
    }
    
    func displayLonguestWinStreak(){
    
        var topPlayer = scoresBoard.players[0]
        
        var winStreakGlobal = 0
        for player in scoresBoard.players{
            var ws = getLongestStreakForPlayer(player, forWins: true)
            if(ws > winStreakGlobal){
                winStreakGlobal = ws
                topPlayer = player
            }else{
            
            }
        }
        
        longestWinStreak.text = "Longest winning streak of " + winStreakGlobal.description + " wins by " + topPlayer.name
    }
    
    func displayLonguestLoseStreak(){
        
        var topPlayer = scoresBoard.players[0]
        
        var loseStreakGlobal = 0
        for player in scoresBoard.players{
            var ws = getLongestStreakForPlayer(player, forWins: false)
            if(ws > loseStreakGlobal){
                loseStreakGlobal = ws
                topPlayer = player
            }
        }
        
        longestLooseStreak.text = "Longest loosing streak of " + loseStreakGlobal.description + " losses by " + topPlayer.name
    }
    
    func displayBreakStats(){
        var i = 0
        var total = 0
        for match in scoresBoard.matchs{
            if(match.winner == match.breaker){
                i += 1
            }
            if(match.breaker == match.winner || match.breaker == match.loser){
                total += 1
            }
        }
        
        let ratio = (Float (i) / Float (total))*100
        if(total != 0){
            breakStats.text = "Breaker wins " + round(ratio).description + "% of the games."
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getLongestStreak(forWins : Bool)-> Player{
        
        var topPlayer = scoresBoard.players[0]
        
        var winStreakGlobal = 0
        for player in scoresBoard.players{
            var ws = getLongestStreakForPlayer(player, forWins: forWins)
            if(ws > winStreakGlobal){
                winStreakGlobal = ws
            }
        }
        
        longestWinStreak.text = winStreakGlobal.description
        //longestLooseStreak.text = loseStreakPlayer.description
        
        return topPlayer
    }
    
    func getLongestStreakForPlayer(player : Player, forWins : Bool)-> Int{
        
        var winStreakPlayer = 0
        var loseStreakPlayer = 0
        var winStreakLoop = 0
        var loseStreakLoop = 0
        
        for match in scoresBoard.getMatchsForUser(player){
            if(match.winner == player){
                winStreakLoop += 1
                loseStreakLoop = 0
                if(winStreakPlayer < winStreakLoop){
                    winStreakPlayer = winStreakLoop
                }
            }else if(match.loser == player){
                loseStreakLoop += 1
                winStreakLoop = 0
                if(loseStreakPlayer < loseStreakLoop){
                    loseStreakPlayer = loseStreakLoop
                }
            }
        }
        
        return forWins ? winStreakPlayer : loseStreakPlayer
    }
    
    
    // MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects > 20 ? 20 : sectionInfo.numberOfObjects
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    
    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        return (self.fetchedResultsController.objectAtIndexPath(NSIndexPath.init(forRow: 0, inSection: section))as! Match).formattedDate
        /*
        switch(section)
        {
        case 0:return "Today's games"
            break
        default :return "Previous games"
            break
        }*/
        
        
    }
    
    func tableView(tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat{
        switch(section)
        {
        case 1:return 30
            break
        default :return 30
            break
        }
    }
    
    func tableView(tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat{
        return CGFloat.min
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        NSFetchedResultsController.deleteCacheWithName(nil);
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDel.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Match", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: kDate, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "formattedDate", cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func tableView(tableView: UITableView,
                   editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return []
    }
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let match = object as! Match
        
        var winnerName =  match.winner.name
        var looserName =  match.loser.name
        let value = round(match.value).description
        
        winnerName.replaceRange(winnerName.startIndex...winnerName.startIndex, with: String(winnerName[winnerName.startIndex]).capitalizedString)
        looserName.replaceRange(looserName.startIndex...looserName.startIndex, with: String(looserName[looserName.startIndex]).capitalizedString)
        
        var winText = " Won "
        winText = winText + (match.scratched ? scratchSign + " " : "")
        
        if(match.titleGame){
            let isTitleTransfered = match.titleHolder != match.winner
            
            winText = winText + "& " +
                (isTitleTransfered ? successChallengedTitle : successDefendTitle)
        }else{
            winText = winText + "against ";
        }
        
        cell.textLabel!.text =  winnerName + winText + looserName
        cell.detailTextLabel!.text =  value
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
}
