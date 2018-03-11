/*

File:           ArgumentParser.swift
Author:         Jacob Williams
Date:           05/30/2017
License:        MIT
Description:    The parser class that reads the cli for data

*/

/// Parses the CLI for Arguments
public final class ArgumentParser {
    var usage: String
    var arguments: [Argument] = []
    var cliArguments: [String]
    var helpArgument: Flag! = try? Flag("h", "help", description: "Display usage information")
    var versionArgument: Flag! = try? Flag("v", "version", description: "Displays the current version")
    private var hasParsed = false

    public static var `default`: ArgumentParser = {
        return ArgumentParser()
    }()

    public lazy var shortNames: Set<String> = {
        return self.allNames.filter { $0.count == 1 }
    }()
    public lazy var longNames: Set<String> = {
        return self.allNames.filter { $0.count > 1 }
    }()
    public lazy var allNames: Set<String> = {
        return Set(self.arguments.reduce([]) { value, arg in
            return value + arg.names
        })
    }()

    public convenience init() {
        var arguments = CommandLine.arguments
        self.init("\(arguments.remove(at: 0)) [Options]", cliArguments: arguments)
    }

    public init(_ usage: String, cliArguments: [String]) {
        self.usage = usage
        self.cliArguments = cliArguments

        do {
            try self.addArgument(self.helpArgument)
            try self.addArgument(self.versionArgument)
        } catch {
            print("An unexpected error occurred:")
            print(error)
        }
    }

    public var needsHelp: Bool {
        if !hasParsed {
            do {
                try parseAll()
            } catch {
                print(error)
                return false
            }
        }
        return self.helpArgument.value ?? false
    }

    public var wantsVersion: Bool {
        if !hasParsed {
            do {
                try parseAll()
            } catch {
                print(error)
                return false
            }
        }
        return self.versionArgument.value ?? false
    }

    public func addArgument(_ argument: Argument) throws {
        let inUse = self.allNames.intersection(argument.names)
        guard inUse.isEmpty else {
            throw ArgumentError.invalidName("Cannot use '\(Array(inUse))' as names since they are already used by a different argument")
        }
        self.arguments.append(argument)
    }

    /// Parse all the arguments and set their values
    @available(*, unavailable, renamed: "parseAll()")
    public func parse() throws {
        fatalError("parse() has been renamed to parseAll()")
    }

    /// Parse all the arguments and set their values
    public func parseAll() throws {
        var unknown: [String] = []
        while !cliArguments.isEmpty {
            if let notFound = try parseNext() {
                unknown.append(notFound)
            }
        }

        if !unknown.isEmpty {
            print("\(unknown.count) unknown arguments:")
            print("\(unknown)")
        }
        hasParsed = true
    }

    private func parseNext() throws -> String? {
        var next: String! = cliArguments.remove(at: 0)

        guard next.hasPrefix("-") else {
            throw ArgumentError.invalidArgument(next)
        }

        if next.hasPrefix("--") {
            next = String(next.dropFirst(2))

            if var argument = arguments.first(where: { arg in
                return arg.names.contains(next)
            }) {
                try argument.parse(&cliArguments)
            } else { return "--\(next!)" }
        } else {
            next = String(next.dropFirst())

            var unknown = ""
            for char in next {
                if var argument = arguments.first(where: { arg in
                    return arg.names.contains("\(char)")
                }) {
                    try argument.parse(&cliArguments)
                } else { unknown += String(char) }
            }
            guard unknown.isEmpty else { return "-\(unknown)" }
        }

        return nil
    }

    @available(*, unavailable)
    private static func parse(_ cli: inout [String], for shortName: Character, isBool: Bool = false) -> String? {
        fatalError("ArgumentParser.parse() has been removed")
    }

    @available(*, unavailable)
    private static func parse(_ cli: inout [String], for argumentNames: [String], isBool: Bool = false) -> String? {
        fatalError("ArgumentParser.parse() has been removed")
    }

    /// Prints the usage text for all of the arguments included in the parser
    public func printHelp() {
        print("Usage: \(usage)\n\nOptions:")
        // Get the length of the longest usage description so that we can
        // format everything nicely
        var longest = 0
        for arg in arguments {
            longest = arg.usageDescriptionActualLength > longest ? arg.usageDescriptionActualLength : longest
        }

        // Now do the actual printing of arguments' usage descriptions
        for var arg in arguments {
            print(arg.usage())
        }
    }
}
