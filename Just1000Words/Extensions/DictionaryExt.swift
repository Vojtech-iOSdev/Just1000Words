//
//  DictionaryExt.swift
//  Just1000Words
//
//  Created by Vojtěch Kalivoda on 6/22/25.
//

import Foundation

extension Dictionary {
    func compactMapKeys<T>(_ transform: (Key) -> T?) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
