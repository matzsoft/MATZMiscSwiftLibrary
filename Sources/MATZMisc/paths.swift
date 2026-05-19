//         FILE: paths.swift
//  DESCRIPTION: MATZMisc - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 5:07 PM

import Foundation

/// Finds the path to a named directory by searching the directory tree.
///
/// Starts the search at given path and proceeds up the directory tree until the named
///  directory is found.
///
/// - Parameters:
///   - name: The name of the desired directory.
///   - base: The path of the place to start the search.
/// - Throws: A RuntimeError if the named directory cannot be found.
/// - Returns: The full path to the desired directory.
public func findDirectory( name: String, base: String? = nil ) throws -> String {
    let fileManager = FileManager.default
    let base = base ?? fileManager.currentDirectoryPath
    var directory = URL( fileURLWithPath: base ).deletingLastPathComponent().path
    
    while directory != "/" {
        var isDir : ObjCBool = false
        
        if fileManager.fileExists( atPath: "\(directory)/\(name)", isDirectory:&isDir ) {
            if isDir.boolValue {
                return "\(directory)/\(name)"
            }
        }
        
        directory = URL( fileURLWithPath: directory ).deletingLastPathComponent().path
    }
    
    throw RuntimeError( "Can't find \(name) directory!" )
}


public extension URL {
    /// Obtain the relative path from the base URL to the given URL
    /// - Parameter base: The URL that forms the base of the relative URL
    /// - Returns: The relative path or nil if it can't be determined
    func relativePath( from base: URL ) -> String? {
        // Ensure that both URLs represent files:
        guard self.isFileURL && base.isFileURL else { return nil }

        // Remove/replace "." and "..", make paths absolute:
        let destComponents = self.standardized.pathComponents
        let baseComponents = base.standardized.pathComponents

        // Find number of common path components:
        let smallest = min( destComponents.count, baseComponents.count )
        let common = ( 0 ..< smallest ).firstIndex { destComponents[$0] != baseComponents[$0] } ?? smallest

        // Build relative path:
        let prefix = Array( repeating: "..", count: baseComponents.count - common )
        return ( prefix + destComponents[common...] ).joined( separator: "/" )
    }
}


/// A friendly interface to the system glob function.
/// - Parameter pattern: A glob pattern as would be presented to the shell.
///  Fot example "*.txt" or "abc?.log".
/// - Returns: An array of pathnames matching the pattern parameter.
public func glob( pattern: String ) -> [String] {
    let globFlags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
    var globObj = glob_t()
    
    defer { globfree( &globObj ) }

    if let cPattern = pattern.cString( using: String.Encoding.utf8 ) {
        if glob( cPattern, globFlags, nil, &globObj ) == 0 {
            return ( 0 ..< Int( globObj.gl_matchc ) ).compactMap {
                return globObj.gl_pathv[$0] == nil ? nil : String( cString: globObj.gl_pathv[$0]! )
            }
        }
    }
    return []
}
