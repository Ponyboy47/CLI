/*

File:           ArgumentErrors.swift
Author:         Jacob Williams
Date:           05/30/2017
License:        MIT
Description:    The errors that can be thrown by this library

*/

/// Errors that occur in the CLI
public enum ArgumentError: Error {
    case conversionError(String)
    case emptyString
    case requiredArgumentNotSet(String)
    case invalidName(String)
}
