//         FILE: clipboard.swift
//  DESCRIPTION: MATZMisc - Manipulation of the system clipboard
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 6:56 PM

import Foundation
import AppKit

/// Place the specified text into the system clipboard
/// - Parameter text: The text that will go into the clipboard
public func copyToClipboard( text: String ) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString( text, forType: .string )
}


/// Obtain the text from the system clipboard
/// - Returns: The text that was in the clipboard or nil if none
public func pasteFromClipboard() -> String? {
    let pasteboard = NSPasteboard.general
    if let pasteboardItems = pasteboard.pasteboardItems {
        for item in pasteboardItems {
            if let copiedString = item.string( forType: .string ) {
                return copiedString
            }
        }
    }
    return nil
}
