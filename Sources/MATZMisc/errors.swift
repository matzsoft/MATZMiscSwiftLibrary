//         FILE: errors.swift
//  DESCRIPTION: MATZMisc - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 5:12 PM

import Foundation

/// Used for throwing generalized exceptions.
///
/// The init takes one parameter, message: any string describing the error condition.
public struct RuntimeError: Error {
    let message: String

    public init( _ message: String ) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
