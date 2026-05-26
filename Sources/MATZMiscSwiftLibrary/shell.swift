//         FILE: shell.swift
//  DESCRIPTION: MATZMisc - Support for running other programs
//        NOTES: "Modern" version of running other programs offering a variadic
//               arguments version and arry of arguments version of each function.
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 3:37 PM

import Foundation

/// Finds the URL of the specified program in the user's PATH
/// - Parameter programName: Name of the program to find
/// - Returns: The URL of the specified program or nil if not found
public func which( programName: String ) -> URL? {
    if programName.contains( "/" ) { return URL( fileURLWithPath: programName ) }
    guard let path = ProcessInfo.processInfo.environment["PATH"] else { return nil }
    
    let paths = path.split(separator: ":").map { String( $0 ) }
    
    for path in paths {
        let programURL = URL( fileURLWithPath: path )
            .appendingPathComponent( programName, isDirectory: false )
        if FileManager.default.isExecutableFile( atPath: programURL.path ) {
            return programURL
        }
    }
    
    return nil
}

/// Runs another program in a seperate process and waits for completion.
/// - Parameters:
///   - stdout: FileHandle of file to capture stdout of the program or nil to put the
///    stdout of the program to the caller's stdout.
///   - args: Variadic list of strings to pass as arguments to the program.
///    Include program to run in args[0].
/// - Throws: Any exception thrown by shell( stdout: FileHandle?, _ args: [String] ).
/// - Returns: Termination status of the program.
public func shell( stdout: FileHandle?, _ args: String... ) throws -> Int32 {
    try shell( stdout: stdout, args )
}


/// Runs another program in a seperate process and waits for completion.
/// - Parameters:
///   - stdout: FileHandle of file to capture stdout of the program or nil to put the
///    stdout of the program to the caller's stdout.
///   - args: Array of strings to pass as arguments to the program.
///    Include program to run in args[0].
/// - Throws: RuntimeError( "shell call must have arguments." )
/// - Returns: Termination status of the program.
public func shell( stdout: FileHandle?, _ args: [String] ) throws -> Int32 {
    if args.isEmpty { throw RuntimeError( "shell call must have arguments." ) }
    let programURL = which( programName: args[0] )
    let task = Process()
    
    task.executableURL = programURL
    task.arguments = args[1...].map { String( $0 ) }
    if let stdout = stdout {
        task.standardOutput = stdout
    }
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}


/// Runs another program in a seperate process and waits for completion.
/// - Parameters:
///   - args: Variadic list of strings to pass as arguments to the program.
///    Include program to run in args[0].
/// - Throws: Any exception thrown by shell( _ args: [String] ).
/// - Returns: A string containing the stdout of the program.
public func shell( _ args: String... ) throws -> String {
    try shell( args )
}


/// Runs another program in a seperate process and waits for completion.
/// - Parameters:
///   - args: Array of strings to pass as arguments to the program.
///    Include program to run in args[0].
/// - Throws: Any of the following:
///   - RuntimeError( "shell call must have arguments." )
///   - Any exception thrown by task.run().
/// - Returns: A string containing the stdout of the program.
public func shell( _ args: [String] ) throws -> String {
    if args.isEmpty { throw RuntimeError( "shell call must have arguments." ) }
    let programURL = which( programName: args[0] )
    let task = Process()
    let pipe = Pipe()

    task.executableURL = programURL
    task.arguments = args[1...].map { String( $0 ) }
    task.standardOutput = pipe

    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    return ( String( data: data, encoding: .utf8 ) ?? "" )
        .trimmingCharacters( in: .whitespacesAndNewlines )
}

