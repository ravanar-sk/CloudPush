//
//  RavExtData.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 17/04/25.
//

import Foundation

/**
 Data Extension
 Method for Converting Data to JSON String
 */
extension Data {
    
    func toJSONString() -> String {
        
        do {
            let dict = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
            return dict?.toString() ?? ""
        } catch {
            debugPrint(error.localizedDescription)
        }
        return String(describing: self)
    }
    
    func toDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
}
