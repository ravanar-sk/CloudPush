//
//  FCMTokenGenerator.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 20/05/25.
//

import Foundation
import OAuth2
import SwiftJWT

struct FCMTokenGenerator {
    
    private let scopes = ["https://www.googleapis.com/auth/firebase.messaging"]

    let credentialsURL: URL
    
    init(credentialsURL: URL) {
        self.credentialsURL = credentialsURL
    }
    
}

// MARK: Auth Token Generation
extension FCMTokenGenerator {
    private func generateAuthToken(_ credentialsURL: URL,  success: @escaping (String) -> Void, failed: @escaping (Error) -> Void) {
        do {
            let tokenProvider = ServiceAccountTokenProvider(credentialsURL: credentialsURL,
                                        scopes: scopes)
            try tokenProvider?.withToken { token, error in
                if let error = error {
                    debugPrint("Error fetching token: \(error.localizedDescription)")
                    failed(error)
                }
                
                if let accessToken = token?.AccessToken {
                    debugPrint("Access token: \(accessToken)")
                    success(accessToken)
                }
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

// MARK: Auth Token Generation
extension FCMTokenGenerator {
    
    func build(_ callback: @escaping (String?,Error?) -> Void) {
        generateAuthToken(credentialsURL) { accessToken in
            callback(accessToken, nil)
        } failed: { error in
            callback(nil, error)
        }
    }
}
