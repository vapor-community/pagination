//
//  TestModel.swift
//  Pagination
//
//  Created by Anthony Castelli on 5/2/18.
//

import Foundation
import FluentSQLite
import Fluent
import Pagination
import Vapor

final class TestModel: SQLiteModel {
    var id: Int?

    var name: String
    
    var createdAt: Date?
    var updatedAt: Date?

    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension TestModel {
    public static var createdAtKey: TimestampKey? = \TestModel.createdAt
    public static var updatedAtKey: TimestampKey? = \TestModel.updatedAt
}

extension TestModel: Migration { }

extension TestModel: Paginatable { }

extension TestModel: Content { }

extension TestModel {
    @discardableResult
    static func create(name: String = "Test", on connection: SQLiteConnection) throws -> TestModel {
        return try TestModel(name: name).save(on: connection).wait()
    }
}

extension TestModel: Equatable {
    static func == (lhs: TestModel, rhs: TestModel) -> Bool {
        return lhs.id == rhs.id
    }
}
