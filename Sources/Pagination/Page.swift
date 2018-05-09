//
//  Page.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

public struct Page<M: Model & Paginatable> {
    public let number: Int
    public let data: [M]
    public let size: Int
    public let total: Int

    // The query used must already be filtered for
    // pagination and ready for `.all()` call
    public init(number: Int, data: [M], size: Int = M.defaultPageSize, total: Int) throws {
        guard number > 0 else {
            throw PaginationError.invalidPageNumber(number)
        }
        self.number = number
        self.data = data
        self.size = size
        self.total = total
    }
}
