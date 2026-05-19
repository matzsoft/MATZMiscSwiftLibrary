//         FILE: math.swift
//  DESCRIPTION: MATZMisc - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 5/18/26 11:01 PM

import Foundation

/// Returns the Greatest Common Divisor of two Int values.
/// - Parameters:
///   - m: The first integer value
///   - n: The second integer value
/// - Returns: The integer greatest common divisor
public func gcd( _ m: Int, _ n: Int ) -> Int {
    var a = 0
    var b = max( m, n )
    var r = min( m, n )
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

/// Returns the Least Common Multiple of two Int values.
/// - Parameters:
///   - m: The first integer value
///   - n: The second integer value
/// - Returns: The integer least common multiple
public func lcm( _ m: Int, _ n: Int ) -> Int {
    return m / gcd (m, n ) * n
}


/// Calculates the value of an integer base raised to an integer power
/// - Parameters:
///   - base: The value to exponentiate
///   - exponent: The power of base desired
/// - Returns: The integer value of base ** exponent
public func pow( _ base: Int, _ exponent: Int ) -> Int {
    Int( pow( Double( base ), Double( exponent ) ) )
}

/// An object that contains a list of primes and methods to utilize that list
public class Primes {
    let limit: Int
    let primes: [Int]
    public var count: Int { primes.count }
    
    /// Generate the list of primes
    /// - Parameter n: The maximum prime to generate, not the number of primes
    public init( to n: Int ) {
        self.limit = n
        guard n > 1 else { self.primes = []; return }
        
        let d = Double( n )
        let squareRootN = Int( d.squareRoot() )
        var composite = Array( repeating: false, count: n + 1 ) // The sieve
        var primes = [ 2 ]

        if n < 150 {
            primes.reserveCapacity( n )
        } else {
            // Upper bound for the number of primes up to and including `n`,  from https://en.wikipedia.org/wiki/Prime_number_theorem#Non-asymptotic_bounds_on_the_prime-counting_function :
            primes.reserveCapacity( Int( d / ( log( d ) - 4 ) ) )
        }
        
        var p = 3
        for q in stride( from: 2, through: n, by: 2 ) { composite[q] = true }
        while p <= squareRootN {
            if !composite[p] {
                primes.append( p )
                for q in stride( from: p * p, through: n, by: p ) {
                    composite[q] = true
                }
            }
            p += 2
        }
        
        while p <= n {
            if !composite[p] {
                primes.append( p )
            }
            p += 2
        }
        
        self.primes = primes
    }
    
    /// Return the nth prime, index is zero based
    public subscript( _ index: Int ) -> Int {
        return primes[index]
    }
    
    /// Generate the prime factors of an integer
    /// - Parameter n: The number used to get the prime factors
    /// - Returns: An array of tuples. Each tuple is ( prime, power )
    public func primeFactors( of n: Int ) -> [ ( Int, Int ) ] {
        let squareRootN = Int( Double( n ).squareRoot() )
        var n = n
        var factors = [ ( Int, Int ) ]()
        
        for p in primes {
            var power = 0
            
            while n % p == 0 {
                n /= p
                power += 1
            }
            
            if power > 0 { factors.append( ( p, power ) ) }
            if n == 1 { break }
            if p >= squareRootN { factors.append( ( n, 1 ) ); n = 1; break }
        }
        
        if n > 1 { factors.append( ( n, 1 ) ) }
        return factors
    }
    
    /// Computes the sum of all factors of a given integer
    /// - Parameter n: The number which the sum of factors will be computed
    /// - Returns: The sum of all factors of n
    public func sumFactors( of n: Int ) -> Int {
        let factors = primeFactors( of: n )
        var sum = 1
        
        for ( p, e ) in factors {
            var factor = 1
            for _ in 1 ... e { factor = 1 + factor * p }
            sum *= factor
        }
        
        return sum
    }
    
    /// Express all the factors of an integer as a list of lists of prime factors.
    /// This is used internally to generate the list of all factors.
    /// - Parameter factors: The list of prime factors to work from.
    /// - Returns: A list of list of tuples. Each tuple is a ( prime, power )
    /// where the power may be zero.
    func factors( of factors: [ ( Int, Int ) ] ) -> [ [ ( Int, Int ) ] ] {
        if factors.count == 1 {
            return ( 0 ... factors[0].1 ).map { [ ( factors[0].0, $0 ) ] }
        }
        
        let others = self.factors( of: Array( factors.dropFirst() ) )
        var result = [ [ ( Int, Int ) ] ]()
        
        for power in 0 ... factors[0].1 {
            for other in others {
                result.append( [ ( factors[0].0, power ) ] + other )
            }
        }
        
        return result
    }
    
    /// Returns a list of all the factors of a given integer
    /// - Parameter n: The number for which all the factors will be returned
    /// - Returns: An array of all the factors of n
    public func factors( of n: Int ) -> [Int] {
        guard n > 3 else { return [ 1, n ] }
        
        let factors = factors( of: primeFactors( of: n ) )
        return factors.map { $0.map { pow( $0.0, $0.1 ) }.reduce( 1, * ) }.sorted()
    }
    
    /// Euler's totient function of an integer
    /// - Parameter n: The number used to obtain the totient
    /// - Returns: Euler's totient of n
    public func totient( of n: Int ) -> Int {
        let factors = primeFactors( of: n )
        
        return factors.reduce( 1, { $0 * pow( $1.0, $1.1 - 1 ) * ( $1.0 - 1 ) } )
    }
}
