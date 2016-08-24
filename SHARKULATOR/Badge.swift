//
//  Badge.swift
//  SHARKULATOR
//
//  Created by clement perez on 7/28/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation

public class Badge {
    var name : String
    var displayName : String
    var imageName : String
    var value : Float
    var levels : [Float]
    var levelsNames : [String]
    
    init(name: String, displayName: String, imageName: String, value: Float, levels: [Float], levelsNames: [String]) {
        self.name = name
        self.displayName = displayName
        self.imageName = imageName
        self.value = value
        self.levels = levels
        self.levelsNames = levelsNames
    }
    
   public func levelNameForValue(value: Float) -> String{
        var i = 0
        while(i < levels.count-1 && value > levels[i]){
            i+=1
        }
        return levelsNames[i]
    }
}


class BestScoreBadge : Badge{
    
    init(value: Float) {
        super.init(
            name: "bestScore",
            displayName: "Best Score",
            imageName: "",
            value: value,
            levels: [1000,1050,1075,1100,1125,1150,1175,1200,1250,1300],
            levelsNames: ["🐛","🐜","🐝","🕷","🦂","🐍","🐊","🐆","🐅","🐲"]
        )
    }
}

class TotalGamesBadge : Badge{

    init(value: Float) {
        super.init(
            name: "totalGames",
            displayName: "Total Games",
            imageName: "",
            value: value,
            levels: [1,5,10,25,50,100,200,500,1000],
            levelsNames: ["🐣","🐥","🐔","🐑","🐨","🐼","🐪","🐘","🦄"]
        )
    }
}

class LongestWinStreak : Badge{
    
    init(value: Float) {
        super.init(
            name: "longestWinStreak",
            displayName: "Top win streak",
            imageName: "",
            value: value,
            levels: [0,3,5,7,9,11,13],
            levelsNames: ["🍴","🔧","🔨","🔪","🗡","🔫","💣"]
        )
    }
}

class LongestLooseStreak : Badge{
    
    init(value: Float) {
        super.init(
            name: "longestLoseStreak",
            displayName: "Top loss streak",
            imageName: "",
            value: value,
            levels: [0,3,5,7,9,11,13],
            levelsNames: ["💨","🍌","🌽","🍆","🌯","🌶","🍍"]
        )
    }
}

class BestShark : Badge{
    
    init(value: Float) {
        super.init(
            name: "Top shark",
            displayName: "Sharky Mc Shark Face",
            imageName: "",
            value: value,
            levels: [20,40,60,80,100,120,140,160,180,200,250,300,400,500],
            levelsNames: ["20","40","60","80","100","120","140","160","180","200","250","300","400","500"]
        )
    }
}

class WorstFish : Badge{
    
    init(value: Float) {
        super.init(
            name: "Worst Fish",
            displayName: "Learn a man how to fish...",
            imageName: "",
            value: value,
            levels: [20,40,60,80,100,120,140,160,180,200,250,300,400,500],
            levelsNames: ["20","40","60","80","100","120","140","160","180","200","250","300","400","500"]
        )
    }
}