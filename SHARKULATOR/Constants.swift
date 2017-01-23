//
//  Constants.swift
//  ELO
//
//  Created by clement perez on 4/11/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation

var kKfactor : Float = 36
var kdefaultELO : Float = 1000

var kdbNameFile : String = "ELODB"

// MARK: PLAYER
var kName : String = "name"
var kPlayer : String = "player"
var kScore : String = "score"
var kStats : String = "stats"
var kIsRetired : String = "isRetired"

// MARK: MATCH
var kMatch : String = "match"
var kWinner : String = "winner"
var kWinnerScore : String = "winnerScore"
var kLoser : String = "loser"
var kBreaker : String = "breaker"
var kScratched : String = "scratched"
var kTitleGame : String = "titleGame"
var kLoserScore : String = "loserScore"
var kValue : String = "value"
var kDate : String = "date"

// MARK: STATS
var kBestScore : String = "bestScore"
var kWinStreak : String = "winStreak"
var kLoseStreak : String = "loseStreak"
var kLongestWinStreak : String = "longestWinStreak"
var kLongestLoseStreak : String = "longestLoseStreak"
var kGamesCount : String = "gamesCount"
var kWinCount : String = "winCount"
var kLoseCount : String = "loseCount"
var kTieCount : String = "tieCount"
var kScratchCount : String = "scratchCount"
var kOpponentScratchCount : String = "opponentScratchCount"
var kTitleHolder : String = "titleHolder"

// STRINGS
var scratchSign : String = "👉👌"
var titleGameSign : String = "🍯"
var successDefendTitle : String = "Defended " + titleGameSign + " against "
var failedDefendTitle : String = "Yielded " + titleGameSign + " to "
var successChallengedTitle : String = "Seized " + titleGameSign + " from "
var failedChallengedTitle : String = "Fizzled " + titleGameSign  + " in front of "
