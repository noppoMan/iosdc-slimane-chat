import XCTest
@testable import iosdc_slimane_chat

class iosdc_slimane_chatTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(iosdc_slimane_chat().text, "Hello, World!")
    }


    static var allTests : [(String, (iosdc_slimane_chatTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
