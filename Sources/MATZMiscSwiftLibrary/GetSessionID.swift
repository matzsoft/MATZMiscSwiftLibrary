//         FILE: OnePassword.swift
//  DESCRIPTION: Leaderboard - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/14/26 8:47 PM

import Foundation

/// Obtains the sessionID value from a particular 1Password entry.
/// Requires that the 1Password CLI API is installed and the sessionID is stored in the one-time password field.
/// - Parameter entryName: The name of the entry in 1Password to access.
/// - Throws: A RuntimeError if the seessionID cannot be found.
/// - Returns: A String containing the sessionID.
public func getSessionID( entryName: String ) throws -> String {
    struct OPItem: Decodable {
        let fields: [OPField]
    }

    struct OPField: Decodable {
        let id: String
        let value: String? // Value can be optional (e.g., notesPlain lacks a value property)
        let label: String?
    }

    let json = try shell( "/usr/local/bin/op", "item", "get", entryName, "--format", "json" )
    let jsonData = json.data( using: .utf8 )!
    
    // 2. Decode the structured JSON payload automatically
    let decoder = JSONDecoder()
    let item = try decoder.decode( OPItem.self, from: jsonData )
    
    // 3. Extract the target values with simple array operations
    guard let sessionID = item.fields.first( where: { $0.label == "one-time password" } )?.value else {
        throw RuntimeError( "Failed to find or extract one-time password field in 1Password" )
    }
    
    return sessionID
}
