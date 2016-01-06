//
//  VWInstantRun.swift
//
//  Created by Victor WANG on 20/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation
import AppKit

var sharedPlugin: VWInstantRun?

class VWInstantRun: NSObject {
    // TODO: support more modules
    static let modules = ["Foundation"]

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        center.addObserver(self, selector: Selector("createMenuItems"), name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }

    deinit {
        removeObserver()
    }

    func removeObserver() {
        center.removeObserver(self)
    }

    func createMenuItems() {
        removeObserver()

        let item = NSApp.mainMenu?.itemWithTitle("Product")
        if item != nil {
            let actionMenuItem = NSMenuItem(title:"Instant Run", action:"instantRun", keyEquivalent:"")
            actionMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.ShiftKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
            actionMenuItem.keyEquivalent = "R"
            actionMenuItem.target = self
            item!.submenu!.addItem(NSMenuItem.separatorItem())
            item!.submenu!.addItem(actionMenuItem)
        }
    }

}

extension VWInstantRun {
    func instantRun() {
        guard let selectedLines = VWXcodeHelpers.selectedLines() else {
            return
        }

        guard let _ = try? VWFileIO.prepareTempDirectory() else {
            return
        }

            guard let _ = try? VWFileIO.writeToSwiftMainFileWithText(importModules() + selectedLines) else {
                return
            }

            VWPluginHelper.buildWithSwift(onCompletion: VWPluginHelper.run)
    }

    private func importModules() -> String {
        return VWInstantRun.modules.map({ (module) -> String in
            return "import " + module
        }).joinWithSeparator("\n") + "\n"
    }
}
