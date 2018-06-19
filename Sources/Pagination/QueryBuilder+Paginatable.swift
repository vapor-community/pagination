//
//  QueryBuilder+Paginatable.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

extension QueryBuilder where Result: Model & Paginatable {
    public func paginate(page: Int, per: Int = Result.defaultPageSize, _ sorts: [Result.Database.QuerySort] = Result.defaultPageSorts) throws -> Future<Page<Result>> {
        // Make sure the current pzge is greater than 0
        guard page > 0 else {
            throw PaginationError.invalidPageNumber(page)
        }

        // Require page 1 or greater
        let page = page > 0 ? page : 1

        // Return a full count
        return self.count().flatMap(to: Page<Result>.self) { total in
            // Clear all aggregates
//            self.query.aggregates.removeAll()
            
            // Limit the query to the desired page
            let lowerBound = (page - 1) * per
            let rangedQuery = self.range(lower: lowerBound, upper: lowerBound + per)
            
            // Create the query
            // Add the sorts w/o replacing
//            let sortedQuery = rangedQuery.sort(sorts.first!)
            let sortedQuery = rangedQuery
            // Fetch the data
            return sortedQuery.all().map(to: Page<Result>.self) { results in
                return try Page<Result>(
                    number: page,
                    data: results,
                    size: per,
                    total: total
                )
            }
        }
    }
}

extension QueryBuilder where Result: Model & Paginatable & Content {
    /// Returns a page-based response using page number from the request data
    public func paginate(for req: Request, pageKey: String = Pagination.defaultPageKey, perPageKey: String = Pagination.defaultPerPageKey, _ sorts: [Result.Database.QuerySort] = Result.defaultPageSorts) throws -> Future<Page<Result>> {
        let page = try req.query.get(Int?.self, at: pageKey) ?? 1
        var per = try req.query.get(Int?.self, at: perPageKey) ?? Result.defaultPageSize
        if let maxPer = Result.maxPageSize, per > maxPer {
            per = maxPer
        }
        return try self.paginate(
            page: page,
            per: per,
            sorts
        )
    }

    /// Returns a paginated response using page number from the request data
    public func paginate(for req: Request) throws -> Future<Paginated<Result>> {
        return try self.paginate(for: req).map(to: Paginated<Result>.self) { $0.response() }
    }
}
