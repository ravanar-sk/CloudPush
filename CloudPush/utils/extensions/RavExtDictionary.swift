//
//  RavExtDictionary.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 17/04/25.
//

import Foundation

/**
 Function to convert a Dictionary to String
 */
extension Dictionary {
    
    func toString() -> String {
        return String(describing: self)
    }
}

/**
 Function to convert a Dictionary to JSON String
 */
extension Dictionary {
    
    func toJSONString() -> String? {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8)
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return nil
    }
}
