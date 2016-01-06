//
//  VWFileIO.swift
//  VWInstantRun
//
//  Created by Victor WANG on 25/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation

class VWFileIO {

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

    static func prepareTempDirectory() throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(VWFileIO.tempDirectory) {
            for file in try fileManager.contentsOfDirectoryAtPath(VWFileIO.tempDirectory) {
                let filePath = (VWFileIO.tempDirectory as NSString).stringByAppendingPathComponent(file)
                try fileManager.removeItemAtPath(filePath)
            }
        } else {
            try fileManager.createDirectoryAtPath(VWFileIO.tempDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    static func writeToObjcMainFileWithText(text: String) throws {
        let textWithMain =
        "#import <Foundation/Foundation.h> \n\n"
            + "int main(int argc, char * argv[]) {\n"
            +    "\n\(text)\n"
            + "\n}\n"

        try textWithMain.writeToFile(objcMainFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    }

    static func writeToSwiftMainFileWithText(text: String) throws {
        try text.writeToFile(swiftMainFilePath, atomically: true, encoding: NSUTF8StringEncoding)
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