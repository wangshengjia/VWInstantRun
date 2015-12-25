//
//  NSObject_Extension.swift
//
//  Created by Victor WANG on 20/12/15.
//  Copyright © 2015 Victor Wang. All rights reserved.
//

import Foundation

extension NSObject {
    class func pluginDidLoad(bundle: NSBundle) {
        let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
        	if sharedPlugin == nil {
        		sharedPlugin = VWInstantRun(bundle: bundle)
        	}
        }
    }
}