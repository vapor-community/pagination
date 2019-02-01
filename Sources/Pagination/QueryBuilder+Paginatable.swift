//
//  QueryBuilder+Paginatable.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

extension QueryBuilder where Result: Paginatable & Content, Result.Database == Database {

    /// Returns a page-based response using page number from the request data.
    public func paginate(for req: Request) throws -> Future<Paginated<Result>> {
        return try self.page(for: req).map { Paginated(from: $0) }
    }

    /// Returns a custom page-based response using page number from the request data.
    public func paginate<T>(for req: Request) throws -> Future<T> where T: PaginatedResponse, T.DataType == Result {
        return try self.page(for: req).map(to: T.self) { T.init(from: $0) }
    }

    /// Returns a page-based response using page number from the request data using a transformtion closure.
    public func paginate<R>(
        on req: Request,
        _ transformation: @escaping (QueryBuilder<Database, Result>) throws -> Future<[R]>
        ) throws -> Future<Paginated<R>> where R: Content {

        return try self.page(for: req, transformation).map { Paginated(from: $0) }
    }

    /// Returns a custom page-based response using page number from the request data using a transformtion closure.
    public func paginate<R, T>(
        on req: Request,
        _ transformation: @escaping (QueryBuilder<Database, Result>) throws -> Future<[R]>
        ) throws -> Future<T> where T: PaginatedResponse, T.DataType == R {

        return try self.page(for: req, transformation).map(to: T.self) { T.init(from: $0) }
    }

}
