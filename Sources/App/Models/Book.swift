//
//  Book.swift
//  App
//
//  Created by k.kovalenko on 12/19/18.
//

import FluentPostgreSQL
import Pagination
import Validation
import Vapor

struct BookRequest: Content {
    let name: String
    let author: String
    let note: String
}

extension BookRequest: Validatable {
    
    static func validations() throws -> Validations<BookRequest> {
        var validations = Validations(BookRequest.self)
        
        validations.add(\.name, at: ["name"], .count(3...))
        validations.add(\.author, at: ["author"], .count(3...))
        validations.add(\.note, at: ["note"], .count(3...))
        
        return validations
    }
}

struct BookResponse: Content {
    let id: Int
    let image: String
    let name: String
    let author: String
    let note: String
}

final class Book: PostgreSQLModel {
    var id: Int?
    var userID: Int?
    
    var name: String
    var image: String
    var author: String
    var note: String
    
    init(name: String, author: String, note: String) {
        self.name = name
        self.author = author
        self.image = ""
        self.userID = 0
        self.note = note
    }
}

extension Book {
    
    var user: Parent<Book, User>? {
        return parent(\.userID)
    }
    
    var readers: Children<Book, Reader>? {
        return children(\.userID)
    }
}

extension Book: Paginatable {}

extension Book: Content {}

extension Book: Migration {}

extension Book: Parameter {}
