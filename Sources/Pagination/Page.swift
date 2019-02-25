//
//  Page.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

/// A page with information used to create pagination output.
public struct Page<M: Content> {

    // MARK: - Properties

    /// The current page number.
    public let number: Int

    /// The underlying data that is paginated.
    public let data: [M]

    /// The page size, also known as `per`.
    public let size: Int

    /// The total amount of data entities in the database.
    public let total: Int

    // MARK: - Lifecycle

    // The query used must already be filtered for
    // pagination and ready for `.all()` call
    public init(number: Int, data: [M], size: Int, total: Int) throws {
        guard number > 0 else {
            throw PaginationError.invalidPageNumber(number)
        }
        self.number = number
        self.data = data
        self.size = size
        self.total = total
    }
}
