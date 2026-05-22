//         FILE: Safari.swift
//  DESCRIPTION: MATZMisc - Support for driving Safari
//        NOTES: Functions to facilitate automating Safari using AppleScript
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 6:06 PM

import Foundation

/// Exececute some JavaScript in the top document of Safari
/// - Parameter javascript: The JavaScript code to execute
/// - Throws: Any exception thrown by doAppleScript
/// - Returns: An NSDictionary describing the result
public func doJavaScript( javascript: String ) throws -> NSDictionary? {
    let scriptText =
        "tell application \"Safari\" to do JavaScript \"\(javascript)\" in document 1"
    return try doAppleScript( script: scriptText )
}


/// Exececute some JavaScript in the top document of Safari and capture the output
/// - Parameter javascript: The JavaScript code to execute
/// - Throws: Any exception thrown by getAppleScriptOutput
/// - Returns: An NSAppleEventDescriptor and NSDictionary describing the result
public func getJavaScriptOutput( javascript: String ) throws -> ( NSAppleEventDescriptor, NSDictionary? ) {
    let scriptText =
        "tell application \"Safari\" to do JavaScript \"\(javascript)\" in document 1"
    return try getAppleScriptOutput( script: scriptText )
}


/// Returns the window index and tab index of the first Safari tab that is displaying
///  a URL that starts with the given URL prefix
/// - Parameter urlPrefix: The prefix of the URL that should be searched for
/// - Throws: One of the following:
///   - cantGetWindowCount
///   - cantGetTabCount
///   - cantGetTabURL
/// - Returns: A tuple of the window index and tab index or nil if not found
public func getWindowAndTab( urlPrefix: String ) throws -> ( Int, Int )? {
    let script1 = "tell application \"Safari\" to get index of every window"
    let ( descriptor1, error ) = try getAppleScriptOutput( script: script1 )
    if let error = error {
        throw AppleScriptError.cantGetWindowCount( error.description )
    }
    for windowIndex in 1 ... descriptor1.numberOfItems {
        let script2 =
            "tell application \"Safari\" to get index of every tab of window \(windowIndex)"
        let ( descriptor2, error ) = try getAppleScriptOutput( script: script2 )
        if let error = error {
            throw AppleScriptError.cantGetTabCount( error.description )
        }
        
        for tabIndex in 1 ... descriptor2.numberOfItems {
            let script3 =
            "tell application \"Safari\" to get url of tab \(tabIndex) of window \(windowIndex)"
            let ( descriptor3, error ) = try getAppleScriptOutput( script: script3 )
            if let error = error {
                throw AppleScriptError.cantGetTabURL( error.description )
            }
            
            if ( descriptor3.stringValue ?? "" ).hasPrefix( urlPrefix ) {
                return ( windowIndex, tabIndex )
            }
        }
    }
    return nil
}


/// Makes the window and tab of the first Safari tab that is displaying
///  a URL that starts with the given URL prefix active
/// - Parameter urlPrefix: The prefix of the URL that should be searched for
/// - Throws: One of the following:
///   - noMatchingWindow
///   - cantBringWindowToFront
///   - cantSetCurrentTab
///   - any exception thrown by getWindowAndTab
///   - Any exception thrown by doAppleScript
/// - Returns: <#description#>
public func findTab( urlPrefix: String ) throws -> Void {
    guard let ( windowIndex, tabIndex ) = try getWindowAndTab( urlPrefix: urlPrefix ) else {
        throw AppleScriptError.noMatchingWindow
    }

    if windowIndex != 1  {
        let script = "tell application \"Safari\" to set index of window \(windowIndex) to 1"
        if let error = try doAppleScript( script: script ) {
            throw AppleScriptError.cantBringWindowToFront( error.description )
        }
    }

    let tabScript = """
        tell application \"Safari\"
            tell window 1
                set current tab to tab \(tabIndex)
            end tell
        end tell
        """
    if let error = try doAppleScript( script: tabScript ) {
        throw AppleScriptError.cantSetCurrentTab( error.description )
    }
}


public enum SafariContentType: String { case html = "source", text }


/// Get the contents of Safari's active window and tab.
/// - Parameters:
///   - type: The type of content to get, either .text or .html.
///   - interval: The number of seconds to sleep between retries.
///   - retries: The maximum number of retries if the result is empty.
/// - Throws: One of the following:
///   - cantGetDocumentHTML
///   - any exception thrown by getAppleScriptOutput
/// - Returns: The content from the tab split into an Array of lines
func getPageContent(
    _ type: SafariContentType, interval: UInt32 = 2, retries: Int = 5
) throws -> [String] {
    let scriptText =
        "tell application \"Safari\" to return \(type.rawValue) of current tab of window 1"
    
    for _ in 0 ... retries {
        let ( textDescriptor, textError ) = try getAppleScriptOutput( script: scriptText )
        if let error = textError {
            throw AppleScriptError.cantGetDocumentHTML( error.description )
        }
        guard let theText = textDescriptor.stringValue else {
            throw AppleScriptError.cantGetDocumentHTML( "returned value is not a string" )
        }
        
        if !theText.isEmpty {
            return theText.split( separator: "\n" ).map { String( $0 ) }
        }
        sleep( interval )
    }
    
    throw AppleScriptError.cantGetDocumentHTML( "returned value is empty" )
}
