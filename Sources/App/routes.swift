import Vapor
import JWT
import Crypto
import Pagination
import FluentPostgreSQL

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    router.get("test") { (req) -> String in
        return "it's work"
    }
  
    let v1 = router.grouped("v1")
  
    let authGroup = v1.grouped("auth")
  
    let authController = AuthController()
  
    authGroup.post(UserRequest.self, at: "signup", use: authController.signUp)
    authGroup.post(SignInUserRequest.self, at: "signin", use: authController.signIn)
    
    let logginedGroup = v1.grouped(AuthJWTMiddleware())
    
    let bookGroup = logginedGroup.grouped("book")
    let bookController = BookController()
    
    bookGroup.post(BookRequest.self, at: "add", use: bookController.add)
    bookGroup.get("list", use: bookController.list)
    bookGroup.patch("", Book.parameter, use: bookController.updateInfo)
    bookGroup.delete("", Book.parameter, use: bookController.delete)
}
