//
//  Application+Testable.swift
//  Pagination
//
//  Created by Anthony Castelli on 5/2/18.
//

import Foundation
import FluentSQLite
import Vapor

extension Application {
    static func testable(envArgs: [String] = ["serve"], services: Services = .default()) throws -> Application {
        let config = Config.default()
        var services = services
        var env = Environment.testing
        env.arguments = envArgs

        try services.register(FluentSQLiteProvider())

        var databases = DatabasesConfig()
        try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
        databases.enableLogging(on: .sqlite)
        services.register(databases)

        var migrations = MigrationConfig()
        migrations.add(model: TestModel.self, database: .sqlite)
        services.register(migrations)

        return try Application(config: config, environment: env, services: services)
    }

    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
}

extension Application {

    func getResponse(to path: String) throws -> Response {
        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: .GET, url: URL(string: path)!)
        let wrappedRequest = Request(http: request, using: self)
        return try responder.respond(to: wrappedRequest).wait()
    }

}
