//
//  TerminalLauncher.swift
//  macSCP
//
//  Utility to launch the macOS native Terminal app with an SSH command using AppleScript.
//

import Foundation
import AppKit

enum TerminalLauncherError: LocalizedError {
    case appleScriptInitializationFailed
    case executionFailed(String)
    case automationNotAuthorized
    
    var errorDescription: String? {
        switch self {
        case .appleScriptInitializationFailed:
            return "Failed to initialize AppleScript."
        case .executionFailed(let message):
            return "Terminal error: \(message)"
        case .automationNotAuthorized:
            return "Terminal automation not authorized. Please check System Settings > Privacy & Security > Automation."
        }
    }
}

enum TerminalLauncher {
    /// Launches the macOS Terminal app and executes an SSH command using AppleScript.
    @discardableResult
    static func launchTerminal(
        host: String,
        port: Int,
        username: String,
        privateKeyPath: String? = nil,
        initialPath: String? = nil
    ) -> Result<Void, Error> {
        logInfo("Launching native terminal (AppleScript) for \(username)@\(host):\(port)", category: .ui)
        
        var sshCommand = "ssh -p \(port)"
        
        if let keyPath = privateKeyPath, !keyPath.isEmpty {
            let escapedKeyPath = keyPath.replacingOccurrences(of: " ", with: "\\ ")
            sshCommand += " -i \(escapedKeyPath)"
        }
        
        sshCommand += " \(username)@\(host)"
        
        if let path = initialPath, path != "/", path != "~", !path.isEmpty {
            let escapedPath = path.replacingOccurrences(of: "\"", with: "\\\"")
            sshCommand += " -t \"cd \\\"\(escapedPath)\\\" ; exec $SHELL -l\""
        }
        
        // Prepare AppleScript source using bundle identifier for better reliability
        let scriptSource = """
        tell application id "com.apple.Terminal"
            activate
            do script "\(sshCommand.replacingOccurrences(of: "\"", with: "\\\""))"
        end tell
        """
        
        // Execute AppleScript directly
        return executeAppleScript(scriptSource)
    }
    
    private static func executeAppleScript(_ source: String) -> Result<Void, Error> {
        guard let script = NSAppleScript(source: source) else {
            return .failure(TerminalLauncherError.appleScriptInitializationFailed)
        }
        
        var error: NSDictionary?
        script.executeAndReturnError(&error)
        
        if let err = error {
            let message = err["NSAppleScriptErrorMessage"] as? String ?? "Unknown AppleScript error"
            logError("AppleScript execution failed: \(message)", category: .ui)
            
            if message.contains("not allowed") || message.contains("authorized") {
                return .failure(TerminalLauncherError.automationNotAuthorized)
            }
            
            return .failure(TerminalLauncherError.executionFailed(message))
        }
        
        return .success(())
    }
}
