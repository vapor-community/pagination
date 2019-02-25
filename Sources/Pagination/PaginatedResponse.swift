//
//  PaginatedResponse.swift
//  Pagination
//
//  Created by Mikkel Ulstrup on 31/01/2019.
//

import Vapor

/// Use this protocol to create custom paginated responses.
/// See `Paginated` for an example of how it is implemented.
public protocol PaginatedResponse: Content {

    /// Det underlying data type that must be paginated.
    associatedtype DataType: Content

    /// Initilize a new response from a `Page` to create a response.
    ///
    /// - Parameter page: See `Page`.
    init(from page: Page<DataType>)

}
