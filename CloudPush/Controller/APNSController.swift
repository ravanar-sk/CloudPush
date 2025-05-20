//
//  APNSController.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation
import SwiftData

class APNSController: NSObject {
    private let devURL = "https://api.sandbox.push.apple.com"
    private let prodURL = "https://api.push.apple.com"
    private var isP8: Bool = true
    
    
    private var identity: SecIdentity!
    private var certificates: [SecCertificate]!
}

// MARK: P8 key authentication
extension APNSController {
    
    func apnsP8(isDev: Bool,
                   p8FilePath: URL,
                   pushType: String,
                   priority: String,
                   keyID: String,
                   teamID: String,
                   bundleID: String,
                   deviceToken: String,
                   body: StringAny,
                success: @escaping () -> Void,
                failed: @escaping (_ error: Int,_ message: String) -> Void,
                retry: @escaping ()-> Void) {
        
        self.isP8 = true
        
        
        
        let jwt = JWTTokenGenerator(keyID: keyID, teamID: teamID, p8FilePath: p8FilePath).build()
        
        guard var token = jwt.token, let p8 = jwt.p8  else { return }
        
        if checkIfEntryExists(keyID: keyID, teamID: teamID, p8Data: p8),
            let previousItem = getPreviousItem(keyID: keyID, teamID: teamID, p8Data: p8) {
            let previousToken = previousItem.token
            let previousP8Data = previousItem.p8
            
            token = previousToken
            
        } else {
            let jwtToken = APNSJWTToken(keyID: keyID, teamID: teamID, p8: p8, token: token)
            SDCoordinator.shared.insert(jwtToken)
        }
        
        debugPrint("Bearer Token: \(token)");
        
        //        context.
        //        context.fetch(FetchDescriptor<APNSJWTToken>())
        
        
        let header: StringString = [
            "apns-topic" : bundleID,
            "apns-push-type" : pushType,
            "apns-priority" : priority,
            "authorization":"bearer \(token)"
        ]
        
        let params = body.toJSONString() ?? ""
        
        let urlString = "\(isDev ? devURL : prodURL)/3/device/\(deviceToken)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        for (key, value) in header {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let data = params.toData() {
            request.httpBody = data
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    success()
                } else {
                    if let dictResponse = data?.toDictionary(), let reason = dictResponse["reason"] as? String {
                        
                        if statusCode == 403 && reason == "ExpiredProviderToken" {
                            self.deletePreviousItem(keyID: keyID, teamID: teamID, p8Data: p8)
                            retry()
                        } else {
                            failed(statusCode, reason)
                        }
                        
                    } else {
                        debugPrint("Dictionary response conversion error")
                    }
                }
                
                
            } else {
                debugPrint("HTTPURLResponse conversion error")
            }
            
            
            debugPrint("""
\(#function)
data -> \(String(describing: data?.debugDescription))

dataString -> \(String(describing: data?.toJSONString()))

response -> \(response.debugDescription)

error -> \(error.debugDescription)
""")
        }
        
        dataTask.resume()
    }
    
    
    private func checkIfEntryExists(keyID: String, teamID: String, p8Data: Data) -> Bool {
        let searchPredicate = #Predicate<APNSJWTToken> { item in
            return ((item.keyID == keyID) && (item.teamID == teamID)) && (item.p8 == p8Data)
        }
        //        let searchQuery = Query(filter: searchPredicate)
        let fetchDescriptor = FetchDescriptor<APNSJWTToken>(predicate: searchPredicate)
        //        context.fetch
        
        do {
            let count = try SDCoordinator.shared.fetchCount(fetchDescriptor)
            return count > 0
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    private func getPreviousItem(keyID: String, teamID: String, p8Data: Data) -> APNSJWTToken? {
        let searchPredicate = #Predicate<APNSJWTToken> { item in
            return ((item.keyID == keyID) && (item.teamID == teamID)) && (item.p8 == p8Data)
        }
        //        let searchQuery = Query(filter: searchPredicate)
        let fetchDescriptor = FetchDescriptor<APNSJWTToken>(predicate: searchPredicate)
        //        context.fetch
        
        do {
            let items = try SDCoordinator.shared.fetch(fetchDescriptor)
            
            if items.count == 1 {
                return items[0]
            } else if items.count > 1 {
                debugPrint("Count is more than 1 and this should not happen")
                return nil
            } else {
                return nil
            }
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    private func deletePreviousItem(keyID: String, teamID: String, p8Data: Data) {
        if let previousItem = getPreviousItem(keyID: keyID, teamID: teamID, p8Data: p8Data) {
            SDCoordinator.shared.delete(previousItem)
            do {
                try SDCoordinator.shared.save()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}


// MARK: P12 key authentication
extension APNSController: URLSessionDelegate {
    
    func apnsP12(isDev: Bool,
                 p12FilePath: URL,
                 password: String,
                 pushType: String,
                 priority: String,
                 keyID: String,
                 teamID: String,
                 bundleID: String,
                 deviceToken: String,
                 body: StringAny,
                 success: @escaping () -> Void,
                 failed: @escaping (_ error: Int,_ message: String) -> Void) {
        
        self.isP8 = false
        
        
        
        do {
            let p12Data = try Data(contentsOf: p12FilePath)
            
            let options: [String: Any] = [
                kSecImportExportPassphrase as String: password
            ]
            
            var items: CFArray?
            let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)
            
            if status == errSecSuccess, let items = items as? [[String: Any]], let firstItem = items.first {
                identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity
                certificates = firstItem[kSecImportItemCertChain as String] as? [SecCertificate]
                
                print("Identity: \(String(describing: identity))")
                print("Certificates: \(String(describing: certificates))")
                
                // Optionally, export or use the identity/certs
            } else {
                print("Failed to import .p12 file: \(status)")
            }
        } catch {
            print("Error reading .p12 file: \(error)")
        }
        
        
        
        let header: StringString = [
            "apns-topic" : bundleID,
            "apns-push-type" : pushType,
            "apns-priority" : priority,
            "authorization":"bearer \(deviceToken)"
        ]
        
        let params = body.toJSONString() ?? ""
        
        let urlString = "\(isDev ? devURL : prodURL)/3/device/\(deviceToken)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        for (key, value) in header {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let data = params.toData() {
            request.httpBody = data
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    success()
                } else {
                    if let dictResponse = data?.toDictionary(), let reason = dictResponse["reason"] as? String {
                        failed(statusCode, reason)
                    } else {
                        debugPrint("Dictionary response conversion error")
                    }
                }
                
                
            } else {
                debugPrint("HTTPURLResponse conversion error")
            }
            
            
            debugPrint("""
\(#function)
data -> \(String(describing: data?.debugDescription))

dataString -> \(String(describing: data?.toJSONString()))

response -> \(response.debugDescription)

error -> \(error.debugDescription)
""")
        }
        
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if isP8 {
            
        } else {
            let credential = URLCredential(identity: identity, certificates: certificates, persistence: .none)
            completionHandler(.useCredential, credential)
        }
    }
}

