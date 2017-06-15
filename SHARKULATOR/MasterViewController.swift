//
//  MasterViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoresBoard.restore(UIApplication.shared.delegate as! AppDelegate)
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
       // fakePlayer()
       // fakeMatchs()
       // createStatsTable()
      /*  scoresBoard.playerWithName("Alex").stats.setValue(true, forKey: kTitleHolder)
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var managedContext = appDel.managedObjectContext
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }*/
    }

    func fakePlayer(){
        self.scoresBoard.addPlayerWithName("Alex",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Clement",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Sal",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Frank",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Gerrit",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Erik",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Jim",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Ash",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Danny",score:1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Basit",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Ronak",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Amber",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        self.scoresBoard.addPlayerWithName("Jason",score: 1000, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        
    }
    
    func fakeMatchs(){
        for  pl in self.scoresBoard.players {
            for  pl2 in self.scoresBoard.players {
                if(pl != pl2){
                    let bool = arc4random_uniform(2) == 0 ? true: false
                    let bool2 = arc4random_uniform(2) == 0 ? true: false
                    let bool3 = arc4random_uniform(20) == 0 ? true: false
                self.scoresBoard.addMatch(bool ? pl : pl2, loser: bool ? pl2 : pl, breaker: bool2 ? pl2 : pl, scratch: bool3, appDelegate: UIApplication.shared.delegate as! AppDelegate)
                }
            }
        }
    }
    
    func createStatsTable(){
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        var managedContext = appDel.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Stats", in:managedContext)
        
        for  pl in self.scoresBoard.players {
            var matchs = scoresBoard.getMatchsForUser(pl)
            
            var winCount = 0
            var loseCount = 0
            var winStreak = 0
            var loseStreak = 0
            var longestWinStreak = 0
            var longestLoseStreak = 0
            var scratchCount = 0
            var oppScratchCount = 0
            
            for  match in matchs {
                if(pl == match.winner){
                    winCount+=1
                    
                    winStreak+=1
                    loseStreak = 0
                    longestWinStreak = max(winStreak,longestWinStreak)
                    
                    if(match.scratched){
                        scratchCount+=1
                    }
                }
                else{
                    loseCount+=1
                    
                    loseStreak+=1
                    winStreak = 0
                    longestLoseStreak = max(loseStreak,longestLoseStreak)
                    
                    if(match.scratched){
                        oppScratchCount+=1
                    }
                }
            }
            
            let stats = NSManagedObject(entity: entity!, insertInto: managedContext)
            stats.setValue(matchs.count, forKey:kGamesCount)
            stats.setValue(winCount, forKey:kWinCount)
            stats.setValue(loseCount, forKey:kLoseCount)
            stats.setValue(winStreak, forKey:kWinStreak)
            stats.setValue(loseStreak, forKey:kLoseStreak)
            stats.setValue(longestWinStreak, forKey:kLongestWinStreak)
            stats.setValue(longestLoseStreak, forKey:kLongestLoseStreak)
            stats.setValue(pl.bestScore, forKey:kBestScore)
            stats.setValue(scratchCount, forKey:kScratchCount)
            stats.setValue(oppScratchCount, forKey:kOpponentScratchCount)
            
            pl.setValue(stats, forKey: kStats)
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createUser(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Create new user", message: "Enter yo' name Player", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            let name = textField.text
            if(self.scoresBoard.isPlayerNameValid(name!) && !self.scoresBoard.containsPlayerWithName(name!)){
                self.scoresBoard.addPlayerWithName(name!, appDelegate: UIApplication.shared.delegate as! AppDelegate)
                self.tableView.reloadData();
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.player = object as! Player
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count < 2 ? (self.fetchedResultsController.sections?.count)! : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        self.configureCell(cell, index: indexPath, withObject: object)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            let playerObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
            playerObject.setValue(true, forKey: kIsRetired)
            context.refresh(playerObject, mergeChanges: true)
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
    
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section == 0){
            let retire = UITableViewRowAction(style: .normal, title: "Retire") { action, index in
                
                let context = self.fetchedResultsController.managedObjectContext
                let playerObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
                playerObject.setValue(true, forKey: kIsRetired)
                context.refresh(playerObject, mergeChanges: true)
                do {
                    print("Retire " + (playerObject.value(forKey: kName)! as AnyObject).description + "isRetired = " + (playerObject.value(forKey: kIsRetired)! as AnyObject).description)
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    print("Unresolved error \(error)")
                    abort()
                }
            }
            return [retire]
        }else{
            let unretire = UITableViewRowAction(style: .normal, title: "Unretire") { action, index in
                
                let context = self.fetchedResultsController.managedObjectContext
                let playerObject = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
                playerObject.setValue(false, forKey: kIsRetired)
                context.refresh(playerObject, mergeChanges: true)
                do {
                     print("Unretire " + (playerObject.value(forKey: kName)! as AnyObject).description + "isRetired = " + (playerObject.value(forKey: kIsRetired)! as AnyObject).description)
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    print("Unresolved error \(error)")
                    abort()
                }
            }
            return [unretire]
        }
    }
    
    func configureCell(_ cell: UITableViewCell, index : IndexPath, withObject object: NSManagedObject) {
        var cellTitle = "'";
        if(index.section == 0){
            let i = index.row == 0 ? "\u{265B}" : (index.row + 1).description
            cellTitle = i + " - " + (object.value(forKey: kName)! as AnyObject).description
        }else{
            cellTitle = (object.value(forKey: kName)! as AnyObject).description
        }
        
        if(((object.value(forKey: kStats) as AnyObject).value(forKey: kTitleHolder))! as! Bool){
            cellTitle = cellTitle + "  🍯"
        }
        
        cell.textLabel!.text = cellTitle;
        cell.detailTextLabel!.text = String(format: "%.0f", round(object.value(forKey: kScore)! as! Float))
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil);
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Player", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sectionSort = NSSortDescriptor(key: "isRetired", ascending: true)
        let innerSectionSort = NSSortDescriptor(key: "score", ascending: false)
        
        fetchRequest.sortDescriptors = [sectionSort, innerSectionSort] //the first descriptor is for the section grouping, the secong one is for the inner section sort
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "isRetired" , cacheName: nil)
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

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    override func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        switch(section)
        {
        case 1:return "sore losers"
            break
        default :return ""
            break
        }
    }
    
    override func tableView(_ tableView: UITableView,
                     heightForHeaderInSection section: Int) -> CGFloat{
        switch(section)
        {
        case 1:return 30
            break
        default :return CGFloat.leastNormalMagnitude
            break
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat{
        return CGFloat.leastNormalMagnitude
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, index: indexPath! , withObject: anObject as! NSManagedObject)
            case .move:
                //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.moveRow(at: indexPath!, to: newIndexPath!) //should work but causes problem when the retired section is empty
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }

     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
}

