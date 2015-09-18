//
//  Chain.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//

class Chain: CustomStringConvertible, Hashable {
    var dots = [Dot]()
    var score = 0
    
    func addDot(dot: Dot) {
        dots.append(dot)
    }
    
    func addDots(dots: [Dot]) {
        for dot in dots {
            self.dots.append(dot)
        }
    }
    
    func removeLastDot() {
        dots.removeLast()
    }
    
    func firstDot() -> Dot {
        return dots[0]
    }
    
    func lastDot() -> Dot {
        return dots.last!//[dots.count - 1]
    }
    
    func empty() {
        dots.removeAll()
    }
    
    func calculateScores() {
        score = 6 * length
    }
    
    var length: Int {
        return dots.count
    }
    
    var description: String {
        return "Dots \(dots)"
    }
    
    var hashValue: Int {
        return dots.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
}
func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.dots == rhs.dots
}
