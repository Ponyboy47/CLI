# CLI

A swift framework for parsing command line arguments into values
---

## Installation (SPM)
Include the following in your Package.swift file
```swift
.package(url: "https://github.com/Ponyboy47/CLI.git", .upToNextMajor(from: "1.0.0"))
```
For swift 3 use version 1.x

---

## Usage
```swift
import CLI

// The CLI module can't get the CommandLine arguments itself (well it can call `CommandLine.arguments` but it will be empty for some reason)
var arguments = CommandLine.arguments

// Remove the first item in the array since it's just the path to the executable
var argParser = ArgumentParser("\(arguments.remove(at: 0)) [Options]", cliArguments: arguments)

let arg1 = Option<Int>("i", alternateNames: ["int", "integer"], description: "An integer argument", parser: &argParser)
let arg2 = Flag("b", alternateNames: ["bool", "boolean"], description: "A boolean argument", parser: &argParser)
let arg3 = Option<String>("n", alternateNames: ["name"], required: true, description: "A string argument that must have a value", parser: &argParser)
let arg4 = Option<Double>("d", default: 12.34, description: "A double argument with a default value", parser: &argParser)

// Sets the values of the arguments, will throw an error if required arguments are not set
try argParser.parse()

// Get argument values like this
if let i = arg1.value {
    print("Got an integer value from the cli: \(i)")
}

if let b = arg2.value {
    print("Got a boolean value from the cli: \(b)")
}

// This should be set or else something is wrong with my framework's logic
guard let s = arg3.value else { exit(EXIT_FAILURE) }
print("Got a string value from the cli: \(s)")

if let d = arg4.value {
    print("Got a double value from the cli: \(d)")
}

// You can make your own types available to be processed from the command line if you conform to the ArgumentType protocol
struct MyStruct: ArgumentType {
    var value: Int
    public static func from(string value: String) throws -> MyStruct {
        guard let i = Int(value) else {
            throw ArgumentError.conversionError("Could not cast string to int")
        }
        return MyStruct(value: i)
    }
}

// Now you can create an Option with the MyStruct type
let arg5 = Option<MyStruct>("m", description: "My own struct!", parser: &argParser)

// There are also a couple built in functions to the ArgumentParser class

// Checks for '-h' or '--help'
if argParser.needsHelp {
    // Prints all of the arguments descriptions and names
    argParser.printHelp()
    exit(EXIT_SUCCESS)
}

// Checks for '-v' or '--version'
if argParser.wantsVersion {
    print("Version 1.0.5")
    exit(EXIT_SUCCESS)
}
```
