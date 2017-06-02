/*

File:           ArgumentParser.swift
Author:         Jacob Williams
Date:           05/30/2017
License:        MIT
Description:    The parser struct that reads the cli for data

*/

/// Parses the CLI for Arguments
public struct ArgumentParser {
    var usage: String
    var arguments: [Argument] = []

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

    public init(_ usage: String) {
        self.usage = usage
    }

    public static var needsHelp: Bool = {
        var h: Bool = false
        do {
            if let help = ArgumentParser.parse(longName: "help", isBool: true) {
                h = try Bool.from(string: help)
            } else if let help = ArgumentParser.parse(shortName: "h", isBool: true) {
                h = try Bool.from(string: help)
            }
        } catch {
            print("An error occured determing if the help/usage text needed to be displayed.\n\t\(error)")
        }
        return h
    }()

    public static var wantsVersion: Bool = {
        var v: Bool = false
        do {
            if let version = ArgumentParser.parse(longName: "version", isBool: true) {
                v = try Bool.from(string: version)
            } else if let version = ArgumentParser.parse(shortName: "v", isBool: true) {
                v = try Bool.from(string: version)
            }
        } catch {
            print("An error occured determing if the version needed to be displayed.\n\t\(error)")
        }
        return v
    }()

    /// Parse all the arguments and set their values
    public func parse() throws {
        for var arg in arguments {
            try arg.parse()
        }
    }

    /// Parse for a specific Argument and returns it's string value if it finds one
    public static func parse<A: ArgumentValue>(_ argument: A) -> String? {
        let isBool = argument.type is Bool.Type
        if argument.mainName.length > 1 {
            if let value = ArgumentParser.parse(longName: argument.mainName, isBool: isBool) {
        		// If the value is a bool or the argument has no default value,
		        //   then just return what we got
                guard isBool, let d = argument.`default` else { return value }

                // Otherwise return the opposite boolean of the default value
                return String(!(d as! Bool))
            }
        } else {
            if let value = ArgumentParser.parse(shortName: argument.mainName, isBool: isBool) {
                // If the value is a bool or the argument has no default value,
                //   then just return what we got
                guard isBool, let d = argument.`default` else { return value }

                // Otherwise return the opposite boolean of the default value
                return String(!(d as! Bool))
            }
        }
        // If the argument has a long name, let's look for that first
        if let alternates = argument.alternateNames {
            for alt in alternates {
                if alt.length > 1 {
                    if let value = ArgumentParser.parse(longName: alt, isBool: isBool) {
                        // If the value is a bool or the argument has no default value,
                        //   then just return what we got
                        guard isBool, let d = argument.`default` else { return value }

                        // Otherwise return the opposite boolean of the default value
                        return String(!(d as! Bool))
                    }
                } else {
                    if let value = ArgumentParser.parse(shortName: alt, isBool: isBool) {
                        // If the value is a bool or the argument has no default value,
                        //   then just return what we got
                        guard isBool, let d = argument.`default` else { return value }

                        // Otherwise return the opposite boolean of the default value
                        return String(!(d as! Bool))
                    }
                }
            }
        }

        // If we didn't find the cli argument, return nil
        return nil
    }

    /// Parse for a specific longName argument
    static func parse(longName: String, isBool: Bool = false) -> String? {
        // Drop the first argument since it's just the path to the executable
        let args = CommandLine.arguments.dropFirst()
        // Try and find the index of the long argument
        if let index = args.index(of: "--\(longName)"), index >= 0 {
            // If the argument we're looking for is a Bool, go ahead and return true
            guard !isBool else { return String(true) }
            // So try and get the string value of the next argument, then return it
            if let index = args.index(of: "--\(longName)"), args.count <= index + 1 {
                let next = args[index + 1]
                return next
            }
            // Otherwise, return nil
            return nil
        }
        return nil
    }

    /// Parse for a specific shortName argument
    static func parse(shortName: Character, isBool: Bool = false) -> String? {
        // Drop the first argument since it's just the path to the executable
        let args = CommandLine.arguments.dropFirst()
        // Go over all the flag arguments
        for arg in args.filter({ $0.starts(with: "-") && !$0.starts(with: "--") }) {
            // Get rid of the hyphen and return the remaining characters
            let argChars = arg.dropFirst().characters
            // Look for the argument in the array, else return nil
            guard let _ = argChars.index(of: shortName) else { continue }
            // Make sure it's not a bool, or else just return true
            guard !isBool else { return String(true) }
            // Get the index from the array of all args
            let index = args.index(of: arg)!
            // Try and return the next argument's string value
            return args[index + 1]
        }
        // Returns nil only when there were no arguments
        return nil
    }

    /// Parse for a specific shortName argument
    private static func parse(shortName: String, isBool: Bool = false) -> String? {
        guard shortName.length > 0 else { return nil }
        return ArgumentParser.parse(shortName: shortName.characters.first!, isBool: isBool)
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
