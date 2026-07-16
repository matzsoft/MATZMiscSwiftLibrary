//         FILE: OnePassword.swift
//  DESCRIPTION: Leaderboard - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/14/26 8:47 PM

import Foundation

public func getSessionID( entityID: String ) throws -> String {
    struct OPItem: Decodable {
        let fields: [OPField]
    }

    struct OPField: Decodable {
        let id: String
        let value: String? // Value can be optional (e.g., notesPlain lacks a value property)
        let label: String?
    }

    let json = try shell( "/usr/local/bin/op", "item", "get", entityID, "--format", "json" )
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
