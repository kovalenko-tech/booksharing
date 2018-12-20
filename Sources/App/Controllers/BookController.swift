//
//  BookController.swift
//  App
//
//  Created by k.kovalenko on 12/19/18.
//

import Vapor
import Pagination

class BookController {
    
    func add(_ req: Request, model: BookRequest) throws -> Future<BookResponse> {
        try model.validate()
        
        return req.withPooledConnection(to: .psql) { (conn) -> Future<BookResponse> in
            return Book.query(on: conn)
                .filter(\.name, .equal, model.name)
                .count().flatMap(to: BookResponse.self) { (count) in
                    
                    if count != 0 {
                        throw Abort(.badRequest, reason: "Such book already exists.")
                    }
                    
                    let model = Book(name: model.name, author: model.author, note: model.note)
                    
                    return model.save(on: conn).map(to: BookResponse.self) { (savedBook) in
                        return BookResponse(id: savedBook.id ?? 0,
                                            image: savedBook.image,
                                            name: savedBook.name,
                                            author: savedBook.author,
                                            note: savedBook.note)
                    }
            }
        }
    }
    
    func get(_ req: Request) -> Future<BookResponse> {
        return try! req.parameters.next(Book.self).map(to: BookResponse.self) { book in
            return BookResponse(id: book.id ?? 0,
                                image: book.image,
                                name: book.name,
                                author: book.author,
                                note: book.note)
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return req.withPooledConnection(to: .psql) { (conn) -> Future<HTTPStatus> in
            return try req.parameters.next(Book.self).flatMap { user in
                return user.delete(on: conn)
            }.transform(to: .ok)
        }
    }
    
    func updateInfo(_ req: Request) throws -> Future<BookResponse> {
        return req.withPooledConnection(to: .psql) { (conn) -> Future<BookResponse> in
            return try req.parameters.next(Book.self).flatMap { model in
                return try req.content.decode(BookRequest.self).flatMap { new in
                    
                    model.name = new.name
                    model.author = new.author
                    model.note = new.note
                    
                    return model.save(on: conn).map(to: BookResponse.self) { (savedBook) in
                        return BookResponse(id: savedBook.id ?? 0,
                                            image: savedBook.image,
                                            name: savedBook.name,
                                            author: savedBook.author,
                                            note: savedBook.note)
                    }
                }
            }
        }
    }
    
    func updateImage(_ req: Request, model: BookRequest) throws -> String {
        try model.validate()
        
        return ""
    }
    
    func list(_ req: Request) throws -> Future<Paginated<BookResponse>> {
        return req.withPooledConnection(to: .psql) { (conn) -> Future<Paginated<BookResponse>> in
            return try BookResponse.query(on: conn).paginate(for: req)
        }
    }
    
}
