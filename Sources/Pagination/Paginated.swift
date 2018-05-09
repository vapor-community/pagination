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
    var current: Int
    var next: Int?
    var previous: Int?
    var max: Int
}
public struct PageData: Content {
    var per: Int
    var total: Int
}
public struct PageInfo: Content {
    var position: Position
    var data: PageData
}
public struct Paginated<M: Model & Paginatable & Content>: Content {
    var page: PageInfo
    var data: [M]
}

extension Page where M: Paginatable & Content {
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
            data: data
        )
    }
}
