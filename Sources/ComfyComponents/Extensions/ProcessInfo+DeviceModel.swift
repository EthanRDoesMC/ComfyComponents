//
//  ProcessInfo+DeviceModel.swift
//  ComfyComponents
//
//  Created by Ethan Chaffin on 3/5/26.
//

import Foundation
import SystemConfiguration

public extension ProcessInfo {
    var deviceModel: String {
        var systemInfo = utsname()
        unsafe uname(&systemInfo)
        let size = Int(_SYS_NAMELEN)

        return unsafe withUnsafeMutablePointer(to: &systemInfo.machine) { pointer in
            unsafe pointer.withMemoryRebound(to: CChar.self, capacity: size) { secondPointer in
                return unsafe String(cString: secondPointer)
            }
        }
    }

    var isPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }
}
