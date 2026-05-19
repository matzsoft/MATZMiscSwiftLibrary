//         FILE: prompting.swift
//  DESCRIPTION: MATZMisc - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 8:54 PM

import Foundation

/// Issue a prompt on stdout and accept a string input from stdin
/// - Parameters:
///   - prompt: The string to use as prompt. A ": " will be appended
///   - preferred: The value to be returned if nothing is entered.
///    The value in brackets will be appended to the prompt before the ": "
/// - Returns: The value entered or the value of preferred if it is non-nil
public func getString( prompt: String, preferred: String? ) -> String {
    let defaultPrompt = preferred == nil ? ": " : " [\(preferred!)]: "
    
    while true {
        print( "\(prompt)\(defaultPrompt)", terminator: "" )
        
        let answer = readLine( strippingNewline: true )
        
        if answer != nil && answer! != "" { return answer! }
        if preferred != nil { return preferred! }
    }
}

/// Issue a prompt on stdin and read a series of lines from stdin
/// - Parameters:
///   - prompt: The string to use as prompt. A "- " will be appended
///   - blanksOK: If true empty lines terminate the input.
///    If false end of file is required to terminate the input
/// - Returns: An Array of String containing the lines input from stdin
public func getLines( prompt: String, blanksOK: Bool = false ) -> [String] {
    var inputLines = [String]()
    
    print( "\(prompt) -" )
    while let line = readLine( strippingNewline: true ) {
        if line == "" && blanksOK { break }
        inputLines.append( line )
    }
    
    return inputLines
}


/// Present a yes/no question on stdout and read the response from stdin.
///  The response must be "y" or "n" in either upper or lower case.
/// - Parameters:
///   - prompt: The prompt to present.
///    A bracketed list of options followed by a "?" will be appeneded.
///    In the bracketed list the expected result will be uppercase
///     and the alternative will be lowercase
///   - expected: The value returned if an empty line is entered.
///   This should be true for an expected result of yes
///    and false for an expected result of no
/// - Returns: A value pf true for a yes response or a value of false for a no result
public func askYN( prompt: String, expected: Bool ) -> Bool {
    let defaultPrompt = expected ? " [Y/n]? " : " [y/N]? "
    
    while true {
        print( "\(prompt)\(defaultPrompt)", terminator: "" )
        
        let answer = readLine( strippingNewline: true )
        
        guard let value = answer else { return expected }
        if value.isEmpty { return expected }
        if value.first!.lowercased() == "y" { return true }
        if value.first!.lowercased() == "n" { return false }
    }
}
