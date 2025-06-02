//
//  FCMView.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import SwiftUI

struct FCMView: View {
    
    @State var credentialFile: URL?
    
    @State var validateOnly: Bool = false
    
    @State var deviceTokenPlaceholder: String = FCMPushDestinations.device.rawValue
    @State var deviceToken: String = ""
    @State var pushPayload: String = ""
    @State var pushPayloadPreview: String = ""
    
    @State var errorSelectedFile: String = ""
    @State var errorDeviceToken: String = ""
    @State var errorPayload: String = ""
    
    @State private var successAlert: Bool = false
    @State private var failureAlert: Bool = false
    @State private var failureMessage: String = ""
    
    
    @State private var pushDestination: FCMPushDestinations = .device
    
    var body: some View {
        //        Text("Hello, World! FCm")
        rootView
            .onAppear() {
                pushPayload = defaultFCMJSONPayload.toJSONString() ?? ""
            }
            .onChange(of: pushDestination) { oldValue, newValue in
                deviceTokenPlaceholder = newValue.rawValue
            }
            .alert(Text("Success"), isPresented: $successAlert) {
                Button("OK") {
                    successAlert.toggle()
                }
            } message: {
                Text("Push Sent Successfully")
            }
            .alert(Text("Failed"), isPresented: $failureAlert) {
                Button("OK") {
                    failureAlert.toggle()
                }
            } message: {
                Text(failureMessage)
            }
    }
    
    private var rootView: some View {
        
        VStack(spacing: 10) {
            
            HStack(alignment: .top) {
                viewValidateOnly
                viewSelectFile
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            viewPushDestination
            viewDeviceToken
            viewPayload
            viewSendButton
        }
    }
    
    private var viewSelectFile: some View {
        VStack( alignment: .leading){
            Button {
                selectAuthFile()
            } label: {
                Label {
                    Text(credentialFile?.lastPathComponent ?? "Select Credential File")
                    //                Text("Empty")
                } icon: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 15))
                }
                
            }
            Text(errorSelectedFile)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(.red)
        }
    }
    
    
    private var viewValidateOnly: some View {
        Toggle(isOn: $validateOnly) {
            Text("Validate Only")
        }
    }
    
    private var viewPushDestination: some View {
        Picker("Push Destination: ", selection: $pushDestination) {
            ForEach(FCMPushDestinations.allCases, id: \.self) { item in
                Text(item.rawValue)
            }
        }
        .pickerStyle(.palette)
    }
    
    private var viewDeviceToken: some View {
        VStack {
            RavTextField(title: deviceTokenPlaceholder, text: $deviceToken, error: "")
            Text(errorDeviceToken)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(.red)
        }
    }
    
    var viewPayload: some View {
        // Row 8
        VStack {
//            TextEditor(text: $pushPayload)
            JSONTextEditor(text: $pushPayload)
                .frame(maxWidth: .infinity, minHeight: 150)
            
//            Text(pushPayloadPreview)
//                .frame(maxWidth: .infinity)
            Text(errorPayload)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(.red)
        }
    }
    
    var viewSendButton: some View {
        // Row 9
        HStack {
            //            Spacer()
            Button {
                sendPushNotification()
            } label: {
                Label {
                    Text("Send")
                } icon: {
                    Image(systemName: "paperplane.fill")
                }
                .font(.system(size: 15))
                .padding(.all,5)
            }
        }
        .frame(maxWidth: .infinity)
        //        .background(.red)
    }
}

extension FCMView {
    private func selectAuthFile() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select File"
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                DispatchQueue.main.async {
                    self.credentialFile = url
                }
            }
        }
    }
}

extension FCMView {
    
    private func validForm() -> Bool {
        var flag = true
                
        
        if deviceToken.isEmpty {
            flag = false
            debugPrint("Please add a valid device token")
            errorDeviceToken = "Please add a valid device token"
        } else {
            errorDeviceToken = ""
        }
        
        if credentialFile == nil {
            flag = false
            debugPrint("Please select a google credential file")
            errorSelectedFile = "Please select a google credential file"
        } else {
            errorSelectedFile = ""
        }
        
        if let _: [String:Any] = pushPayload.toDictionary() {
            errorPayload = ""
        } else {
            flag = false
            debugPrint("Please add valid JSON payload")
            errorPayload = "Please add valid JSON payload"
        }
        
        return flag
    }
    
    private func sendPushNotification() {
        
        if validForm() {
            
            var payload: [String:Any] = pushPayload.toDictionary()!
//            var payload: [String:Any] = defaultFCMJSONPayload
            
            
            
            switch pushDestination {
                
            case .device:
                payload["token"] = deviceToken
            case .topic:
                payload["topic"] = deviceToken
            }
            
            
            let body: StringAny = [
                "validate_only": validateOnly,
                "message": payload
            ]
            
            
            FCMController(credentialsURL: credentialFile!).send(body: body) {
                debugPrint("Success")
                successAlert.toggle()
            } failed: { message in
                debugPrint("Failed: \(message)")
                failureMessage = message
                failureAlert.toggle()
            }

        }
    }
    
    
}


#Preview {
    FCMView()
}
