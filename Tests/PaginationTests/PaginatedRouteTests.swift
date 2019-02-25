import XCTest
import Vapor
import FluentSQLite
@testable import Pagination

final class PaginationRouteTests: XCTestCase {

    // MARK: - Properties

    var app: Application!
    var sqlConnection: SQLiteConnection!

    // MARK: - Lifecycle

    func routes(_ router: Router) throws {
        // get paginated response with defualt response type
        router.get("/paginated") { req throws -> Paginated<TestModel> in
            return try TestModel.query(on: req).paginate(for: req).wait()
        }

        // get pagianted response with custom resposne type
        router.get("/paginated/custom") { req throws -> CustomPaginatedResponse in
            return try TestModel.query(on: req).paginate(for: req, response: CustomPaginatedResponse.self).wait()
        }

        // get pagianted response with transformation closure
        router.get("/advanced") { req throws -> Paginated<TestModel.Public> in
            let result = try TestModel.query(on: req).paginate(on: req) { builder in
                // transform query builder, do joins/alsoDecode etc.
                return builder.all().map(to: [TestModel.Public].self) { models in
                    return models.map { TestModel.Public(name: $0.name) }
                }
            }
            return try result.wait()
        }

        // get pagianted response with transformation closure and custom response
        router.get("/advanced/custom") { req throws -> CustomPaginatedResponse in
            let result = try TestModel.query(on: req).paginate(on: req, response: CustomPaginatedResponse.self) { builder in
                // transform query builder, do joins/alsoDecode etc. and return in custom response
                return builder.all().map(to: [TestModel].self) { models in
                    for model in models {
                        model.name = "Changed"
                    }
                    return models
                }
            }
            return try result.wait()
        }
    }

    override func setUp() {
        super.setUp()

        var services = Services.default()

        let router = EngineRouter.default()
        try! routes(router)
        services.register(router, as: Router.self)
        
        self.app = try! Application.testable(services: services)
        self.sqlConnection = try! self.app.newConnection(to: .sqlite).wait()
    }

    override func tearDown() {
        self.sqlConnection.close()
        super.tearDown()
    }

    // MARK: - Tests

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass
            .defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    func testGetDefualtPaginatedResponse() throws {
        // create models in DB
        let models: [TestModel] = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]

        // request endpoint and decode response to paginated
        let response = try app.getResponse(to: "/paginated")
        let paginated = try response.content.decode(Paginated<TestModel>.self).wait()

        // test
        XCTAssertEqual(paginated.page.data.total, models.count)
        XCTAssertEqual(paginated.data.count, models.count)
        XCTAssertEqual(paginated.page.data.per, TestModel.defaultPageSize)
    }

    func testGetCustomPaginatedResponse() throws {
        // create models in DB
        let models: [TestModel] = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]

        // request endpoint and decode response to custom response
        let response = try app.getResponse(to: "/paginated/custom")
        let paginated = try response.content.decode(CustomPaginatedResponse.self).wait()

        // test
        XCTAssertEqual(paginated.data.count, models.count)
        XCTAssertEqual(paginated.meta.totalPages, 1)
    }

    func testAdvancedQueryPagination() throws {
        // create models in DB
        let models: [TestModel] = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]

        // request endpoint and decode response
        let response = try app.getResponse(to: "/advanced")
        let paginated = try response.content.decode(Paginated<TestModel.Public>.self).wait()

        // test
        XCTAssertEqual(paginated.data.count, models.count)
        XCTAssertEqual(paginated.page.data.total, models.count)
        let assert = models.first { model in
            return paginated.data.contains { $0.name == model.name }
        }
        XCTAssertNotNil(assert)
    }

    func testAdvancedQueryPaginationCustomResponse() throws {
        // create models in DB
        let models: [TestModel] = try [
            TestModel.create(name: "Test 1", on: self.sqlConnection),
            TestModel.create(name: "Test 2", on: self.sqlConnection),
            TestModel.create(name: "Test 3", on: self.sqlConnection),
            TestModel.create(name: "Test 4", on: self.sqlConnection),
            TestModel.create(name: "Test 5", on: self.sqlConnection)
        ]

        // request endpoint and decode response
        let response = try app.getResponse(to: "/advanced/custom")
        let paginated = try response.content.decode(CustomPaginatedResponse.self).wait()

        // test
        XCTAssertEqual(paginated.data.count, models.count)
        XCTAssertEqual(paginated.meta.totalPages, 1)
        let assert = paginated.data.filter { $0.name == "Changed" }
        XCTAssertEqual(assert.count, models.count)
    }

}

// MARK: - All Tests

extension PaginationRouteTests {

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testGetDefualtPaginatedResponse", testGetDefualtPaginatedResponse),
        ("testGetCustomPaginatedResponse", testGetCustomPaginatedResponse),
        ("testAdvancedQueryPagination", testAdvancedQueryPagination),
        ("testAdvancedQueryPaginationCustomResponse", testAdvancedQueryPaginationCustomResponse)
    ]

}
