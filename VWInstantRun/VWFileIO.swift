//
//  VWFileIO.swift
//  VWInstantRun
//
//  Created by Victor WANG on 25/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation

class VWFileIO {
    static func writeToMainFileWithText(text: String) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(VWFileIO.tempDirectory) {
            for file in try fileManager.contentsOfDirectoryAtPath(VWFileIO.tempDirectory) {
                let filePath = (VWFileIO.tempDirectory as NSString).stringByAppendingPathComponent(file)
                try fileManager.removeItemAtPath(filePath)
            }
        } else {
            try fileManager.createDirectoryAtPath(VWFileIO.tempDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        try text.writeToFile(swiftMainFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    }

    static var tempDirectory: String {
        return (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("com.instant-run.tmp")
    }

    static var swiftMainFilePath: String {
        return (tempDirectory as NSString).stringByAppendingPathComponent("main.swift")
    }

    static var objcMainFilePath: String {
        return (tempDirectory as NSString).stringByAppendingPathComponent("main.m")
    }

    static var outputBinaryFilePath: String {
        return (tempDirectory as NSString).stringByAppendingPathComponent("run")
    }
}

extension VWFileIO {
    static func removeItemAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        guard fileManager.fileExistsAtPath(path) else {
            return
        }

        do {
            try fileManager.removeItemAtPath(path)
        } catch {
            print(error)
        }
    }
}