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

public protocol Paginatable: Model where Self.Database: QuerySupporting {
    static var defaultPageSize: Int { get }
    static var maxPageSize: Int? { get }
    static var defaultPageSorts: [QuerySort] { get }
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
}
