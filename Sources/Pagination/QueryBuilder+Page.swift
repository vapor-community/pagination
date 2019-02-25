//
//  QueryBuilder+Page.swift
//  Pagination
//
//  Created by Mikkel Ulstrup on 31/01/2019.
//

import Fluent
import Vapor

extension QueryBuilder where Result: Paginatable & Content, Result.Database == Database {

    /// Get a `Page` with a transformation closure from a `Request`.
    /// If you don't need the advanced transform closure, use the method without the closure.
    ///
    /// - Parameters:
    ///   - req: The request to be used.
    ///   - pageKey: See `Pagination.defaultPageKey`.
    ///   - perPageKey: See `Pagination.defaultPerPageKey`.
    ///   - sorts: See `Result.defaultPageSorts`.
    ///   - transform: A transformation closure, that allows you to do advanced quries such as joins.
    /// - Returns: A page based on the transformation output.
    public func page<R: Content>(
        for req: Request,
        pageKey: String = Pagination.defaultPageKey,
        perPageKey: String = Pagination.defaultPerPageKey,
        sorts: [Result.Database.QuerySort] = Result.defaultPageSorts,
        _ transform: @escaping (QueryBuilder) throws -> Future<[R]>
        ) throws -> Future<Page<R>> {

        let page = try req.query.get(Int?.self, at: pageKey) ?? 1
        var per = try req.query.get(Int?.self, at: perPageKey) ?? Result.defaultPageSize
        if let maxPer = Result.maxPageSize, per > maxPer {
            per = maxPer
        }

        return try self.getPage(current: page, per: per, sorts: sorts, transform: transform)
    }

    /// Get a `Page` from the current `QueryBuilder` from a `Request`.
    /// If you need the advanced queries such as joins, use the method with a transform closure.
    ///
    /// - Parameters:
    ///   - req: The request to be used.
    ///   - pageKey: See `Pagination.defaultPageKey`.
    ///   - perPageKey: See `Pagination.defaultPerPageKey`.
    ///   - sorts: See `Result.defaultPageSorts`.
    /// - Returns: A page based on the current `QueryBuilder.Result` type.
    public func page(
        for req: Request,
        pageKey: String = Pagination.defaultPageKey,
        perPageKey: String = Pagination.defaultPerPageKey,
        sorts: [Result.Database.QuerySort] = Result.defaultPageSorts
        ) throws -> Future<Page<Result>> {

        let page = try req.query.get(Int?.self, at: pageKey) ?? 1
        var per = try req.query.get(Int?.self, at: perPageKey) ?? Result.defaultPageSize
        if let maxPer = Result.maxPageSize, per > maxPer {
            per = maxPer
        }

        return try self.getPage(current: page, per: per, sorts: sorts)
    }

}
