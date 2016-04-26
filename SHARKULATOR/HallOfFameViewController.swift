//
//  HallOfFameViewController.swift
//  SHARKULATOR
//
//  Created by clement perez on 4/12/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation
import UIKit

class HallOfFameViewController: UIViewController {
    
    var scoresBoard : ScoresBoard = ScoresBoard.sharedInstance
    var player : Player!
    var matchs : [Match] = []
    
    @IBOutlet weak var highestScoreLabel : UILabel!
    @IBOutlet weak var longestChampion : UILabel!
    @IBOutlet weak var currentChampion : UILabel!
    @IBOutlet weak var longestWinStreak : UILabel!
    @IBOutlet weak var longestLooseStreak : UILabel!
    @IBOutlet weak var totalGames : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let champion = getPlayerWithHighestScore()
        let player = getPlayerWithCurrentHighestScore()
        
        currentChampion.text = "Current champion " + player.name + " with " + player.score.description
        highestScoreLabel.text = "All time champion " + champion.name + " with " + champion.bestScore.description
        
        displayLonguestWinStreak()
        displayLonguestLoseStreak()
        
        totalGames.text = scoresBoard.matchs.count.description
    }
    
    func getPlayerWithHighestScore()-> Player{
        //need date
        //need player
        //need score
        var topPlayer = scoresBoard.players[0]
        for player in scoresBoard.players{
            if(player.bestScore > topPlayer.bestScore){
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
        
        var playerMatchs = scoresBoard.getMatchsForUser(player)
        
        for match in scoresBoard.matchs{
            if(match.winner == player){
                winStreakLoop = winStreakLoop + 1
                loseStreakLoop = 0
                if(winStreakPlayer < winStreakLoop){
                    winStreakPlayer = winStreakLoop
                }
            }else if(match.loser == player){
                loseStreakLoop = loseStreakLoop + 1
                winStreakLoop = 0
                if(loseStreakPlayer < loseStreakLoop){
                    loseStreakPlayer = loseStreakLoop
                }
            }
        }
        
        return forWins ? winStreakPlayer : loseStreakPlayer
    }
}