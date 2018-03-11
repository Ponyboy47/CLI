/*

File:           ArgumentProtocols.swift
Author:         Jacob Williams
Date:           05/29/2017
License:        MIT
Description:    Protocols/Types needed for arguments

*/

import Foundation
import Strings

/// Protocol for types to be usable in Arguments on the command line. Types
///   must be able to be retrieved from a string, since that is what the CLI sends
public protocol ArgumentType {
    static func from(string value: String) throws -> Self
}

public struct ArgArray<Element: ArgumentType>: ArgumentType {
    public let values: [Element]
    init(_ array: [Element]) {
        self.values = array
    }
    public static func from(string value: String) throws -> ArgArray<Element> {
        return ArgArray<Element>(try value.components(separatedBy: ",").map({ try Element.from(string: $0.strip()) }))
    }
}

public protocol Argument {
    /// The identifiers for the cli argument
    var names: Set<String> { get }
    /// The description of the cli argument
    var description: String? { get }
    var usageDescriptionActualLength: Int { get }
    var usageDescriptionNiceLength: Int { get }
    /// The usage string for cli argument
    mutating func usage() -> String
    /// Parses the cli arguments to get the string value of the argument, or nil if it is not set
    mutating func parse(_ cli: inout [String]) throws
}


/// Protocol for CLI argument types
public protocol ArgumentValue: Argument {
    associatedtype ArgType: ArgumentType
    /// Whether or not the argument is required to be set
    var `required`: Bool { get }
    /// The type of the argument value
    var type: ArgType.Type { get }
    /// The default value of the argument 
    var `default`: ArgType? { get }
    /// The value of the argument after parsing the command line input
    var value: ArgType? { get }

    /**
     Initializer

     - Parameter names: A list of cli arg names that trigger the argument
     - Parameter default: The default value for the cli argument
     - Parameter description: The usage description for the cli argument
     - Parameter required: Whether or not the argument is required to be set
    */
    init(_ names: [String], `default`: ArgType?, description: String?, `required`: Bool, parser: inout ArgumentParser) throws

    /**
     Initializer

     - Parameter names: A list of cli arg names that trigger the argument
     - Parameter default: The default value for the cli argument
     - Parameter description: The usage description for the cli argument
     - Parameter required: Whether or not the argument is required to be set
    */
    init(_ names: [String], `default`: ArgType?, description: String?, `required`: Bool) throws
}

struct ArgumentNameValidator: Validator {
    public static func validate(_ value: Validatable) -> Bool {
        guard let str = value as? String, str.count > 0 else { return false }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "_-")
        guard CharacterSet.lowercaseLetters.contains(str.first!.unicodeScalar) else { return false }
        for char in str {
            if !allowed.contains(char.unicodeScalar) {
                return false
            }
        }
        return true
    }
}
