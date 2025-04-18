//
//  RavTextField.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 14/04/25.
//

import SwiftUI

struct RavTextField: View {
    
    let title: String
    @Binding var text: String
    let error: String
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(title, text: $text)
//                .font(.system(size: 18))
            if error.count > 0 {
                Text(error)
                    .font(.system(size: 8))
                    .foregroundColor(.red)
            }
        }
        .frame(alignment: .trailing)
        
    }
}

#Preview {
    RavTextField(title: "Title", text: .constant(""), error: "Error")
//    RavTextField(text: .constant(""))
}
