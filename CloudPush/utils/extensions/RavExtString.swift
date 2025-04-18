//
//  RavExtString.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 17/04/25.
//

import Foundation

/**
 String Extension
 Method for Converting a JSON string to Dictionary
 */
extension String {
    
    func toDictionary<K,V>() -> [K: V]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [K: V]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

/**
 String Extension
 Method for Converting a JSON string to Data
 */
extension String {
    
    func toData() -> Data? {
        return self.data(using: .utf8)
    }
}


