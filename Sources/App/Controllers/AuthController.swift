//
//  AuthController.swift
//  App
//
//  Created by k.kovalenko on 12/10/18.
//

import FluentPostgreSQL
import DatabaseKit
import Vapor
import Crypto
import JWT

final class AuthController {
  
    func signUp(_ req: Request, user: UserRequest) throws -> Future<UserResponse> {
        try user.validate()
        
        return req.withPooledConnection(to: .psql) { (conn) -> Future<UserResponse> in
            return User.query(on: conn)
                .filter(\.email, .equal, user.email)
                .count().flatMap(to: UserResponse.self) { (count) in
                    
                if count != 0 {
                    throw Abort(.badRequest, reason: "Such user already exists.")
                }
                
                let hash = try SHA1.hash(user.password).hexEncodedString()
                
                let model = User(email: user.email,
                                 password: hash,
                                 name: user.name,
                                 position: user.position)
                
                return model.save(on: conn).map(to: UserResponse.self) { (savedUser) in
                    let data = try JWT(payload: savedUser).sign(using: .hs256(key: "secret"))
                    return UserResponse(token: String(data: data, encoding: .utf8) ?? "")
                }
            }
        }
    }
    
    func signIn(_ req: Request, model: SignInUserRequest) throws -> Future<UserResponse> {
        try model.validate()
        
        return req.withPooledConnection(to: .psql) { (conn) -> Future<UserResponse> in
            return User.query(on: conn).filter(\.email, .equal, model.email).first().map(to: UserResponse.self) { (user) in
                guard let user = user else {
                    throw Abort(.badRequest, reason: "No such user exists.")
                }
                
                let hash = try SHA1.hash(model.password).hexEncodedString()
                
                if hash != user.password {
                    throw Abort(.badRequest, reason: "Wrong password.")
                }
                
                let data = try JWT(payload: user).sign(using: .hs256(key: "secret"))
                return UserResponse(token: String(data: data, encoding: .utf8) ?? "")
            }
        }
    }
    
}
