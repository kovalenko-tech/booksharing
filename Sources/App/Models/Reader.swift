//
//  Reader.swift
//  App
//
//  Created by k.kovalenko on 12/19/18.
//

import FluentPostgreSQL
import Pagination
import Validation
import Vapor

struct Reader: PostgreSQLModel {
    var id: Int?
    var bookID: Int?
    var userID: Int?
    
    let start: Double
    let end: Double
}

extension Reader {
    
    var book: Parent<Reader, Book>? {
        return parent(\.bookID)
    }
    
    var user: Parent<Reader, User>? {
        return parent(\.userID)
    }
}

extension Reader: Paginatable {}

extension Reader: Content {}

extension Reader: Migration {}

extension Reader: Parameter {}


