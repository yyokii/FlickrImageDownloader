    import XCTest
    @testable import AppPackage

    final class AppTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(AppPackage().text, "Hello, World!")
        }
    }
