/*

Author:     Jacob Williams
Date:       05/30/2017
License:    MIT

*/

/// Errors that occur in the CLI
enum ArgumentError: Error {
    case conversionError(String)
    case emptyString
    case requiredArgumentNotSet(String)
    case invalidName(String)
}
