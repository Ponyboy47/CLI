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
public class Option<A: ArgumentType>: ArgumentValueWithDefault {
    public typealias ArgType = A
    public internal(set) var names: Set<String>
    public lazy var sortedNames: [String] = {
        return self.names.sorted(by: { return $0.count < $1.count })
    }()
    public internal(set) var _description: String?
    public internal(set) var `required`: Bool
    public var type: A.Type {
        return A.self
    }
    public internal(set) var `default`: A?
    private var _value: A?
    public var value: A? {
        get {
            return _value ?? `default`
        }
        set {
            _value = newValue
        }
    }
    public internal(set) var usageDescriptionActualLength: Int = 0
    public internal(set) var usageDescriptionNiceLength: Int = 0

    public var description: String {
        return "\(self.sortedNames) = \(String(describing: self.value))"
    }

    public convenience init(_ names: String..., description: String? = nil, `required`: Bool = false, parser: inout ArgumentParser) throws {
        try self.init(names, default: nil, description: description, required: `required`)

        try parser.addArgument(self)
    }

    public required init(_ names: [String], description: String? = nil, `required`: Bool = false, parser: inout ArgumentParser) throws {
        guard !names.isEmpty else {
            throw ArgumentError.missingName
        }

        let names = Set(names.map { $0.lowercased().lstrip("-") })

        for name in names {
            guard name.validate(ArgumentNameValidator.self) else {
                throw ArgumentError.invalidName("Cannot use '\(name)' as a name since it contains invalid characters.")
            }
        }

        self.names = names
        self.default = nil
        self._description = description
        self.`required` = `required`

        try parser.addArgument(self)
    }

    public convenience init(_ names: String..., description: String? = nil, `required`: Bool = false) throws {
        try self.init(names, default: nil, description: description, required: `required`)
    }

    public required init(_ names: [String], description: String? = nil, `required`: Bool = false) throws {
        guard !names.isEmpty else {
            throw ArgumentError.missingName
        }

        let names = Set(names.map { $0.lowercased().lstrip("-") })

        for name in names {
            guard name.validate(ArgumentNameValidator.self) else {
                throw ArgumentError.invalidName("Cannot use '\(name)' as a name since it contains invalid characters.")
            }
        }

        self.names = names
        self.default = nil
        self._description = description
        self.`required` = `required`
    }

    public convenience init(_ names: String..., `default`: A?, description: String? = nil, `required`: Bool = false, parser: inout ArgumentParser) throws {
        try self.init(names, default: `default`, description: description, required: `required`)

        try parser.addArgument(self)
    }

    public required init(_ names: [String], `default`: A?, description: String? = nil, `required`: Bool = false, parser: inout ArgumentParser) throws {
        guard !names.isEmpty else {
            throw ArgumentError.missingName
        }

        let names = Set(names.map { $0.lowercased().lstrip("-") })

        for name in names {
            guard name.validate(ArgumentNameValidator.self) else {
                throw ArgumentError.invalidName("Cannot use '\(name)' as a name since it contains invalid characters.")
            }
        }

        self.names = names
        self.default = `default`
        self._description = description
        self.`required` = `required`

        try parser.addArgument(self)
    }

    public convenience init(_ names: String..., `default`: A?, description: String? = nil, `required`: Bool = false) throws {
        try self.init(names, default: `default`, description: description, required: `required`)
    }

    public required init(_ names: [String], `default`: A?, description: String? = nil, `required`: Bool = false) throws {
        guard !names.isEmpty else {
            throw ArgumentError.missingName
        }

        let names = Set(names.map { $0.lowercased().lstrip("-") })

        for name in names {
            guard name.validate(ArgumentNameValidator.self) else {
                throw ArgumentError.invalidName("Cannot use '\(name)' as a name since it contains invalid characters.")
            }
        }

        self.names = names
        self.default = `default`
        self._description = description
        self.`required` = `required`
    }

    public func usage() -> String {
        var u = "\t-"
        if sortedNames.first!.count > 1 {
            u += "-"
        }
        u += sortedNames.first!

        for alt in sortedNames.dropFirst() {
            u += ", -"
            if alt.count > 1 {
                u += "-"
            }
            u += alt
        }
        usageDescriptionActualLength = u.count

        while u.count < usageDescriptionNiceLength {
            u += " "
        }

        if let d = _description {
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
        guard type is Bool.Type else {
            value = try A.from(string: cli.remove(at: 0))
            return
        }

        guard let d = `default` else {
            value = try A.from(string: String(true))
            return
        }

        value = try A.from(string: String(!(d as! Bool)))
    }
}

/// CLI arguments that are true/false depending on whether or not they're present
public typealias Flag = Option<Bool>
