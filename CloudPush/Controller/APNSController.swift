//
//  APNSController.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import Foundation

struct APNSController {
    
    private let devURL = "https://api.sandbox.push.apple.com"
    private let prodURL = "https://api.push.apple.com"
    
    
    func apnsP8(isDev: Bool, header: StringString, params: String, deviceToken: String) {
        
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
            
            debugPrint("""
\(#function)
data -> \(data?.debugDescription)

dataString -> \(data?.toJSONString())

response -> \(response.debugDescription)

error -> \(error.debugDescription)
""")
        }
        
        dataTask.resume()
    }
}
