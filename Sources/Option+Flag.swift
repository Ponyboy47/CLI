/*

File:           Option+Flag.swift
Author:         Jacob Williams
Date:           05/30/2017
License:        MIT
Descriptiont:   The base structs for all arguments

*/

import Foundation
import Strings

/// CLI Arguments that come with a value
public class Option<A: ArgumentType>: ArgumentValue {
    typealias ArgType = A
    public var mainName: String
    public var alternateNames: [String]?
    public var `default`: A?
    public var description: String?
    public var `required`: Bool
    public var type: A.Type {
        return A.self
    }
    public var value: A?
    public var usageDescriptionActualLength: Int = 0
    public var usageDescriptionNiceLength: Int = 0

    public required init(_ mainName: String, alternateNames: [String]? = nil, `default`: A? = nil, description: String? = nil, `required`: Bool = false, parser: inout ArgumentParser) throws {
        let reserved = ["h", "help", "v", "version"]
        let mainName = mainName.lowercased().lstrip("-")
        let alternateNames = alternateNames?.map { $0.lowercased().lstrip("-") }
        let allNames = parser.allNames

        guard mainName.validate(ArgumentNameValidator.self) else {
            throw ArgumentError.invalidName("Cannot use '\(mainName)' as a name since it contains invalid characters.")
        }
        guard !reserved.contains(mainName) else {
            throw ArgumentError.invalidName("Cannot use '\(mainName)' as a name since it is reserved for some base functionality.")
        }
        guard !allNames.contains(mainName) else {
            throw ArgumentError.invalidName("Cannot use '\(mainName)' as a name since it is already used by a different argument")
        }
        if let alternates = alternateNames {
            for alt in alternates {
                guard alt.validate(ArgumentNameValidator.self) else {
                    throw ArgumentError.invalidName("Cannot use '\(alt)' as a name since it contains invalid characters.")
                }
                guard !reserved.contains(alt) else {
                    throw ArgumentError.invalidName("Cannot use '\(alt)' as a name since it is reserved for some base functionality.")
                }
                guard !allNames.contains(alt) else {
                    throw ArgumentError.invalidName("Cannot use '\(alt)' as a name since it is already used by a different argument")
                }
            }
        }

        self.mainName = mainName
        self.alternateNames = alternateNames
        self.`default` = `default`
        self.description = description
        self.`required` = `required`

        parser.arguments.append(self)
    }

    public func usage() -> String {
        var u = "\t-"
        if mainName.length > 1 {
            u += "-"
        }
        u += mainName

        if let alternates = alternateNames {
            for alt in alternates {
                u += ", -"
                if alt.length > 1 {
                    u += "-"
                }
                u += alt
            }
        }
        usageDescriptionActualLength = u.length

        while u.length < usageDescriptionNiceLength {
            u += " "
        }

        if let d = description {
            u += ": \(d)"
        }
        if let d = `default` {
            u += "\n\t"
            for _ in 0...usageDescriptionNiceLength {
                u += " "
            }
            u += "DEFAULT: \(d)"
        }
        return u
    }

    public func parse(_ cli: inout [String]) throws {
        // Try and get the string value of the argument from the cli
        if let stringValue = ArgumentParser.parse(&cli, for: self) {
            // Try and convert that string value to the proper type
            self.value = try A.from(string: stringValue)
        }

        if self.value == nil {
            // No string value specified in the cli, so try and return the default value
            if let v = `default` {
                self.value = v
            // If the value is required and has no default value, throw an error
            } else if `required` {
                throw ArgumentError.requiredArgumentNotSet(mainName)
            }
        }
    }
}

/// CLI arguments that are true/false depending on whether or not they're present
public typealias Flag = Option<Bool>
