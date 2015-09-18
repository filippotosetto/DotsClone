//
//  Dot.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//

import SpriteKit


let NumberOfColors: UInt32 = 4

enum DotColor: Int, CustomStringConvertible {
    case Blue = 0, Red, Green, Yellow
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Red:
            return "red"
        case .Yellow:
            return "yellow"
        case .Green:
            return "green"
        }
    }
    
    var color: UIColor {
        switch self {
        case .Blue:
            return UIColor(red: 0, green: 163.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        case .Red:
            return UIColor(red: 209/255.0, green: 78.0/255.0, blue: 4.0/255.0, alpha: 1.0)
        case .Yellow:
            return UIColor(red: 0, green: 209/255.0, blue: 106/255.0, alpha: 1.0)
        case .Green:
            return UIColor(red: 209/255.0, green: 184.0/255.0, blue: 0, alpha: 1.0)
        }
    }
    
    var description: String {
        return self.spriteName
    }
    
    static func random() -> DotColor {
        return DotColor(rawValue: Int(arc4random_uniform(NumberOfColors)))!
    }
}


class Dot: Hashable, CustomStringConvertible {
    
    let color: DotColor
    
    var column: Int
    var row: Int
    var sprite: SKShapeNode?
    
    var properColor: UIColor {
        get {
            return color.color
        }
    }
    
    var spriteName: String {
        return color.description
    }
    
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column: Int, row: Int, color:DotColor) {
        self.column = column
        self.row = row
        self.color = color
    }
    
    final class func random(startingColumn:Int, startingRow:Int) -> Dot {
        return Dot(column: startingColumn, row: startingRow, color: DotColor.random())
    }

    func canBeConnected(dot: Dot) -> Bool {
        return  (dot.column == self.column - 1 && dot.row == self.row) ||
                (dot.column == self.column + 1 && dot.row == self.row) ||
                (dot.row == self.row + 1 && dot.column == self.column) ||
                (dot.row == self.row - 1 && dot.column == self.column)

    }
}

func ==(lhs: Dot, rhs: Dot) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}
