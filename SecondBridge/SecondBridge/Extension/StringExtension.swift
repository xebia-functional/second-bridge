//
//  StringExtension.swift
//  SecondBridge
//
//  Created by Javier de Silóniz Sandino on 13/10/15.
//  Copyright © 2015 47 Degrees. All rights reserved.
//

import Foundation

extension String {
    static func randomStringWithLength(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        return (0..<length).reduce("") { (currentString: String, index: Int) -> String in
            let characterPos = arc4random_uniform(UInt32(letters.characters.count))
            let character = [Character](letters.characters)[Int(characterPos)]
            return "\(currentString)\(character)"
        }
    }
}