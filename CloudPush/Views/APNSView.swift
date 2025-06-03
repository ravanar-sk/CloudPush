//
//  APNSView.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 03/04/25.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

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
    
    
    @State private var p12Password: String = ""
    @State private var keyID: String = ""
    @State private var errorKeyID: String = ""
    @State private var teamID: String = ""
    @State private var errorTeamID: String = ""
    @State private var bundleID: String = ""
    @State private var errorBundleID: String = ""
    @State private var deviceToken: String = ""
    @State private var errorDeviceToken: String = ""
    @State private var isJSON: Bool = true
    @State private var pushPayload: String = ""
    @State private var errorPushPayload: String = ""
    @State private var pushPayloadPreview: String = ""
    @State private var showFilePicker: Bool = false
    
    @State private var pickerFileType: UTType = .p8
    @State private var selectedFile: URL!
    @State private var errorSelectedFile: String = ""
    
    @State private var p8Data: Data!
    
    @State private var successAlert: Bool = false
    @State private var failureAlert: Bool = false
    @State private var failureMessage: String = ""
    
    @State private var apiLoading: Bool = false
    
    @Environment(\.modelContext) var context
    
    
    // SD
    //    @Query private var jwtTokens: [APNSJWTToken]
    
    
    
    
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
    
    var rootView: some View {
        
        VStack(spacing: 10) {
            
            HStack {
                viewOSType
                viewIsDev
            }
            
            HStack {
                
                viewPushType
                viewPriority
            }
            //            .padding(.top, 0)
            VStack {
                HStack(alignment: .top) {
                    viewFileType
                    viewSelectFile
                    
                    if (fileType == .p12) {
                        viewP12Password
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(errorSelectedFile)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
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
        .pickerStyle(.palette)
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
    
    private var viewP12Password: some View {
        RavTextField(title: "Password (Optional)", text: $p12Password, error: "")
    }
    
    private var viewKeyID: some View {
        RavTextField(title: "Key ID", text: $keyID, error: errorKeyID)
    }
    
    private var viewTeamID: some View {
        RavTextField(title: "Team ID", text: $teamID, error: errorTeamID)
    }
    
    private var viewBundleID: some View {
        RavTextField(title: "Bundle ID", text: $bundleID, error: errorBundleID)
    }
    
    private var viewDeviceToken: some View {
        RavTextField(title: "Device Token", text: $deviceToken, error: errorDeviceToken)
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
        VStack {
//            TextEditor(text: $pushPayload)
            JSONTextEditor(text: $pushPayload)
                .frame(maxWidth: .infinity, minHeight: 150)
            Text(errorPushPayload)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(.red)
//            Text(pushPayloadPreview)
//                .frame(maxWidth: .infinity)
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
                    HStack(spacing: 0) {
                        Text("Send")
                        
                        if apiLoading {
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 25, height: 20)
                        }
                            
                    }

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
        
        if (validate()) {
            
            apiLoading = true
            
            if fileType == .p8 {
                
                let body: StringAny! = pushPayload.toDictionary()
                
                APNSController().apnsP8(isDev: isDevelopment,
                                        p8FilePath: selectedFile,
                                        pushType: pushType.rawValue,
                                        priority: priority.rawValue,
                                        keyID: keyID,
                                        teamID: teamID,
                                        bundleID: bundleID,
                                        deviceToken: deviceToken,
                                        body: body) {
                    apiLoading = false
                    successAlert.toggle()
                } failed: { error, message in
                    apiLoading = false
                    failureMessage = message
                    failureAlert.toggle()
                } retry: {
                    sendPushNotification()
                }
            } else {
                
                let body: StringAny! = pushPayload.toDictionary()
                
                APNSController().apnsP12(isDev: isDevelopment,
                                         p12FilePath: selectedFile,
                                         password: p12Password,
                                         pushType: pushType.rawValue,
                                         priority: priority.rawValue,
                                         keyID: keyID,
                                         teamID: teamID,
                                         bundleID: bundleID,
                                         deviceToken: deviceToken,
                                         body: body) {
                    apiLoading = false
                    successAlert.toggle()
                } failed: { error, message in
                    apiLoading = false
                    failureMessage = message
                    failureAlert.toggle()
                }

            }
        }
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
                
                
                
                /*
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
                */
                
                
            }
        }
        
        
        //        showFilePicker = true
    }
}

//MARK:
extension APNSView {
    
    private func validate() -> Bool {
        
        var flag = true
        
        if keyID.isEmpty {
            flag = false
            debugPrint("Key ID is empty")
            errorKeyID = "Enter a valid Key ID"
        } else {
            errorKeyID = ""
        }
        
        if teamID.isEmpty {
            flag = false
            debugPrint("Team ID is empty")
            errorTeamID = "Enter a valid Team ID"
        } else {
            errorTeamID = ""
        }
        
        if bundleID.isEmpty {
            flag = false
            debugPrint("Bundle ID is empty")
            errorBundleID = "Enter a valid bundle ID"
        } else {
            errorBundleID = ""
        }
        
        if deviceToken.isEmpty {
            flag = false
            debugPrint("Bundle ID is empty")
            errorDeviceToken = "Enter a valid device token"
        } else {
            errorDeviceToken = ""
        }
        
        if let _: StringAny = pushPayload.toDictionary() {
            errorPushPayload = ""
        } else {
            errorPushPayload = "Enter a valid JSON payload"
        }
        
        if selectedFile == nil {
            flag = false
            debugPrint("Select a file")
            errorSelectedFile = "Please select a certificate file"
        } else {
            errorSelectedFile = ""
        }
        
        return flag
    }
    
//    private func checkIfEntryExists() -> Bool {
//        let searchPredicate = #Predicate<APNSJWTToken> { item in
//            return ((item.keyID == keyID) && (item.teamID == teamID)) && (item.p8 == p8Data)
//        }
//        //        let searchQuery = Query(filter: searchPredicate)
//        let fetchDescriptor = FetchDescriptor<APNSJWTToken>(predicate: searchPredicate)
//        //        context.fetch
//        
//        do {
//            let count = try context.fetchCount(fetchDescriptor)
//            return count > 0
//        } catch {
//            debugPrint(error.localizedDescription)
//            return false
//        }
//    }
    
//    private func getPreviousItem() -> APNSJWTToken? {
//        let searchPredicate = #Predicate<APNSJWTToken> { item in
//            return ((item.keyID == keyID) && (item.teamID == teamID)) && (item.p8 == p8Data)
//        }
//        //        let searchQuery = Query(filter: searchPredicate)
//        let fetchDescriptor = FetchDescriptor<APNSJWTToken>(predicate: searchPredicate)
//        //        context.fetch
//        
//        do {
//            let items = try context.fetch(fetchDescriptor)
//            
//            if items.count == 1 {
//                return items[0]
//            } else if items.count > 1 {
//                debugPrint("Count is more than 1 and this should not happen")
//                return nil
//            } else {
//                return nil
//            }
//        } catch {
//            debugPrint(error.localizedDescription)
//            return nil
//        }
//    }
    
//    private func deletePreviousItem() {
//        if let previousItem = getPreviousItem() {
//            context.delete(previousItem)
//            do {
//                try context.save()
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
//        }
//    }
}

#Preview {
    APNSView()
}
