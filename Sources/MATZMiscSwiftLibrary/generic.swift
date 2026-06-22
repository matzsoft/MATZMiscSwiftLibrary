//         FILE: generic.swift
//  DESCRIPTION: MATZMisc - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 10:42 PM

import Foundation

extension Collection {
    /// Behaves like split(where:) except the delimiting elements are retained in the output array.
    /// - Parameter isSplit: A function that returns true when an element should cause a split.
    /// - Returns: An array of SubSequence that reflects the original collection split according to
    ///  the predicate isSplit.
    func splitAt( isSplit: ( Iterator.Element ) throws -> Bool ) rethrows -> [SubSequence] {
        let delimiterIndicees = try indices.filter( { try isSplit( self[$0] ) } )
        var lastStartIndex = self.startIndex
        let result = delimiterIndicees.reduce( into: [SubSequence]() ) { result, index in
            if index > lastStartIndex {
                result.append( self[lastStartIndex..<index] )
            }
            result.append( self[index...index] )
            lastStartIndex = self.index( after: index )
        }
        
        guard lastStartIndex < endIndex else { return result }
        return result + [ self[lastStartIndex..<endIndex] ]
    }
}

extension String {
    /// Splits a string with multiple delimiters, but keeps the delimiters in the result.
    ///
    /// For example these 2 lines produce similar results.
    ///
    ///     let withoutDelimiters = string.split( whereSeparator: { delimiters.contains( $0 ) } )
    ///     let withDelimiters = string.tokenize( delimiters: delimiters )
    ///
    /// - Parameter delimiters: A string of characters, any one of which splits the input string.
    /// - Returns: An array of Substring that keeps the delimiters interspersed with the other parts.
    public func tokenize( delimiters: String ) -> [Substring] {
        return self.splitAt( isSplit: { delimiters.contains( $0 ) } )
    }
}


extension Array where Element: RandomAccessCollection, Element.Element: Any {
    public func transpose() -> [[Element.Element]] {
        guard !isEmpty else { return [] }
        guard self.allSatisfy( { $0.count == first!.count } ) else { fatalError() }
        
        return first!.indices.reversed().reduce( into: [[Element.Element]]() ) {
            new, xIndex in
            let row = indices.map { self[$0][xIndex] }
            new.append( row )
        }
    }
}


extension Int {
    public func string( unit: String ) -> String {
        "\(self) \(unit)\(self == 1 ? "" : "s" )"
    }
}
