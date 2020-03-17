# xcode-rpc
This is a small program to provide Discord with rich presence info for Xcode. The provided info includes the current file(type) and the current workspace.

# Building
To build this repository, you must clone both it and [SwordRPC](https://github.com/Azoy/SwordRPC) into the same directory. You must also modify the `socket` property of the `SwordRPC` class to be public.

# Usage
The best way to use this, in my opinion, is to run it in a terminal emulator with `nohup`, i.e. `nohup xcode-rpc &`. This way, the process will run in the background and automatically handle Xcode launching/quitting/switching files and Discord launching/closing.

# Notes
* This program currently only supports macOS >= 10.12 because of its dependence on `Timer.scheduledTimer(withTimeInterval:repeats:block:)`. Support for macOS < 10.12 will be added in the future.
* Linux support and Windows support are both impossible and pointless. Impossible because the program calls AppleScript, and pointless because Xcode runs on neither platform.
