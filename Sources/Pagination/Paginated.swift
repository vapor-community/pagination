//
//  Paginated.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

/// A defualt paginated response.
/// If you need to create your own custom response objects, conform them to the `PaginatedResponse` protocol.
public struct Paginated<M: Content>: PaginatedResponse {

    /// See `PageInfo`.
    public var page: PageInfo

    /// The paginated data.
    public var data: [M]

    // MARK: - Lifecycle

    public init(page: PageInfo, data: [M]) {
        self.page = page
        self.data = data
    }

    public init(from page: Page<M>) {
        let count = Int(ceil(Double(page.total) / Double(page.size)))
        let position = Position(
            current: page.number,
            next: page.number < count ? page.number + 1 : nil,
            previous: page.number > 1 ? page.number - 1 : nil,
            max: count
        )
        let pageData = PageData(
            per: page.size,
            total: page.total
        )
        let pageInfo = PageInfo(
            position: position,
            data: pageData
        )
        self.page = pageInfo
        self.data = page.data
    }

}

// MARK: - Pagination helper structs

public struct Position: Content {
    public var current: Int
    public var next: Int?
    public var previous: Int?
    public var max: Int

    public init(current: Int, next: Int? = nil, previous: Int? = nil, max: Int) {
        self.current = current
        self.next = next
        self.previous = previous
        self.max = max
    }
}

public struct PageData: Content {
    public var per: Int
    public var total: Int

    public init(per: Int, total: Int) {
        self.per = per
        self.total = total
    }
}

public struct PageInfo: Content {
    public var position: Position
    public var data: PageData

    public init(position: Position, data: PageData) {
        self.position = position
        self.data = data
    }
}
