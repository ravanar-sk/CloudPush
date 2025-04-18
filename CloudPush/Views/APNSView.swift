//
//  APNSView.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let p12 = UTType(importedAs: "com.rsa.pkcs-12")
    static let p8 = UTType(importedAs: "com.example.p8")
}



struct APNSView: View {
    
    @State private var osType: APNSOSType = .iOS
    @State private var fileType: APNSAuthFileType = .p8
    @State private var isDevelopment: Bool = true
    
    @State private var pushType: APNSPushType = .alert
    @State private var arrayPushType: [APNSPushType] = Array(apns[.iOS]!.keys)
    
    @State private var priority: APNSPriority = ._10
    @State private var arrayPriority: [APNSPriority] = apns[.iOS]![.alert]!.priority
    
    
    @State private var keyID: String = "DFZGZ7KY49"
    @State private var teamID: String = "NHS5DQA5B5"
    @State private var bundleID: String = "com.qatarrail.QRailCustomerApp"
    @State private var deviceToken: String = ""
    @State private var isJSON: Bool = true
    @State private var pushPayload: String = "Hello Dear"
    @State private var pushPayloadPreview: String = "Hello Dada"
    @State private var showFilePicker: Bool = false

    @State private var pickerFileType: UTType = .p8
    @State private var selectedFile: URL?
    
    
    var body: some View {
        rootView
            .onAppear() {
                pushPayload = defaultAPNSJSONPayload.toJSONString() ?? ""
            }
            .onDisappear() {
                
            }
            .onChange(of: osType) { oldValue, newValue in
                let pushTypes = apns[newValue]!
                arrayPushType = Array(pushTypes.keys)
                
                pushType = arrayPushType.first!
            }
            .onChange(of: pushType) { oldValue, newValue in
                arrayPriority = apns[osType]![newValue]!.priority
                priority = arrayPriority.first!
            }
            .onChange(of: fileType, { oldValue, newValue in
                switch newValue {
                    
                case .p8:
                    pickerFileType = .p8
                    selectedFile = nil
                case .p12:
                    pickerFileType = .p12
                    selectedFile = nil
                }
            })
    }
    
    var rootView: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                viewOSType
                viewPushType
                viewPriority
            }
//            .padding(.top, 0)
            
            HStack(alignment: .top) {
                viewFileType
                viewSelectFile
                viewIsDev
            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(.cyan)
//            .frame(maxWidth: .infinity, alignment: .top)
//            .background(.red)
            
            HStack {
                viewKeyID
                viewTeamID
            }
            viewBundleID
            viewDeviceToken
            
//            viewIsJSON
            viewPayload
            viewSendButton
        }
    }
    
    private var viewOSType: some View {
            Picker("OS Type", selection: $osType) {
                ForEach(APNSOSType.allCases, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
    }
    
    private var viewPushType: some View {
            Picker("Push Type", selection: $pushType) {
                ForEach(arrayPushType, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
    }
    
    private var viewPriority: some View {
            Picker("Priority", selection: $priority) {
                ForEach(arrayPriority, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
    }
    
    private var viewFileType: some View {
        Picker("File Type", selection: $fileType) {
            ForEach(APNSAuthFileType.allCases, id: \.self) { item in
                Text(item.rawValue)
            }
        }
        .pickerStyle(.inline)
    }
    
    private var viewSelectFile: some View {
        Button {
            selectAuthFile()
        } label: {
            Label {
                Text(selectedFile?.lastPathComponent ?? "Select File")
//                Text("Empty")
            } icon: {
                Image(systemName: "paperclip")
                    .font(.system(size: 15))
            }

        }
    }
    
    private var viewIsDev: some View {
        Toggle(isOn: $isDevelopment) {
            Text("is Development")
        }
    }
    
    private var viewKeyID: some View {
        RavTextField(title: "Key ID", text: $keyID, error: "Some Error")
    }
    
    private var viewTeamID: some View {
        RavTextField(title: "Team ID", text: $teamID, error: "Some Error")
    }
  
    private var viewBundleID: some View {
        RavTextField(title: "Bundle ID", text: $bundleID, error: "Some Error")
    }
    
    private var viewDeviceToken: some View {
        RavTextField(title: "Device Token", text: $deviceToken, error: "Some Error")
    }
            
    private var viewIsJSON: some View {
        // Row 7
        HStack {
            Toggle(isOn: $isJSON) {
                Text("JSON")
            }
            
            Spacer()
        }
    }
    var viewPayload: some View {
        // Row 8
        HStack {
            TextEditor(text: $pushPayload)
                .frame(maxWidth: .infinity, minHeight: 150)
            
            Text(pushPayloadPreview)
                .frame(maxWidth: .infinity)
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

//MARK: Button Actions
extension APNSView {
    
    private func sendPushNotification() {
        print(#function)
        
        //TODO: Implement Fields Validation and then procees with this
        
        guard let token = JWTTokenGenerator(keyID: keyID, teamID: teamID, p8FilePath: selectedFile!).build() else { return }
        
        debugPrint("Bearer Token: \(token ?? "")");

        
        let header: StringString = [
            "apns-topic" : bundleID,
            "apns-push-type" : pushType.rawValue,
            "apns-priority" : priority.rawValue,
            "authorization":"bearer \(token)"
        ]
        
        let body = pushPayload
        
        APNSController().apnsP8(isDev: isDevelopment, header: header, params: body, deviceToken: deviceToken
        )
        
        
        
        
    }
    
    private func selectAuthFile() {
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Select File"
        openPanel.allowedContentTypes = [pickerFileType]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {

                DispatchQueue.main.async {
                    self.selectedFile = url
                }

                    
                
                
                switch pickerFileType {
                case .p8:
                    do {
                        let content = try String(contentsOf: url, encoding: .utf8)
                        print("File content:\n\(content)")
                    } catch {
                        print("Failed to read file: \(error)")
                    }
                case .p12:
                    do {
                            let p12Data = try Data(contentsOf: url)

                            let options: [String: Any] = [
                                kSecImportExportPassphrase as String: "12345678"
                            ]

                            var items: CFArray?
                            let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)

                            if status == errSecSuccess, let items = items as? [[String: Any]], let firstItem = items.first {
                                let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity
                                let certs = firstItem[kSecImportItemCertChain as String] as? [SecCertificate]

                                print("Identity: \(String(describing: identity))")
                                print("Certificates: \(String(describing: certs))")

                                // Optionally, export or use the identity/certs
                            } else {
                                print("Failed to import .p12 file: \(status)")
                            }
                        } catch {
                            print("Error reading .p12 file: \(error)")
                        }
                default:
                    debugPrint("Default")
                }
                
                
            }
        }
        
        
//        showFilePicker = true
    }
}

#Preview {
    APNSView()
}
