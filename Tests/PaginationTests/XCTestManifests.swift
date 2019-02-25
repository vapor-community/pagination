import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PaginationTests.allTests),
        testCase(PaginationRouteTests.allTests)
    ]
}
#endif
