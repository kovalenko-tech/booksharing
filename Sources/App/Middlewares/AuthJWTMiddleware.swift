//
//  AuthJWTMiddleware.swift
//  App
//
//  Created by k.kovalenko on 12/10/18.
//

import Vapor
import JWT

final class AuthJWTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard
            let _ = request.http.headers.bearerAuthorization,
            let response = try? next.respond(to: request)else {
            throw Abort(.unauthorized)
        }
        
        return response
    }
}
