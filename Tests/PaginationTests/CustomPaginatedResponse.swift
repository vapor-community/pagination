//
//  CustomPaginatedResponse.swift
//  PaginationTests
//
//  Created by Mikkel Ulstrup on 31/01/2019.
//

import Foundation
import FluentSQLite
import Fluent
import Pagination
import Vapor

// To solve this question: https://github.com/vapor-community/pagination/issues/14

struct CustomPaginatedResponseMetaData: Content {
    let totalPages: Int
}

struct CustomPaginatedResponseLinks: Content {
    let selfLink: String
    let firstLink: String
    let prevLink: String
    let nextLink: String
    let lastLink: String
}

struct CustomPaginatedResponse: PaginatedResponse {

    typealias DataType = TestModel

    var meta: CustomPaginatedResponseMetaData
    var data: [DataType]
    var links: CustomPaginatedResponseLinks

    init(from page: Page<DataType>) {
        let count = Int(ceil(Double(page.total) / Double(page.size)))
        self.meta = CustomPaginatedResponseMetaData(totalPages: count)
        self.data = page.data
        // do something custom with each link
        let baseURL = "http://example.com/articles?page[number]=3&page[size]=1"
        self.links = CustomPaginatedResponseLinks(
            selfLink: baseURL,
            firstLink: baseURL,
            prevLink: baseURL,
            nextLink: baseURL,
            lastLink: baseURL
        )
    }

}
