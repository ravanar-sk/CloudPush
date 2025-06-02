//
//  JSONTextEditor.swift
//  CloudPush
//
//  Created by Saravana Kumar K R on 02/06/25.
//

import AppKit
import SwiftUI

struct JSONTextEditor: NSViewRepresentable {
//    typealias NSViewType = NSScrollView
    
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.delegate = context.coordinator
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
        }
    }
    
    static func dismantleNSView(_ nsView: NSScrollView, coordinator: Coordinator) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        textView.delegate = nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

extension JSONTextEditor {
    class Coordinator: NSObject, NSTextViewDelegate {
            var parent: JSONTextEditor

            init(_ parent: JSONTextEditor) {
                self.parent = parent
            }

            func textDidChange(_ notification: Notification) {
                guard let textView = notification.object as? NSTextView else { return }
                parent.text = textView.string
            }
        }
}
