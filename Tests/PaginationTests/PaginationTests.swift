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
    
    func testQuery() throws {
        let models = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]
        
        let pageInfo = try TestModel.query(on: self.sqlConnection).paginate(page: 1).wait()
        XCTAssertEqual(pageInfo.total, models.count)
    }
    
    func testFilterQuery() throws {
        let model = try TestModel.create(name: "Test Filter", on: self.sqlConnection)
        let pageInfo = try TestModel.query(on: self.sqlConnection).filter(\TestModel.name == "Test Filter").paginate(page: 1).wait()
        XCTAssertEqual(pageInfo.total, 1)
        XCTAssertEqual(pageInfo.data.first?.name, model.name)
    }

    static var allTests = [
        ("testQuery", testQuery),
        ("testFilterQuery", testFilterQuery),
    ]
}
