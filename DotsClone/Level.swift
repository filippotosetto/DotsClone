//
//  DotManager.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//

import SwiftyJSON

let NumColumns = 10
let NumRows = 10


class Level {

    private var dotsArray = Array2D<Dot>(columns: NumColumns, rows: NumRows)
    private var tilesArray = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    var targetScore = 0
    var maximumMoves = 0
    
    init(fileName: String) {
        
        if let jsonObject = JSON.loadJSONFromBundle(fileName) {
            if let tArray: Array = jsonObject["tiles"].array {
                for (row, rowArray):(Int, JSON) in tArray.enumerate() {
                    for (column, value): (Int, JSON) in rowArray.array!.enumerate() {
                        if value.intValue == 1 {
                            let tileRow = NumRows - row - 1
                            tilesArray[column, tileRow] = Tile()
                        }
                    }
                }
            }

            targetScore = jsonObject["targetScore"].intValue
            maximumMoves = jsonObject["moves"].intValue
        }
    }
    
    func dotAtPosition(column column: Int, row: Int) -> Dot? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return dotsArray[column, row]
    }

    func tileAtPosition(column column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return tilesArray[column, row]
    }
    
    func shuffle() -> Set<Dot>{
        return createInitialDots()
    }
    
    func getAllDotsFromColor(color: DotColor) -> [Dot] {
        return dotsArray.filter { $0.color == color }
    }
    
    func cleanDots() {
        dotsArray = Array2D<Dot>(columns: NumColumns, rows: NumRows)
    }


    private func createInitialDots() -> Set<Dot>{
        var setOfDots = Set<Dot>()
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if (tilesArray[column, row] != nil) {
                
                    let dot = Dot.random(column, startingRow: row)
                    dotsArray[column, row] = dot
                
                    setOfDots.insert(dot)
                }
            }
        }
        return setOfDots
    }
    
    
    func removeDots(chain: Chain) {
        for dot in chain.dots {
            dotsArray[dot.column, dot.row] = nil
        }
    }
    
    
    func fillHoles() -> [[Dot]] {
        var columns = [[Dot]]()
        for column in 0..<NumColumns {
            var array = [Dot]()
            for row in 0..<NumRows {
                if tilesArray[column, row] != nil && dotsArray[column, row] == nil {
                    for lookup in (row + 1)..<NumRows {
                        if let dot = dotsArray[column, lookup] {
                            dotsArray[column, lookup] = nil
                            dotsArray[column, row] = dot
                            dot.row = row
                            array.append(dot)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    
    func topUpDots() -> [[Dot]] {
        var columns = [[Dot]]()
        for column in 0..<NumColumns {
            var array = [Dot]()
            for var row = NumRows - 1; row >= 0 && dotsArray[column, row] == nil; --row {
                if tilesArray[column, row] != nil {
                    let dot = Dot.random(column, startingRow: row)
                    dotsArray[column, row] = dot
                    array.append(dot)
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}