//
//  Extensions.swift
//  DotsClone
//
//  Created by Filippo Tosetto on 17/09/2015.
//  Copyright © 2015 Conjure. All rights reserved.
//

//import Foundation
import SwiftyJSON

extension JSON {
    static func loadJSONFromBundle(filename: String) -> JSON? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return JSON(data: data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}