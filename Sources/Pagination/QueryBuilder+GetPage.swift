//
//  QueryBuilder+GetPage.swift
//  Pagination
//
//  Created by Mikkel Ulstrup on 31/01/2019.
//

import Fluent
import Vapor

extension QueryBuilder where Result: Paginatable & Content, Result.Database == Database {

    /// Get a `Page` with a transformation closure.
    /// If you don't need the advanced transform closure, use the method without the closure.
    ///
    /// - Parameters:
    ///   - page: The current page that is being fetched.
    ///   - per: Items per page.
    ///   - sorts: How the query should be sorted.
    ///   - transform: A transformation closure, that allows you to do advanced quries such as joins.
    /// - Returns: A page based on the transformation output.
    public func getPage<R: Content>(
        current page: Int,
        per: Int = Result.defaultPageSize,
        sorts: [Result.Database.QuerySort] = Result.defaultPageSorts,
        transform: @escaping (QueryBuilder) throws -> Future<[R]>
        ) throws -> Future<Page<R>> {

        // Make sure the current page is greater than 0
        guard page > 0 else {
            throw PaginationError.invalidPageNumber(page)
        }

        // Per-page also must be greater than zero
        guard per > 0 else {
            throw PaginationError.invalidPerSize(per)
        }

        // Require page 1 or greater
        let page = page > 0 ? page : 1

        // Return a full count
        return self.count().flatMap { total in
            // Limit the query to the desired page
            let lowerBound = (page - 1) * per
            Database.queryRangeApply(lower: lowerBound, upper: lowerBound + per, to: &self.query)

            // Add the sorts
            for sort in sorts {
                Database.querySortApply(sort, to: &self.query)
            }

            // Return the transformed result in a page
            return try transform(self).map { results in
                try Page<R>(number: page, data: results, size: per, total: total)
            }
        }
    }

    /// Get a `Page` from the current `QueryBuilder`.
    /// If you need the advanced queries such as joins, use the method with a transform closure.
    ///
    /// - Parameters:
    ///   - page: The current page that is being fetched.
    ///   - per: Items per page.
    ///   - sorts: How the query should be sorted.
    /// - Returns: A page based on the current `QueryBuilder.Result` type.
    public func getPage(
        current page: Int,
        per: Int = Result.defaultPageSize,
        sorts: [Result.Database.QuerySort] = Result.defaultPageSorts
        ) throws -> Future<Page<Result>> {

        return try getPage(current: page, per: per, sorts: sorts) { $0.all() }
    }

}
