//
//  MasterViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var scoreBoard : ScoresBoard = ScoresBoard.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreBoard.restore(UIApplication.sharedApplication().delegate as! AppDelegate)
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        //createFakeData()
        //fakeMatchs()
    }

    func createFakeData(){// score on 4/13/16
        self.scoreBoard.addPlayerWithName("Alex",score: 1119, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Clement",score: 1089, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Sal",score: 1018, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Frank",score: 1008, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Gerrit",score: 1008, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Erik",score: 995, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Jim",score: 982, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Ash",score: 979, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Danny",score: 978, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Basit",score: 969, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Ronak",score: 957, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Amber",score: 949, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        self.scoreBoard.addPlayerWithName("Jason",score: 949, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    func fakeMatchs(){
        for  pl in self.scoreBoard.players {
            for  pl2 in self.scoreBoard.players {
                if(pl != pl2){
                    let bool = arc4random_uniform(2) == 0 ? true: false
                    let bool2 = arc4random_uniform(2) == 0 ? true: false
                self.scoreBoard.addMatch(bool ? pl : pl2, loser: bool ? pl2 : pl, breaker: bool2 ? pl2 : pl, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createUser(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Create new user", message: "Enter yo' name Player", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text)")
            let name = textField.text
            if(self.scoreBoard.isPlayerNameValid(name!) && !self.scoreBoard.containsPlayerWithName(name!)){
                self.scoreBoard.addPlayerWithName(name!, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
                self.tableView.reloadData();
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.player = object as! Player
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, index: indexPath, withObject: object)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            var playerObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            playerObject.setValue(true, forKey: kIsRetired)
            context.refreshObject(playerObject, mergeChanges: true)
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
    
    override func tableView(tableView: UITableView,
                            editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section == 0){
            let retire = UITableViewRowAction(style: .Normal, title: "Retire") { action, index in
                
                let context = self.fetchedResultsController.managedObjectContext
                var playerObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                playerObject.setValue(true, forKey: kIsRetired)
                context.refreshObject(playerObject, mergeChanges: true)
                do {
                    print("Retire " + playerObject.valueForKey(kName)!.description + "isRetired = " + playerObject.valueForKey(kIsRetired)!.description)
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
            let unretire = UITableViewRowAction(style: .Normal, title: "Unretire") { action, index in
                
                let context = self.fetchedResultsController.managedObjectContext
                var playerObject = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                playerObject.setValue(false, forKey: kIsRetired)
                context.refreshObject(playerObject, mergeChanges: true)
                do {
                     print("Unretire " + playerObject.valueForKey(kName)!.description + "isRetired = " + playerObject.valueForKey(kIsRetired)!.description)
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
    
    func configureCell(cell: UITableViewCell, index : NSIndexPath, withObject object: NSManagedObject) {
        if(index.section == 0){
            let i = index.row == 0 ? "\u{265B}" : (index.row + 1).description
            cell.textLabel!.text = i + " - " + object.valueForKey(kName)!.description
        }else{
            cell.textLabel!.text = object.valueForKey(kName)!.description
        }
        
        cell.detailTextLabel!.text = String(format: "%.0f", round(object.valueForKey(kScore)! as! Float))
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        NSFetchedResultsController.deleteCacheWithName(nil);
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Player", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sectionSort = NSSortDescriptor(key: "isRetired", ascending: true)
        let innerSectionSort = NSSortDescriptor(key: "score", ascending: false)
        
        fetchRequest.sortDescriptors = [sectionSort, innerSectionSort] //the first descriptor is for the section grouping, the secong one is for the inner section sort
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "isRetired" , cacheName: "Master")
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
        self.tableView.beginUpdates()
    }
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        switch(section)
        {
        case 1:return "Retired"
            break
        default :return ""
            break
        }
    }
    
    override func tableView(tableView: UITableView,
                     heightForHeaderInSection section: Int) -> CGFloat{
        switch(section)
        {
        case 1:return 30
            break
        default :return CGFloat.min
            break
        }
    }
    
    override func tableView(tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat{
        return CGFloat.min
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, index: indexPath! , withObject: anObject as! NSManagedObject)
            case .Move:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                //tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!) //should work but causes problem when the retired section is empty
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

