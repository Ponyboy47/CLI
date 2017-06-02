/*

File:           ArgumentParser.swift
Author:         Jacob Williams
Date:           05/30/2017
License:        MIT
Description:    The parser class that reads the cli for data

*/

/// Parses the CLI for Arguments
public class ArgumentParser {
    var usage: String
    var arguments: [Argument] = []
    var cliArguments: [String]

    public lazy var shortNames: [String] = {
        return self.allNames.filter { $0.characters.count == 1 }
    }()
    public lazy var longNames: [String] = {
        return self.allNames.filter { $0.characters.count > 1 }
    }()
    public lazy var allNames: [String] = {
        var aNames: [String] = []
        for arg in self.arguments {
            aNames.append(arg.mainName)
            if let alts = arg.alternateNames {
                aNames += alts
            }
        }
        return aNames
    }()

    public init(_ usage: String, cliArguments: [String]) {
        self.usage = usage
        self.cliArguments = cliArguments
    }

    public var needsHelp: Bool {
        var h: Bool = false
        do {
            if let help = ArgumentParser.parse(&cliArguments, for: "help", isBool: true) {
                h = try Bool.from(string: help)
            } else if let help = ArgumentParser.parse(&cliArguments, for: "h", isBool: true) {
                h = try Bool.from(string: help)
            }
        } catch {
            print("An error occured determing if the help/usage text needed to be displayed.\n\t\(error)")
        }
        return h
    }

    public var wantsVersion: Bool {
        var v: Bool = false
        do {
            if let version = ArgumentParser.parse(&cliArguments, for: "version", isBool: true) {
                v = try Bool.from(string: version)
            } else if let version = ArgumentParser.parse(&cliArguments, for: "v", isBool: true) {
                v = try Bool.from(string: version)
            }
        } catch {
            print("An error occured determing if the version needed to be displayed.\n\t\(error)")
        }
        return v
    }

    /// Parse all the arguments and set their values
    public func parse() throws {
        for var arg in arguments {
            try arg.parse(&cliArguments)
        }
    }

    /// Parse for a specific Argument and returns it's string value if it finds one
    static func parse<A: ArgumentValue>(_ cli: inout [String], for argument: A) -> String? {
        let isBool = argument.type is Bool.Type
        var names: [String] = [argument.mainName]
        if let alternates = argument.alternateNames {
            names += alternates
        }
        if let value = ArgumentParser.parse(&cli, for: names, isBool: isBool) {
            // If the value is a bool or the argument has no default value,
            //   then just return what we got
            guard isBool, let d = argument.`default` else { return value }

            // Otherwise return the opposite boolean of the default value
            return String(!(d as! Bool))
        }

        // If we didn't find the cli argument, return nil
        return nil
    }

    /// Parse for a specific longName argument
    private static func parse(_ cli: inout [String], for longName: String, isBool: Bool = false) -> String? {
        // Try and find the index of the long argument
        if let index = cli.index(of: "--\(longName)"), index >= 0 {
            // If the argument we're looking for is a Bool, go ahead and return true
            guard !isBool else { return String(true) }
            // So try and get the string value of the next argument, then return it
            if let index = cli.index(of: "--\(longName)"), cli.count <= index + 1 {
                let next = cli[index + 1]
                return next
            }
            // Otherwise, return nil
            return nil
        }
        return nil
    }

    /// Parse for a specific shortName argument
    private static func parse(_ cli: inout [String], for shortName: Character, isBool: Bool) -> String? {
        // Go over all the single character arguments (preceded by a single hyphen)
        for arg in cli.filter({ $0.starts(with: "-") && !$0.starts(with: "--") }) {
            // Get rid of the hyphen and return the remaining characters
            var argChars = arg.dropFirst().characters
            // Look for the argument in the array, else return nil
            guard let _ = argChars.index(of: shortName) else { continue }
            // Make sure it's not a bool, or else just return true
            guard !isBool else { return String(true) }
            // Get the index from the array of all args or return nil (this shouldn't ever happen)
            guard let index = cli.index(of: arg) else { return nil }
            // Verify the next index is within the array of cli arguments
            guard cli.count >= index + 1 else { return nil }
            // Now that we've gotten an argument, remove it from the array of cli arguments
            cli.remove(at: index)
            // If it was a single character argument but there were multiple
            // args together (ie: -abc), we need to put the other args back
            // into the array
            if argChars.count > 1 {
                cli.insert(arg.replacingOccurrences(of: String(shortName), with: ""), at: index)
            }

            // Remove and return the argument's value as well
            return cli.remove(at: index)
        }
        // Returns nil only when there were no arguments
        return nil
    }

    private static func parse(_ cli: inout [String], for argumentNames: [String], isBool: Bool = false) -> String? {
        var value: String?
        for argumentName in argumentNames {
            if argumentName.length == 1 {
                value = ArgumentParser.parse(&cli, for: argumentName.characters.first!, isBool: isBool)
            } else {
                value = ArgumentParser.parse(&cli, for: argumentName, isBool: isBool)
            }
            if value != nil {
                return value
            }
        }
        return nil
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
