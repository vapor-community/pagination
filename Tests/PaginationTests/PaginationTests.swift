import XCTest
import Vapor
import FluentSQLite
@testable import Pagination

final class PaginationTests: XCTestCase {

    var app: Application!
    var sqlConnection: SQLiteConnection!

    override func setUp() {
        super.setUp()
        self.app = try! Application.testable()
        self.sqlConnection = try! self.app.newConnection(to: .sqlite).wait()
    }

    override func tearDown() {
        self.sqlConnection.close()
        super.tearDown()
    }

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass
            .defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    func testQuery() throws {
        let models: [TestModel] = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]

        let pageInfo = try TestModel.query(on: self.sqlConnection).sort(\.id).getPage(current: 1).wait()
        XCTAssertEqual(pageInfo.total, models.count)
        XCTAssertEqual(pageInfo.data, models)
    }

    func testFilterQuery() throws {
        let model = try TestModel.create(name: "Test Filter", on: self.sqlConnection)
        let pageInfo = try TestModel.query(on: self.sqlConnection).filter(\TestModel.name == "Test Filter").getPage(current: 1).wait()
        XCTAssertEqual(pageInfo.total, 1)
        XCTAssertEqual(pageInfo.data.first?.name, model.name)
    }
    
    func testPaginationResponse() throws {
        for i in 0..<20 {
            try TestModel.create(name: "Test \(i)", on: self.sqlConnection)
        }
        let pageInfo = try TestModel.query(on: self.sqlConnection).getPage(current: 1).wait()
        let pageResponse = Paginated(from: pageInfo)
        XCTAssertEqual(pageInfo.total, 20)
        XCTAssertEqual(pageResponse.page.position.max, 2)
    }

}

// MARK: - All Tests

extension PaginationTests {

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testQuery", testQuery),
        ("testFilterQuery", testFilterQuery),
        ("testPaginationResponse", testPaginationResponse)
    ]

}
