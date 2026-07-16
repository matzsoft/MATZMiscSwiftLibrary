//         FILE: SessionHTMLClient.swift
//  DESCRIPTION: Leaderboard - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/9/26 1:48 PM

import Foundation

enum SessionHTMLError: Error {
    case invalidBaseURL
    case invalidCookie
    case badStatusCode( Int )
    case responseNotUTF8
}

/// An actor that creates a client that can be used to access webpages from a domain that
/// requires a sessionID cookie.
public actor SessionHTMLClient {
    private let baseURL: URL
    private let session: URLSession
    private let cookieStorage: HTTPCookieStorage
    
    /// Initialize a client with the information it needs.
    /// - Parameters:
    ///   - baseURL: The URL of the domain that the client can access.
    ///   - sessionID: The value of the required sessionID cookie.
    /// - Throws:
    ///   - SessionHTMLError.invalidBaseURL
    ///   - SessionHTMLError.invalidCookie
    public init( baseURL: URL, sessionID: String ) throws {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.ephemeral
        let storage = HTTPCookieStorage()
        config.httpCookieStorage = storage
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always

        self.cookieStorage = storage
        self.session = URLSession( configuration: config )

        try Self.seedSessionCookie( baseURL: baseURL, cookieStorage: storage, sessionID: sessionID )
    }

    private static func seedSessionCookie( baseURL: URL, cookieStorage: HTTPCookieStorage, sessionID: String ) throws {
        guard let host = baseURL.host else { throw SessionHTMLError.invalidBaseURL }

        let properties: [HTTPCookiePropertyKey: Any] = [
            .domain: host,
            .path: "/",
            .name: "sessionid",
            .value: sessionID,
            .secure: "TRUE"
        ]

        guard let cookie = HTTPCookie( properties: properties ) else { throw SessionHTMLError.invalidCookie }

        cookieStorage.setCookie( cookie )
    }
    
    /// Fetches the HTML from a page of the baseURL.
    /// - Parameter path: The path component(s) to add to the baseURL.
    /// - Throws:
    ///   - URLError
    ///   - SessionHTMLError.badStatusCode
    ///   - SessionHTMLError.responseNotUTF8
    /// - Returns: A string containing the HTML from the selected page.
    public func fetchPageHTML( _ path: String ) async throws -> String {
        let url = baseURL.appendingPathComponent( path )
        var request = URLRequest( url: url )
        request.httpMethod = "GET"
        request.httpShouldHandleCookies = true
        request.setValue( "text/html,application/xhtml+xml", forHTTPHeaderField: "Accept" )

        let ( data, response ) = try await session.data( for: request )

        guard let http = response as? HTTPURLResponse else {
            throw URLError( .badServerResponse )
        }

        guard ( 200 ... 299 ).contains( http.statusCode ) else {
            throw SessionHTMLError.badStatusCode( http.statusCode )
        }

        guard let html = String( data: data, encoding: .utf8 ) else {
            throw SessionHTMLError.responseNotUTF8
        }

        return html
    }
}
