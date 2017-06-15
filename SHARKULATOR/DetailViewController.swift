//
//  DetailViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate , UITableViewDelegate, UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource {

    
    var managedObjectContext: NSManagedObjectContext!
    
    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var scoreLabel : UILabel!
    @IBOutlet weak var positionLabel : UILabel!
    //@IBOutlet weak var bestScoreLabel : UILabel!
    @IBOutlet weak var tableMatch : UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalGames: UIButton!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var worstEnemy: UILabel!
    @IBOutlet weak var bestEnemy: UILabel!
    @IBOutlet weak var scratchRatio: UILabel!
    @IBOutlet weak var currentStreak: UILabel!
    @IBOutlet weak var filter: UISegmentedControl!
    
    var playerMatchs : [Match] = []
    var playerOpponents : [Player] = []
    var badges : [Badge] = []

    var defendedTitle = 0;
    var titleSeized = 0;
    
    var player: Player? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBAction func onFilterChanged(_ sender: AnyObject) {
        tableMatch.reloadData()
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
                label.text = "Position : " + String(scoresBoard.players.index(of: player)! + 1)
            }
           // if let label = self.bestScoreLabel {
           //     label.text = "Best score : " + (player.bestScore).description
            //}
            
            playerMatchs = scoresBoard.getMatchsForUser(player)
            let stats = player.value(forKey: kStats)
            
            calculateTitleStats();
            
            
            badges = [TotalGamesBadge.init(value: (stats! as AnyObject).value(forKey:kGamesCount) as! Float),
                      BestScoreBadge.init(value: (stats! as AnyObject).value(forKey: kBestScore) as! Float),
                      LongestWinStreak.init(value: (stats! as AnyObject).value(forKey: kLongestWinStreak) as! Float),
                      LongestLooseStreak.init(value: (stats! as AnyObject).value(forKey: kLongestLoseStreak) as! Float),
                      TitleDefended.init(value: Float(defendedTitle)),
                      TitleGrab.init(value: Float(titleSeized))]
       
            if let collection = self.collectionView {
                collection.reloadData()
            }
            
            displayRatios() // win loss ratio and scratch ratio
            displayWorstEnemy()
            displayCurrentStreak()
        }
    }

    @IBAction func displayTotalGame(_ sender: UIButton) {
        var numberOfGames = 0
        if(player != nil){
            numberOfGames = scoresBoard.getMatchsForUser(player!).count
        }
        sender.setTitle(String(numberOfGames), for: UIControlState())
        sender.isSelected = !sender.isSelected
    }
    
    
    
    func calculateTitleStats(){
        
        var total = 0;
        titleSeized = 0;
        defendedTitle = 0;
        
        
        for match in playerMatchs{
            // calculate the win loss ratio
            if(match.titleGame){
                if(player == match.winner && match.titleHolder == player){
                    total += 1;
                    defendedTitle = defendedTitle < total ? total : defendedTitle;
                }else if (player == match.loser && match.titleHolder == player){
                    total = 0;
                }
                
                if (player == match.winner && match.titleHolder != player){
                    var holder = match.titleHolder.name
                    var winner = match.winner.name
                    titleSeized += 1;
                }
            }
        }
        
    }
    
    
    func displayRatios() {
        
        var wins = 0
        var ratioPerc : Float = 0
        
        var scratchsDone = 0
        var scratchsReceived = 0
        
        for match in playerMatchs{
            // calculate the win loss ratio
            if(player == match.winner){
                wins = wins + 1
                if(match.scratched){  // calculate the scratchs ratio
                    scratchsReceived = scratchsReceived + 1
                }

            }
            else if(match.scratched){  // calculate the scratchs ratio
                    scratchsDone = scratchsDone + 1
            }
        }
        
        ratioPerc = (Float (wins) / Float (playerMatchs.count))*100
        
        if let label = self.ratio {
            label.text = "Winning ratio of : " + String(format: "%.1f", ratioPerc) + "%"
        }
        if let label = self.scratchRatio {
            label.text = "Scratchs : " + String(format: "👌 %d - 👉 %d", scratchsDone,scratchsReceived)
        }
    }
    
    func displayCurrentStreak(){
        if(playerMatchs.isEmpty){
            return;
        }
        let stats = player?.value(forKey: kStats)
        if let label = self.currentStreak {
            let ws = (stats as AnyObject).value(forKey: kWinStreak) as! Int
            let ls = (stats as AnyObject).value(forKey: kLoseStreak) as! Int
            let i = ws > 0 ? ws : ls
            label.text = "Current streak : " + String(format: "%d", i) + (ws > 0 ?  ( i < 2 ? " win" : " wins") : ( i < 2 ? " loss" : " losses"))
        }
        
        /*
        var i = 1;
        var isWinningStreak = playerMatchs[0].winner == player
        while(i < playerMatchs.count && ((playerMatchs[i].winner == player && playerMatchs[i].winner == playerMatchs[i-1].winner)
        || (playerMatchs[i].loser == player && playerMatchs[i].loser == playerMatchs[i-1].loser))){
            i += 1
        }
        
        if let label = self.currentStreak {
            label.text = "Current " + (isWinningStreak ?  "winning" : "losing") + " streak of " + String(format: "%d", i) + ( i < 2 ? " game" : " games")
        }*/
    }
    
    func displayWorstEnemy() {
        
        let opponents = NSMutableDictionary()
        
        for match in playerMatchs{
            let opponent = player == match.winner ? match.loser.name : match.winner.name
            var pointSumForUser = opponents[opponent]
            
            if (pointSumForUser == nil) {
                opponents[opponent] = Float(0)
                pointSumForUser = Float(0)
            }
            
            if(player == match.winner){
                pointSumForUser = pointSumForUser as! Float + match.value
            }else{
                pointSumForUser = pointSumForUser as! Float - match.value
            }
            
            opponents[opponent] = pointSumForUser
        }
        
        var mostPointLost = Float(0)
        var mostPointWon = Float(0)
        
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
            label.text = "Shark : " + worstEnemyName + " with " + String(format: "%.0f", round(mostPointLost )) + " points"
        }
        if let label = self.bestEnemy {
            label.text = "Fish : " + bestEnemy + " with " + String(format: "%.0f", round(mostPointWon )) + " points"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return player == nil ? 0 : self.fetchedResultsController.sections?.count ?? 0
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        let numberOfGames = sectionInfo.numberOfObjects
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
        fetchRequest.predicate = NSPredicate(format: "winner == %@ OR loser == %@ ", self.player!, self.player!)
        
        // Edit the sort key as appropriate.
        let selector = filter.selectedSegmentIndex == 0 ? kDate : kPlayer
        let sortDescriptor = NSSortDescriptor(key: selector, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController?.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableMatch.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableMatch.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete: break
            //self.tableMatch.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableMatch.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: break
            //tableMatch.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .update:
            self.configureCell(tableMatch.cellForRow(at: indexPath!)!, withObject: anObject as! NSManagedObject)
        case .move:
            tableMatch.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //self.tableMatch.endUpdates()
    }
    
    //Called, when long press occurred
    func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: tableMatch)
            if let indexPath = tableMatch.indexPathForRow(at: touchPoint) {
                
                let alert = UIAlertController(title: "Alert", message: "Deleting the match is irreversible", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        var match = self._fetchedResultsController?.fetchedObjects![indexPath.row] as! Match
                        match.winner.score = match.winner.score - match.value
                        match.loser.score = match.loser.score + match.value
                        self.tableView(self.tableMatch,commit: UITableViewCellEditingStyle.delete,forRowAt: indexPath)
                        self.configureView()
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let match = object as! Match
        
        let playerWon = match.winner == player
        let opponent : Player = playerWon ? match.loser : match.winner
        var opponentName =  opponent.name
        let value = round(match.value).description
        
        opponentName.replaceSubrange(opponentName.startIndex...opponentName.startIndex, with: String(opponentName[opponentName.startIndex]).capitalized)
        
        var winText = (playerWon ? " Won " : " Lost ") + (match.scratched ? scratchSign + " " : "") + "against "
        
        if(match.titleGame){
            let isChallenger = match.titleHolder != player
            let isSuccess = match.winner == player
            
            winText = (playerWon ? " Won " : " Lost ") + "& " +
                (isChallenger ?
                    (isSuccess ? successChallengedTitle: failedChallengedTitle) :
                    (isSuccess ? successDefendTitle: failedDefendTitle))
        }
        
        cell.textLabel!.text =  winText + opponentName
        cell.detailTextLabel!.text =  value
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
    
    
    // MARK: - Badges CollectionViewController
    
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return abs(badges.count/3 + 1)
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(badges.count - section * 3,3)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCell", for: indexPath)
        if(!badges.isEmpty){
            let badge = badges[indexPath.section * 3 + indexPath.row]
            let valueLabel = cell.viewWithTag(101) as! UILabel
            valueLabel.text = String(format: "%.0f", badge.value )
            let titleLabel = cell.viewWithTag(102) as! UILabel
            titleLabel.text = badge.displayName
            let levelLabel = cell.viewWithTag(103) as! UILabel
            
            levelLabel.text = badge.levelNameForValue(badge.value)
            // Configure the cell
        }
        return cell
    }
}

