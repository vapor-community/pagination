//
//  Paginated.swift
//  Pagination
//
//  Created by Anthony Castelli on 4/5/18.
//

import Foundation
import Fluent
import Vapor

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

public struct Paginated<M: Content>: Content {
    public var page: PageInfo
    public var data: [M]
    
    public init(page: PageInfo, data: [M]) {
        self.page = page
        self.data = data
    }
}

extension Page where M: Content {
    public func response() -> Paginated<M> {
        let count = Int(ceil(Double(self.total) / Double(self.size)))
        let position = Position(
            current: self.number,
            next: self.number < count ? self.number + 1 : nil,
            previous: self.number > 1 ? self.number - 1 : nil,
            max: count
        )
        let pageData = PageData(
            per: self.size,
            total: self.total
        )
        let pageInfo = PageInfo(
            position: position,
            data: pageData
        )
        return Paginated(
            page: pageInfo,
            data: self.data
        )
    }
}
