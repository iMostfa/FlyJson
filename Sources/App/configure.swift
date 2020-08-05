import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
  app.leaf.cache.isEnabled = app.environment.isRelease
  app.views.use(.leaf)
  app.leaf.cache.isEnabled = app.environment.isRelease
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes

  
    try routes(app)
}
