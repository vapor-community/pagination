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

extension TestModel: Migration { }

extension TestModel: Paginatable { }

extension TestModel: Timestampable {
    static var createdAtKey: WritableKeyPath<TestModel, Date?> = \TestModel.createdAt
    static var updatedAtKey: WritableKeyPath<TestModel, Date?> = \TestModel.updatedAt
}

extension TestModel {
    @discardableResult
    static func create(name: String = "Test", on connection: SQLiteConnection) throws -> TestModel {
        return try TestModel(name: name).save(on: connection).wait()
    }
}
