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
    static var defaultPageSorts: [Self.Database.QuerySort] { get }
}

extension Paginatable {
    public static var defaultPageSize: Int {
        return 10
    }

    public static var maxPageSize: Int? {
        return nil
    }
}

extension Paginatable where Self: QuerySupporting {
    public static var defaultSorts: [Self.Database.QuerySort] {
        return [
            Self.createdAtKey?.querySort(Self.Database.querySortDirectionDescending) ?? Self.idKey.querySort(Self.Database.querySortDirectionAscending)
        ]
    }
}

extension KeyPath where Root: Model {
    public func querySort(_ direction: Root.Database.QuerySortDirection = Root.Database.querySortDirectionAscending) -> Root.Database.QuerySort {
        return Root.Database.querySort(self.queryField, direction)
    }
    
    public var fluentProperty: FluentProperty {
        return FluentProperty.keyPath(self)
    }
    
    public var queryField: Root.Database.QueryField {
        return Root.Database.queryField(fluentProperty)
    }
}
