//
//  Paginatable.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

public enum PaginationError: Error {
    case invalidPageNumber(Int)
    case unspecified(Error)
}

public protocol Paginatable: Model {
    static var defaultPageSize: Int { get }
    static var maxPageSize: Int? { get }
    static var defaultPageSorts: [QuerySort] { get }
    static var defaultPageGroups: [QueryGroupBy] { get }
}

extension Paginatable {
    public static var defaultPageSize: Int {
        return 10
    }
    
    public static var maxPageSize: Int? {
        return nil
    }
}

extension Paginatable where Self: Timestampable {
    public static var defaultPageSorts: [QuerySort] {
        return [
            QuerySort(field: QueryField(entity: Self.entity, name: "createdAt"), direction: .descending)
        ]
    }
    
    public static var defaultPageGroups: [QueryGroupBy] {
        return [
            QueryGroupBy.field(QueryField(entity: Self.entity, name: "createdAt"))
        ]
    }
}
