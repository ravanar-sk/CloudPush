//
//  FCMController.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

class FCMController {
    
    let credentialsURL: URL
    
    
    
    init(credentialsURL: URL) {
        self.credentialsURL = credentialsURL
    }
    
    func urlString(_ projectID: String) -> String {
        return "https://fcm.googleapis.com/v1/projects/\(projectID)/messages:send"
    }
    
}

extension FCMController {
    
    func send(body: StringAny,success: @escaping () -> Void, failed: @escaping (_ message:String) -> Void) -> Void {
        
        guard let data = try? Data(contentsOf: credentialsURL) else {
            failed("Credential file is not found")
            return
        }
        
        guard let credentials: [String:Any] = data.toDictionary() else {
            failed("Credential file format is invalid")
            return
        }
        
        guard let projectId = credentials["project_id"] as? String else {
            failed("Project ID is undefined")
            return
        }
        
        let urlString = urlString(projectId)    
        
        FCMTokenGenerator(credentialsURL: credentialsURL).build { authToken, error in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                failed(error.localizedDescription)
            } else if let authToken = authToken {
                debugPrint("authToken : \(authToken)")
                
                let header: StringString = [
                    "Authorization": "Bearer \(authToken)"
                ]
                
                var request = URLRequest(url: URL(string: urlString)!)
                request.httpMethod = "POST"
                
                for (key, value) in header {
                    request.addValue(value, forHTTPHeaderField: key)
                }
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                if let data = body.toData() {
                    request.httpBody = data
                }
                
                let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if let error = error {
                        
                        if let dictResponse: [String:Any] = data?.toDictionary(), let errorCode = dictResponse["error_code"] {
                            failed("\(errorCode) - \(error.localizedDescription)")
                        } else {
                            failed(error.localizedDescription)
                        }
                    } else if let response = response as? HTTPURLResponse {
                        
                        let statusCode = response.statusCode
                        
                        if statusCode == 200 {
                            success()
                        } else {
                            failed("Error \(statusCode)")
                        }
                    } else {
                        debugPrint("Limbo")
                        failed("Error Limbo")
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
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
}
