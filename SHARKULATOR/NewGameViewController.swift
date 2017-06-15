//
//  ViewController.swift
//  ELO
//
//  Created by clement perez on 3/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController,UITextFieldDelegate {
    
    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    @IBOutlet weak var winnerTextField: UITextField!
    @IBOutlet weak var loserTextField: UITextField!
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var loserLabel: UILabel!
    
    @IBOutlet weak var breakSegmentedControl: UISegmentedControl!
    @IBOutlet weak var calculateButton: UIButton!
    
    @IBOutlet weak var titleGameSwitch: UISwitch!
    @IBOutlet weak var titleGameLabel: UILabel!
    @IBOutlet weak var scratchSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        winnerTextField.delegate = self
        loserTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func calculateClicked(_ sender: AnyObject) {
        
        calculateButton.isEnabled = false
        
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
        
        
        scoresBoard.addMatch(winner, loser: loser, breaker: breaker, scratch : scratchSwitch.isOn, titleGame: titleGameSwitch.isOn && titleGameSwitch.isEnabled, appDelegate: UIApplication.shared.delegate as! AppDelegate)
        
        winnerLabel.text = round(winner.score).description + " (" + round(winner.score - oldWinnerScore).description + ")"
        loserLabel.text = round(loser.score).description + " (" + round(loser.score - oldLoserScore).description + ")"
        
        scoresBoard.store(UIApplication.shared.delegate as! AppDelegate)
    }
    
    @IBAction func nameChanged(_ sender: AnyObject) {
        
        let winnerName = self.winnerTextField.text!
        let loserName = self.loserTextField.text!
        
        let validWinnerName = scoresBoard.containsPlayerWithName(winnerName)
        let validLoserName = scoresBoard.containsPlayerWithName(loserName)
        
        calculateButton.isEnabled = (validWinnerName && validLoserName) && winnerName != loserName
        
        if(validLoserName && validWinnerName){
            let winner = scoresBoard.playerWithName(winnerName)
            let loser = scoresBoard.playerWithName(loserName)
            var b1 = winner.stats.titleHolder
            var b = winner.stats.titleHolder
            titleGameSwitch.isEnabled = winner.stats.titleHolder || loser.stats.titleHolder
            titleGameLabel.alpha = titleGameSwitch.isEnabled ? 1 : 0.5
        }else{
            titleGameSwitch.isEnabled = false
            titleGameLabel.alpha = 0.5
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        let playerName = textField.text!
        if(scoresBoard.containsPlayerWithName(playerName) && !scoresBoard.playerWithName(playerName).isRetired){
            let player = scoresBoard.playerWithName(playerName) as! Player
            
            if(textField == winnerTextField){
                winnerLabel.text = round(player.score).description
                breakSegmentedControl.setTitle(player.name, forSegmentAt: 0)
            }else if(textField == loserTextField){
                loserLabel.text = round(player.score).description
                breakSegmentedControl.setTitle(player.name, forSegmentAt: 1)
            }
        }else{
            if(textField == winnerTextField){
                winnerLabel.text = "Invalid name"
            }else if(textField == loserTextField){
                loserLabel.text = "Invalid name"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        return true
    }
    
}

