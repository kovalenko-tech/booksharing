//
//  User.swift
//  App
//
//  Created by k.kovalenko on 12/10/18.
//

import FluentPostgreSQL
import Pagination
import Validation
import JWT
import Vapor
import Fluent

struct UserResponse: Content {
    let token: String
}

struct SignInUserRequest: Content {
    let email: String
    let password: String
}

extension SignInUserRequest: Validatable {
    
    static func validations() throws -> Validations<SignInUserRequest> {
        var validations = Validations(SignInUserRequest.self)
        
        validations.add(\.password, at: ["password"], .count(6...))
        validations.add(\.email, at: ["email"], .email)
        
        return validations
    }
}

struct UserRequest: Content {
    let email: String
    let password: String
    let name: String
    let position: String
}

extension UserRequest: Validatable {
    
    static func validations() throws -> Validations<UserRequest> {
        var validations = Validations(UserRequest.self)
        
        validations.add(\.name, at: ["name"], .count(3...))
        validations.add(\.password, at: ["password"], .count(6...))
        validations.add(\.email, at: ["email"], .email)
        validations.add(\.position, at: ["position"], .count(3...))
        
        return validations
    }
}

struct User: PostgreSQLModel, JWTPayload {
    var id: Int?
    
    let email: String
    let password: String
    let name: String
    let position: String
    
    func verify(using signer: JWTSigner) throws {
        // nothing to verify
    }
    
    init(email: String, password: String, name: String, position: String) {
        self.email = email
        self.password = password
        self.name = name
        self.position = position
    }
    
}

extension User {
    
    var books: Children<User, Book>? {
        return children(\.userID)
    }
    
    var readers: Children<User, Reader>? {
        return children(\.userID)
    }
}

extension User: Paginatable {}

extension User: Content {}

extension User: Migration {}

extension User: Parameter {}
