//
//  QueryBuilder+Paginatable.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

extension QueryBuilder where Model: Paginatable {
    public func paginate(page: Int, count: Int = Model.defaultPageSize, _ sorts: [QuerySort] = Model.defaultPageSorts, _ groups: [QueryGroupBy] = Model.defaultPageGroups) throws -> Future<Page<Model>> {
        // Make sure the current pzge is greater than 0
        guard page > 0 else {
            throw PaginationError.invalidPageNumber(page)
        }
        
        // Require page 1 or greater
        let page = page > 0 ? page : 1
        
        // Limit the query to the desired page
		let lowerBound = (page - 1) * count
		self.query.range = QueryRange(lower: lowerBound, upper: lowerBound + count)
        
        // Create the query and get a total count
        return self.count().flatMap(to: Page<Model>.self) { total in
            // Remove all the aggregates from the count
            // Note: Using the `.count()` method appends aggregates to the query
            // which then causes issues below with actually returning the data
            self.query.aggregates.removeAll()
            
            // Add the sorts/groups w/o replacing
            // BUG: An issue with fluent causes issues with grouping and sorting.
            // https://github.com/vapor/fluent/issues/438
//            self.query.groups.append(contentsOf: groups)
//            self.query.sorts.append(contentsOf: sorts)
            
            // Fetch the data
            return self.all().map(to: Page<Model>.self) { results in
                return try Page<Model>(
                    number: page,
                    data: results as! [Model],
                    size: count,
                    total: total
                )
            }
        }
    }
}

extension QueryBuilder where Model: Paginatable {
    /// Returns a paginated response using page
    /// number from the request data
    public func paginate(for req: Request, key: String = Pagination.defaultPageKey, perKey: String = Pagination.defaultPagePerKey, _ sorts: [QuerySort] = Model.defaultPageSorts) throws -> Future<Page<Model>> {
        let page = try req.query.get(Int?.self, at: key) ?? 1
        var per = try req.query.get(Int?.self, at: perKey) ?? Model.defaultPageSize
        if let maxPer = Model.maxPageSize, per > maxPer {
            per = maxPer
        }
        return try self.paginate(
            page: page,
            count: per,
            sorts
        )
    }
}

extension QueryBuilder where Model: Paginatable {
    /// Returns a mapped out future response
    public func paginate<T>(for req: Request) throws -> Future<Paginated<T>> {
        return try T.paginate(for: req).map(to: Paginated<T>.self) { $0.response() }
    }
}
