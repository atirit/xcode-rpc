//
//  main.swift
//  xcode-rpc
//
//  Created by Aydin Tiritoglu on 3/15/20.
//  Copyright © 2020 Aydin Tiritoglu. All rights reserved.
//

import Foundation
import SwordRPC

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}

func fetchCurrent() -> (String, String)? {
    let applescript =
    """
    on is_running(appName)
        tell application "System Events" to (name of processes) contains appName
    end is_running
    set xcodeRunning to is_running("Xcode")
    if xcodeRunning then
    run script "tell application \\"Xcode\\"
    return {path of document 1 whose name ends with (word 1 of (get name of window 1)), path of active workspace document}
    end tell"
    else
    return "e"
    end if
    """
    if let scriptObject = NSAppleScript(source: applescript) {
        var error: NSDictionary?
        let output = scriptObject.executeAndReturnError(&error)
        if output.atIndex(2) == nil {
            print(error ?? "no error")
            return nil
        }
        var file = output.atIndex(1)?.stringValue ?? ""
        var workspace = output.atIndex(2)?.stringValue ?? ""
        workspace = workspace.components(separatedBy: "/").last!
        file = file.components(separatedBy: workspace + "/").last!
        return (file, workspace)
    }
    return ("", "")
}

var current = fetchCurrent()

var currentFile: String {
    return current!.0
}

var currentWorkspace: String {
    return current!.1
}

let appId = "688643193310543966"

var rpc = SwordRPC(appId: appId)

var currentProj = ""

var date = Date().addingTimeInterval(Date().timeIntervalSince1970 * 999)

func updatePresence() {
    guard current != nil else {
        rpc.socket?.close()
        rpc.createSocket()
        date = Date().addingTimeInterval(Date().timeIntervalSince1970 * 999)
        return
    }
    guard let con = rpc.socket?.isConnected, con else {
        rpc.connect()
        return
    }
    var presence = RichPresence()
    presence.details = currentWorkspace
    presence.state = currentFile
    presence.timestamps.start = date
    presence.assets.largeImage = currentFile.components(separatedBy: ".").reversed()[0]
    presence.assets.largeText = "Editing a \(currentFile.components(separatedBy: ".").last?.firstUppercased ?? "") file"
    presence.assets.smallImage = "xcodebg"
    presence.assets.smallText = "Xcode"
    rpc.setPresence(presence)
}

rpc.onConnect { rpc in
    updatePresence()
}

rpc.onError { rpc, code, msg in
    print(msg)
    print(currentFile)
    print(currentWorkspace)
}

rpc.connect()

if #available(OSX 10.12, *) {
    Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { t in
        current = fetchCurrent()
        updatePresence()
    }
} else {
    // add later
}

CFRunLoopRun()
