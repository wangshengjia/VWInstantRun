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

        showDebugAreaIfNeeded()

        let attibutes: Dictionary<String, AnyObject>
        if let debuggedTargetOutputTextAttributes = consoleTextView.valueForKeyPath("_debuggedTargetOutputTextAttributes") as? Dictionary<String, AnyObject> {
            attibutes = debuggedTargetOutputTextAttributes
        } else {
            attibutes = [NSFontAttributeName: NSFont.boldSystemFontOfSize(NSFont.systemFontSize())]
        }

        textStorage.beginEditing()
        textStorage.appendAttributedString(NSAttributedString(string: logText, attributes: attibutes))
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
        guard let editorArea = xcodeEditorArea(),
            let editor = editorArea.valueForKeyPath("lastActiveEditorContext.editor"),
            let textView = editor.valueForKey("textView") as? NSTextView else {
                return nil
        }

        return textView
    }

    static func consoleTextView(inWindow window: NSWindow? = NSApp.mainWindow) -> NSTextView? {
        if let contentView = window?.contentView,
            let consoleTextView = getViewByClassName("IDEConsoleTextView", inContainer: contentView) as? NSTextView {
                return consoleTextView
        }
        
        return nil
    }


}

extension VWXcodeHelpers {
    private static func showDebugAreaIfNeeded(inWindow window: NSWindow? = NSApp.mainWindow) {
        if let editor = xcodeEditorArea(),
            let showDebuggerArea = editor.valueForKey("showDebuggerArea") as? Bool where showDebuggerArea == false {
                editor.performSelector("toggleDebuggerVisibility:")
        }
    }

    private static func xcodeEditorArea(inWindow window: NSWindow? = NSApp.mainWindow) -> AnyObject? {
        guard let window = window, let windowController = window.windowController,
            let editor = windowController.valueForKeyPath("editorArea") else {
                return nil
        }

        return editor
    }

    private static func getViewByClassName(name: String, inContainer container: NSView) -> NSView? {
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
