//
//  ViewController.swift
//  ELO
//
//  Created by clement perez on 3/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {
    
    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    @IBOutlet weak var winnerTextField: UITextField!
    @IBOutlet weak var loserTextField: UITextField!
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var loserLabel: UILabel!
    
    @IBOutlet weak var breakSegmentedControl: UISegmentedControl!
    @IBOutlet weak var calculateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        winnerTextField.delegate = self
        loserTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func calculateClicked(sender: AnyObject) {
        
        calculateButton.enabled = false
        
        let winnerName = self.winnerTextField.text!
        let loserName = self.loserTextField.text!
        
        if(!scoresBoard.containsPlayerWithName(winnerName) || !scoresBoard.containsPlayerWithName(loserName)){
            return
        }
        
        var winner = scoresBoard.playerWithName(winnerName)
        var loser = scoresBoard.playerWithName(loserName)
        var breaker = breakSegmentedControl.selectedSegmentIndex == 0 ? winner : loser
        
        let winnerScore = winner.score
        let loserScore = loser.score
        let oldWinnerScore = winner.score
        let oldLoserScore = loser.score
        
        
        scoresBoard.addMatch(winner, loser: loser, breaker: breaker, appDelegate: UIApplication.sharedApplication().delegate as! AppDelegate)
        
        winnerLabel.text = round(winner.score).description + " (" + round(winner.score - oldWinnerScore).description + ")"
        loserLabel.text = round(loser.score).description + " (" + round(loser.score - oldLoserScore).description + ")"
        
        scoresBoard.store(UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    @IBAction func nameChanged(sender: AnyObject) {
        
        let winnerName = self.winnerTextField.text!
        let loserName = self.loserTextField.text!
        
        calculateButton.enabled = (scoresBoard.containsPlayerWithName(winnerName) && scoresBoard.containsPlayerWithName(loserName)) && winnerName != loserName
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {    //delegate method
        
    }
    
    
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        let playerName = textField.text!
        if(scoresBoard.containsPlayerWithName(playerName) && !scoresBoard.playerWithName(playerName).isRetired){
            let player = scoresBoard.playerWithName(playerName) as! Player
            
            if(textField == winnerTextField){
                winnerLabel.text = round(player.score).description
                breakSegmentedControl.setTitle(player.name, forSegmentAtIndex: 0)
            }else if(textField == loserTextField){
                loserLabel.text = round(player.score).description
                breakSegmentedControl.setTitle(player.name, forSegmentAtIndex: 1)
            }
        }else{
            if(textField == winnerTextField){
                winnerLabel.text = "Invalid name"
            }else if(textField == loserTextField){
                loserLabel.text = "Invalid name"
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        return true
    }
    
}

