import XCTest
@testable import CLI

class CLITests: XCTestCase {
}

#if os(Linux)
extension CLITests {
    static var allTests: [(String, (XCTestCase) -> () -> Void)] = [
    ]
}
#endif
