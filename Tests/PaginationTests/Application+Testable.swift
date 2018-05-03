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
    static func testable(envArgs: [String] = ["serve"]) throws -> Application {
        let config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        env.arguments = envArgs
        
        try services.register(FluentSQLiteProvider())
        
        var databases = DatabasesConfig()
        try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
        services.register(databases)
        
        var migrations = MigrationConfig()
        migrations.add(model: TestModel.self, database: .sqlite)
        services.register(migrations)
        
        let app = try Application(config: config, environment: env, services: services)
//        try app.asyncRun().wait()
        return app
    }
    
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment).asyncRun().wait()
    }
}
