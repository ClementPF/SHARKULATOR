//
//  DetailViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate , UITableViewDelegate, UITableViewDataSource {

    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var scoreBoard : ScoresBoard = ScoresBoard.sharedInstance
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var scoreLabel : UILabel!
    @IBOutlet weak var positionLabel : UILabel!
    @IBOutlet weak var bestScoreLabel : UILabel!
    @IBOutlet weak var tableMatch : UITableView!
    @IBOutlet weak var totalGames: UIButton!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var worstEnemy: UILabel!
    @IBOutlet weak var bestEnemy: UILabel!
    @IBOutlet weak var scratchRatio: UILabel!
    
    var playerMatchs : [Match] = []

    var player: Player? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let player = self.player {
            if let label = self.nameLabel {
                label.text = player.name
            }
            if let label = self.scoreLabel {
                label.text = "Score : " + (player.score).description
            }
            if let label = self.positionLabel {
                label.text = "Position : " + String(scoreBoard.players.indexOf(player)! + 1)
            }
            if let label = self.bestScoreLabel {
                label.text = "Best score : " + (player.bestScore).description
            }
            
            playerMatchs = scoreBoard.getMatchsForUser(player)
            
            displayRatios() // win loss ratio and scratch ratio
            displayWorstEnemy()
        }
    }

    @IBAction func displayTotalGame(sender: UIButton) {
        let numberOfGames = scoreBoard.getMatchsForUser(player!).count
        sender.setTitle(String(numberOfGames), forState: UIControlState.Normal)
        sender.selected = !sender.selected
    }
    
    
    func displayRatios() {
        
        var wins = 0
        var ratioPerc : Float = 0
        
        var scratchs = 0
        var scratchsPerc : Float = 0
        
        for match in playerMatchs{
            // calculate the win loss ratio
            if(player == match.winner){
                wins = wins + 1
            }
            else if(match.scratched){  // calculate the scratchs ratio
                scratchs = scratchs + 1
            }
        }
        
        ratioPerc = (Float (wins) / Float (playerMatchs.count))*100
        scratchsPerc = (Float (scratchs) / Float (playerMatchs.count))*100
        
        if let label = self.ratio {
            label.text = "Winning ratio of : " + String(format: "%.1f", ratioPerc) + "%"
        }
        if let label = self.scratchRatio {
            label.text = scratchs > 2 ? String(format: "%d", scratchs) + " scratchs and counting" : String(format: "%d", scratchs) + " scratch"
        }
    }
    
    func displayWorstEnemy() {
        
        var opponents = NSMutableDictionary()
        
        var wins = 0
        var ratioPerc : Float = 0
        
        for match in playerMatchs{
            var opponent = player == match.winner ? match.loser.name : match.winner.name
            var pointSumForUser = opponents[opponent]
            
            if (pointSumForUser == nil) {
                opponents[opponent] = 0
                pointSumForUser = 0
            }
            
            if(player == match.winner){
                pointSumForUser = pointSumForUser as! Float + match.value
            }else{
                pointSumForUser = pointSumForUser as! Float - match.value
            }
            
            opponents[opponent] = pointSumForUser
        }
        
        var mostPointLost = 0 as! Float
        var mostPointWon = 0 as! Float
        var worstEnemyName = ""
        var bestEnemy = ""
        
        
        for (opponentName, sum) in opponents {
            if(mostPointLost > sum as! Float){
                mostPointLost = sum as! Float
                worstEnemyName = opponentName as! String
            }
            if(mostPointWon < sum as! Float){
                mostPointWon = sum as! Float
                bestEnemy = opponentName as! String
            }
        }
        
        if let label = self.worstEnemy {
            label.text = "Your Shark is " + worstEnemyName + " with a total of " + String(format: "%.0f", round(mostPointLost as! Float)) + " points " + (mostPointLost < 0 ? "lost" : "won")
        }
        if let label = self.bestEnemy {
            label.text = "Your Fish is " + bestEnemy + " with a total of " + String(format: "%.0f", round(mostPointWon as! Float)) + " points " + (mostPointWon > 0 ? "won" : "lost")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.view.addGestureRecognizer(longPressRecognizer)
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return player == nil ? 0 : self.fetchedResultsController.sections?.count ?? 0
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        let numberOfGames = sectionInfo.numberOfObjects
        return sectionInfo.numberOfObjects > 10 ? 10 : sectionInfo.numberOfObjects
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
        fetchRequest.predicate = NSPredicate(format: "winner == %@ OR loser == %@ ", self.player!, self.player!)
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: kDate, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableMatch.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableMatch.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete: break
            //self.tableMatch.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableMatch.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete: break
            //tableMatch.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableMatch.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
        case .Move:
            tableMatch.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func tableView(tableView: UITableView,
                            editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return []
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableMatch.endUpdates()
    }
    
    //Called, when long press occurred
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(tableMatch)
            if let indexPath = tableMatch.indexPathForRowAtPoint(touchPoint) {
                
                let alert = UIAlertController(title: "Alert", message: "Deleting the match is irreversible", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { action in
                    switch action.style{
                    case .Default:
                        print("default")
                        var match = self._fetchedResultsController?.fetchedObjects![indexPath.row] as! Match
                        match.winner.score = match.winner.score - match.value
                        match.loser.score = match.loser.score + match.value
                        self.tableView(self.tableMatch,commitEditingStyle: UITableViewCellEditingStyle.Delete,forRowAtIndexPath: indexPath)
                        self.configureView()
                    case .Cancel:
                        print("cancel")
                        
                    case .Destructive:
                        print("destructive")
                    }
                }))
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let match = object as! Match
        
        let playerWon = match.winner == player
        let opponent : Player = playerWon ? match.loser : match.winner
        var opponentName =  opponent.name
        let value = round(match.value).description
        
        opponentName.replaceRange(opponentName.startIndex...opponentName.startIndex, with: String(opponentName[opponentName.startIndex]).capitalizedString)
        cell.textLabel!.text =  (playerWon ? "Won " : "Lost " + (match.scratched ? "👌👈" : "")) + " against " + opponentName
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

