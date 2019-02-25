//
//  PaginationError.swift
//  Pagination
//
//  Created by Mikkel Ulstrup on 01/02/2019.
//

import Foundation

public enum PaginationError: Error {
    case invalidPageNumber(Int)
    case invalidPerSize(Int)
    case unspecified(Error)
}
