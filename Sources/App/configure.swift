import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    try services.register(FluentPostgreSQLProvider())

    // Configure a SQLite database
    let postgresqlConfig = PostgreSQLDatabaseConfig(
        hostname: "manny.db.elephantsql.com",
        port: 5432,
        username: "tlizqtzq",
        database: "tlizqtzq",
        password: "7tw9uvI7hSy471P9MLIU0LsDUSPSOmki"
    )
    services.register(postgresqlConfig)
    
    let poolConfig = DatabaseConnectionPoolConfig(maxConnections: 5)
    services.register(poolConfig)
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Book.self, database: .psql)
    migrations.add(model: Reader.self, database: .psql)
    services.register(migrations)
}
