//
//  JWTTokenGenerator.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 11/04/25.
//

import Foundation
import SwiftJWT

struct JWTTokenGenerator {
    
    private let keyID: String // DFZGZ7KY49
    private let teamID: String // NHS5DQA5B5
    private let p8FilePath: URL
    
    init(keyID: String, teamID: String, p8FilePath: URL) {
        self.keyID = keyID
        self.teamID = teamID
        self.p8FilePath = p8FilePath
    }
    
    @discardableResult
    func build() -> String? {
        guard let privateKey = readFile() else { return nil }
        
        
        let header = Header(typ: nil, kid: keyID)
        let claims = APNSJWTClaims(iss: teamID, iat: Date())
        
        var myJWT = JWT(header: header, claims: claims)
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        
        do  {
            
            let signedJWT = try myJWT.sign(using: jwtSigner)
            return signedJWT
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
//    private func readFile() -> String? {
//        do {
//            let fileContents = try String(contentsOf: p8FilePath, encoding: .utf8)
//            debugPrint("fileContents : \(fileContents)")
//            return fileContents
//        } catch {
//            debugPrint(error.localizedDescription)
//        }
//        
//        return nil
//    }
    
    private func readFile() -> Data? {
        do {
            let fileContents = try Data(contentsOf: p8FilePath)
            debugPrint("fileContents : \(fileContents)")
            return fileContents
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return nil
    }
    
}

fileprivate struct APNSJWTClaims: Claims {
    var iss: String?
    var iat: Date?
}
