//
//  File.swift
//  SHARKULATOR
//
//  Created by clement perez on 8/22/16.
//  Copyright © 2016 frequency. All rights reserved.
//

import Foundation

extension String {
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
    
}
