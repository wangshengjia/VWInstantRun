//
//  VWXcodeHelpers.swift
//  VWInstantRun
//
//  Created by Victor WANG on 25/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation
import AppKit

class VWXcodeHelpers {
    static func appendLogText(logText: String) {

        guard let consoleTextView = consoleTextView(),
            let textStorage = consoleTextView.valueForKey("textStorage") as? NSTextStorage where !logText.isEmpty else {
                return
        }

        textStorage.beginEditing()
        textStorage.appendAttributedString(NSAttributedString(string: logText, attributes: [NSFontAttributeName:NSFont.boldSystemFontOfSize(NSFont.systemFontSize())]))
        textStorage.endEditing()
        consoleTextView.performSelector("_scrollToBottom")
    }

    static func selectedLines() -> String? {
        guard let textView = editorTextView() where textView.selectedRanges.isEmpty != true,
            let textInView: NSString = textView.textStorage?.string,
            let range = textView.selectedRanges.first?.rangeValue else {
                return nil
        }

        return textInView.substringWithRange(textInView.lineRangeForRange(range))
    }

    static func editorTextView(inWindow window: NSWindow? = NSApp.mainWindow) -> NSTextView? {
        guard let window = window,
            let windowController = window.windowController,
            let editor = windowController.valueForKeyPath("editorArea.lastActiveEditorContext.editor"),
            let textView = editor.valueForKey("textView") as? NSTextView else {
                return nil
        }

        return textView
    }

    static func consoleTextView(inWindow window: NSWindow? = NSApp.mainWindow) -> NSTextView? {
        if let contentView = window?.contentView,
            let consoleTextView = VWXcodeHelpers.getViewByClassName("IDEConsoleTextView", inContainer: contentView) as? NSTextView {
                return consoleTextView
        }
        
        return nil
    }
    
    static func getViewByClassName(name: String, inContainer container: NSView) -> NSView? {
        guard let targetClass = NSClassFromString(name) else {
            return nil
        }
        for subview in container.subviews {
            if subview.isKindOfClass(targetClass) {
                return subview
            }

            if let view = getViewByClassName(name, inContainer: subview) {
                return view
            }
        }

        return nil
    }
}