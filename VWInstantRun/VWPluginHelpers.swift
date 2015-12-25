//
//  VWPluginHelpers.swift
//  VWInstantRun
//
//  Created by Victor WANG on 20/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation

class VWPluginHelper: NSObject {
    static func run(output: String?) {
        logOutput(output)
        VWFileIO.removeItemAtPath(VWFileIO.swiftMainFilePath)
        VWFileIO.removeItemAtPath(VWFileIO.objcMainFilePath)
        executeBinaryFile { (output) -> () in
            logOutput(output)
            VWFileIO.removeItemAtPath(VWFileIO.outputBinaryFilePath)
        }
    }

    static func logOutput(output: String?) {
        guard let output = output where !output.isEmpty else {
            return
        }

        VWXcodeHelpers.appendLogText(output)
    }

    static func buildWithObjC(onCompletion completionHandler:(output: String?) -> () = VWPluginHelper.run) {
        guard NSFileManager.defaultManager().fileExistsAtPath(VWFileIO.objcMainFilePath) else {
            return
        }

        runShellCommand(["/usr/bin/xcrun", "/usr/bin/clang", "-fobjc-arc", "-framework", "Foundation", VWFileIO.objcMainFilePath, "-o", VWFileIO.outputBinaryFilePath], commandTerminationHandler: completionHandler)
    }

    static func buildWithSwift(onCompletion completionHandler:(output: String?) -> () = VWPluginHelper.run) {
        guard NSFileManager.defaultManager().fileExistsAtPath(VWFileIO.swiftMainFilePath) else {
            return
        }

        runShellCommand(["/usr/bin/xcrun", "/usr/bin/swiftc", VWFileIO.swiftMainFilePath, "-o", VWFileIO.outputBinaryFilePath], commandTerminationHandler: completionHandler)
    }

    static func executeBinaryFile(onCompletion completionHandler:(output: String?) -> () = VWPluginHelper.logOutput) {
        guard NSFileManager.defaultManager().fileExistsAtPath(VWFileIO.outputBinaryFilePath) else {
            return
        }

        runShellCommand([VWFileIO.outputBinaryFilePath], commandTerminationHandler: completionHandler)
    }

    static func runShellCommand(components: Array<String>, commandTerminationHandler: (output: String?) -> ()) {
        guard !components.isEmpty else {
            return
        }

        let outputPipe = NSPipe()
        let errorPipe = NSPipe()
        let task = NSTask()
        task.launchPath = components.first
        task.arguments = (components.count > 1) ? Array(components[1...components.count-1]) : []
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.launch()
        task.terminationHandler = { (task: NSTask) -> () in
            var output: String? = nil, error: String? = nil
            if let pipe = task.standardOutput as? NSPipe {
                output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
            }

            if let pipe = task.standardError as? NSPipe {
                error = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
            }

            // TODD: make it better
            if (output == nil) || (output!.isEmpty) {
                output = error
            }

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                commandTerminationHandler(output: output)
            })
        }
    }
}
