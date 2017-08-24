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

protocol Argument {
    /// The main identifier for the cli argument
    var mainName: String { get set }
    /// The alternate identifiers for the cli argument
    var alternateNames: [String]? { get set }
    /// The description of the cli argument
    var description: String? { get set }
    var usageDescriptionActualLength: Int { get set }
    var usageDescriptionNiceLength: Int { get set }
    /// The usage string for cli argument
    mutating func usage() -> String
    /// Parses the cli arguments to get the string value of the argument, or nil if it is not set
    mutating func parse(_ cli: inout [String]) throws
}


/// Protocol for CLI argument types
protocol ArgumentValue: Argument {
    associatedtype ArgType: ArgumentType
    /// The default value for the cli argument
    var `default`: ArgType? { get set }
    /// Whether or not the argument is required to be set
    var `required`: Bool { get set }
    /// The type of the argument value
    var type: ArgType.Type { get }
    /// The value of the argument after parsing the command line input
    var value: ArgType? { get set }

    /**
     Initializer

     - Parameter shortName: The single character identifier for the cli argument
     - Parameter longName: The long identifier for the cli argument
     - Parameter default: The default value for the cli argument
     - Parameter description: The usage description for the cli argument
     - Parameter required: Whether or not the argument is required to be set
    */
    init(_ mainName: String, alternateNames: [String]?, `default`: ArgType?, description: String?, `required`: Bool, parser: inout ArgumentParser) throws
}

struct ArgumentNameValidator: Validator {
    public static func validate(_ value: Validatable) -> Bool {
        guard let str = value as? String, str.length > 0 else { return false }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "_-")
        guard CharacterSet.lowercaseLetters.contains(str.characters.first!.unicodeScalar) else { return false }
        for char in str.characters {
            if !allowed.contains(char.unicodeScalar) {
                return false
            }
        }
        return true
    }
}
