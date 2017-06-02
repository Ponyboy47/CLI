/*

Author:     Jacob Williams
Date:       05/30/2017
License:    MIT

*/

/// Allows Bools to be used as cli arguments
extension Bool: ArgumentType {
    public static func from(string value: String) throws -> Bool {
        guard value.characters.count > 0 else {
            throw ArgumentError.emptyString
        }
        if value == "1" {
            return true
        } else if value == "0" {
            return false
        } else if let b = Bool(value) {
            return b
        }

        throw ArgumentError.conversionError("Cannot convert '\(value)' to '\(Bool.self)'")
    }
}

/// Allows Ints to be used as cli arguments
extension Int: ArgumentType {
    public static func from(string value: String) throws -> Int {
        guard value.characters.count > 0 else {
            throw ArgumentError.emptyString
        }
        guard let val = Int(value) else {
            throw ArgumentError.conversionError("Cannot convert '\(value)' to '\(Int.self)'")
        }

        return val
    }
}

/// Allows Doubles to be used as cli arguments
extension Double: ArgumentType {
    public static func from(string value: String) throws -> Double {
        guard value.characters.count > 0 else {
            throw ArgumentError.emptyString
        }
        guard let val = Double(value) else {
            throw ArgumentError.conversionError("Cannot convert '\(value)' to '\(Double.self)'")
        }

        return val
    }
}

/// Allows Strings to be used as cli arguments
extension String: ArgumentType {
    public static func from(string value: String) throws -> String {
        guard value.characters.count > 0 else {
            throw ArgumentError.emptyString
        }
        return value
    }
}
