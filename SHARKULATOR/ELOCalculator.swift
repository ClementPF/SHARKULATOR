//
//  ELOCalculator.swift
//  ELO
//
//  Created by clement perez on 3/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation

class ELOCalculator {
    
    static func getMatchValue(winnerScore : Float,loserScore : Float) -> Float{
        let winnerOrinalScore = winnerScore
        let loserOriginalScore = loserScore
        
        let winnerTransformedRating = transformedRating(winnerOrinalScore)
        let loserTransformedRating = transformedRating(loserOriginalScore)
        
        let winnerExpectedScore = expectedScore(winnerTransformedRating, OpponentTransformedRating: loserTransformedRating)
        return winnerScoreGain(winnerExpectedScore)
    }
    
    static func calculateEloRating(inout winnerScore : Float,inout loserScore : Float){
        let winnerOrinalScore = winnerScore
        let loserOriginalScore = loserScore
        
        let winnerTransformedRating = transformedRating(winnerOrinalScore)
        let loserTransformedRating = transformedRating(loserOriginalScore)
        
        let winnerExpectedScore = expectedScore(winnerTransformedRating, OpponentTransformedRating: loserTransformedRating)
        let loserExpectedScore = expectedScore(loserTransformedRating, OpponentTransformedRating: winnerTransformedRating)
        
        winnerScore = updatedScore(winnerOrinalScore, didWin: 1, expectedScore: winnerExpectedScore)
        loserScore = updatedScore(loserOriginalScore, didWin: 0, expectedScore: loserExpectedScore)
    }
    
    static private func transformedRating(score : Float) -> Float{
        return pow(10,(score/400))
    }
    
    static private func expectedScore(ownTransformedRating : Float, OpponentTransformedRating : Float)-> Float{
        return ownTransformedRating / (ownTransformedRating + OpponentTransformedRating)
    }
    
    static private func thirdStep(winnerScore : Float, loserScore : Float){
        
    }
    
    static private func updatedScore(score : Float, didWin : Float, expectedScore : Float) -> Float{
        
        let result = score + kKfactor * (didWin - expectedScore)
        
        return result
    }
    
    static private func winnerScoreGain(expectedScore : Float) -> Float{
        
        let result = kKfactor * (1 - expectedScore)
        
        return result
    }
}