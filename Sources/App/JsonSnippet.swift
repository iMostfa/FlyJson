//
//  File.swift
//  
//
//  Created by Mostfa Essam on 8/12/20.
//

import Foundation
import Vapor
import Fluent
import FluentMongoDriver

final class JsonSnippet: Model,Content {
    // Name of the table or collection.
    static let schema = "jsonSnippet"

    // Unique identifier for each .
    @ID(key: .id) var id: UUID?

    //name
    @Field(key: "name") var name: String
    
    @Field(key: "swiftCode") var swiftCode: String
    
    @Field(key: "jsonCode") var jsonCode: String
    
    @Field(key: "jsonURL") var jsonURL: String
    
 

    // Creates a new, empty Snippet.
    init() { }

    // Creates a new Snippet with all properties set.
    init(id: UUID? = nil,name: String, swiftCode: String,jsonCode: String, jsonURL: String) {
        self.id = id
        self.swiftCode = swiftCode
        self.jsonCode = jsonCode
        self.jsonURL = jsonURL
        self.name = name
    }
    
    init(jsonCode: String) {
        self.jsonCode = jsonCode
    }
    
    init(jsonCode: String, swiftCode: String) {
        self.jsonCode = jsonCode
        self.swiftCode = swiftCode
    }
}


struct CreateJsonSnippet: Migration {
    // Prepares the database for storing jsonSnippets.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(JsonSnippet.schema)
            .id()
            .field("name", .string)
            .field("swiftCode", .string)
            .field("jsonCode", .string)
            .field("jsonURL", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(JsonSnippet.schema).delete()
    }
}
