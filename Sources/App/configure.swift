import Vapor
import FluentPostgresDriver
// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
//    try app.databases.use(.mongo(connectionString: "mongodb://sysop:moon@localhost/jsonSnippet"), as: .mongo)
//    try app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.databases.use(.postgres(hostname: "localhost", username: "mostfa", password: "123123", database: "mostfaessam"), as: .psql)

    app.migrations.add(CreateJsonSnippet())
    
    // register routes
    try app.autoMigrate().wait()
    try routes(app)
}
