//         FILE: AppleScript.swift
//  DESCRIPTION: MATZMisc - Support for generic use of AppleScript
//        NOTES: Functions and error codes for generic AppleScript use
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 5:58 PM

import Foundation

/// The list of available AppleScriptError exceptions
public enum AppleScriptError: Error, CustomStringConvertible {
    case cantCreateAppleScriptObject
    case cantGetWindowCount( String )
    case cantGetTabCount( String )
    case cantGetTabURL( String )
    case cantBringWindowToFront( String )
    case cantSetCurrentTab( String )
    case cantGetHistoryCount( String )
    case cantDoHistoryBack( String )
    case cantGetDocumentHTML( String )
    case cantLinkToURL( String )
    case cantActivateSafari( String )
    case noMatchingWindow
    
    public var description: String {
        switch self {
        case .cantCreateAppleScriptObject:
            return "Could not create AppleScript object."
        case .cantGetWindowCount( let error ):
            return "Could not get window count: \(error)."
        case .cantGetTabCount( let error ):
            return "Could not get tab count for window: \(error)."
        case .cantGetTabURL( let error ):
            return "Could not get tab URL: \(error)."
        case .cantBringWindowToFront( let error ):
            return "Could not bring window to front: \(error)."
        case .cantSetCurrentTab( let error ):
            return "Could not set current tab: \(error)."
        case .cantGetHistoryCount( let error ):
            return "Could not get history count: \(error)."
        case .cantDoHistoryBack( let error ):
            return "Could not do history back: \(error)."
        case .cantGetDocumentHTML( let error ):
            return "Could not get document HTML: \(error)."
        case .cantLinkToURL( let error ):
            return "Could not link to URL: \(error)."
        case .cantActivateSafari( let error ):
            return "Could not activate Safari: \(error)."
        case .noMatchingWindow:
            return "No matching window found."
        }
    }
    
    public var localizedDescription: String {
        return description
    }
}


/// Perform an AppleScript and returns any error.
/// - Parameter script: The Text of script to run.
/// - Throws: cantCreateAppleScriptObject
/// - Returns: An NSDictionary? which contains any errors.
public func doAppleScript( script: String ) throws -> NSDictionary? {
    var error: NSDictionary?
    guard let script = NSAppleScript( source: script ) else {
        throw AppleScriptError.cantCreateAppleScriptObject
    }
    
    script.executeAndReturnError( &error )
    return error
}


/// Perform an AppleScript and returns any output and/or error.
/// - Parameter script: The Text of script to run.
/// - Throws: cantCreateAppleScriptObject
/// - Returns: A tuple of ( NSAppleEventDescriptor, NSDictionary? ) which
///  contains the output in the first element and any errors in the second.
public func getAppleScriptOutput( script: String ) throws -> ( NSAppleEventDescriptor, NSDictionary? ) {
    var error: NSDictionary?
    guard let script = NSAppleScript( source: script ) else {
        throw AppleScriptError.cantCreateAppleScriptObject
    }
    
    let descriptor = script.executeAndReturnError( &error )
    return ( descriptor, error )
}
