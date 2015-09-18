//
//  Array2D.swift
//  Tetris
//
//  Created by Filippo Tosetto on 16/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//


class Array2D<T> {
    
    let columns: Int
    let rows: Int

    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
        array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
    
    internal func filter(predicate:(T) -> Bool) -> [T] {
        var result = [T]()
        for i in array {
            if let j = i {
                if predicate(j) {
                    result.append(i!)
                }
            }
        }
        return result
    }
    
    func enumerate() -> AnyGenerator<((Int, Int), T?)> {
        var index = 0
        var g = array.generate()
        return anyGenerator() {
            if let item = g.next() {
                let column = index % self.columns
                let row = index / self.columns
                ++index
                return ((column, row) , item)
            }
            return nil
        }
    }
}
