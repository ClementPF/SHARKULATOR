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
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
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
            let ws = getLongestStreakForPlayer(player, forWins: true)
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
            let ws = getLongestStreakForPlayer(player, forWins: false)
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
    
    @IBAction func close(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func getLongestStreak(_ forWins : Bool)-> Player{
        
        let topPlayer = scoresBoard.players[0]
        
        var winStreakGlobal = 0
        for player in scoresBoard.players{
            let ws = getLongestStreakForPlayer(player, forWins: forWins)
            if(ws > winStreakGlobal){
                winStreakGlobal = ws
            }
        }
        
        longestWinStreak.text = winStreakGlobal.description
        //longestLooseStreak.text = loseStreakPlayer.description
        
        return topPlayer
    }
    
    func getLongestStreakForPlayer(_ player : Player, forWins : Bool)-> Int{
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects > 20 ? 20 : sectionInfo.numberOfObjects
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            
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
    
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        return (self.fetchedResultsController.object(at: IndexPath.init(row: 0, section: section))as! Match).formattedDate
        /*
        switch(section)
        {
        case 0:return "Today's games"
            break
        default :return "Previous games"
            break
        }*/
        
        
    }
    
    func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat{
        switch(section)
        {
        case 1:return 30
            break
        default :return 30
            break
        }
    }
    
    func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat{
        return CGFloat.leastNormalMagnitude
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil);
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDel.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Match", in: self.managedObjectContext!)
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
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return []
    }
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let match = object as! Match
        
        var winnerName =  match.winner.name
        var looserName =  match.loser.name
        let value = round(match.value).description
        
        winnerName.replaceSubrange(winnerName.startIndex...winnerName.startIndex, with: String(winnerName[winnerName.startIndex]).capitalized)
        looserName.replaceSubrange(looserName.startIndex...looserName.startIndex, with: String(looserName[looserName.startIndex]).capitalized)
        
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
