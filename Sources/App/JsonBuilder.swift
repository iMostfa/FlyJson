//
//  File 2.swift
//  
//
//  Created by mostfa on 8/5/20.
//

import Foundation
//i'm trying to learn a new of designning APIs

#warning("consider making it as DSL")
#warning("later we will genrate first the subChilds in schema")

extension JSON {

  struct Builder {
    private var schema: JsonSchema
    private var current: String?

    init(_ schema: JsonSchema) {
      self.schema = schema
    }

    private init(currentText: String,schema: JsonSchema) {
      self.schema = schema
      self.current = currentText
    }

    //MARK: - schema functions

    mutating func build()throws  ->  String {
      var builder = self.openJson()

      var  final = try schema.property?.reduce(JSON.Builder(self.schema), { (_, property) -> JSON.Builder in
        return try builder.add(key: property.name, value: property.value, type: property.type)
      })

      var json = try final!.closeJson().result()

      if json.last != "}" {
        json.append("}")
      } //temp fix

      return json

    }

    //MARK: - Json Modifiers
    mutating func openJson() -> JSON.Builder {

      self.current = "{"
      return self
    }

    mutating func closeJson() throws -> JSON.Builder {
      try checkStarted()
      if self.current!.last! == "," {
        _ = self.current!.removeLast()
      }
      return self
    }

    func result() throws -> String {
      try checkStarted()

      return self.current!
    }

    mutating func add(key: String,value: String, type: String ) throws -> JSON.Builder {
      #warning("should check later if the type is avaliable in jsonSchema childs, if avaliable, we will make the json for the childs first ??")
      guard let keyType = JsonTypes(rawValue: type) else { throw  JSON.BuilderError.unsupportedType(type: value) }

      switch keyType {

      case .String:
        return try self.add(key: key, value: value)
      case .arrayString:
        throw JSON.BuilderError.unsupportedType(type: "not ready yet")
      case .Int:
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

       return try self.add(key: key, value: Int(trimmed))
      case .arrayInt:
        throw JSON.BuilderError.unsupportedType(type: "not ready yet")
      case .double:
        throw JSON.BuilderError.unsupportedType(type: "not ready yet")
      case .arrayDouble:
        throw JSON.BuilderError.unsupportedType(type: "not ready yet")
      case .bool:
        let v = value.removingAllWhitespaces().description
        let value = (value as NSString).boolValue
        return try add(key: key, value: value)

      }

    }


    //MARK: - Value adders
    //I KNOW ABOUT GENERICS, BUT EACH ONE TAKE A SPECIFIC WORK ?
    mutating func add(key: String, value: String) throws->  JSON.Builder {
     try checkStarted()
      self.current! += "\"\(key)\": \(value),"
      return self
    }

    mutating func add(key: String, value: Int?) throws->  JSON.Builder {
      try checkStarted()
      guard let value = value else { throw JSON.BuilderError.wrongType(message: "can't convert the given value for key \(key) to int")}
       self.current! += "\"\(key)\": \(value),"
       return self
     }

    mutating func add(key: String, value: Double?) throws->  JSON.Builder {
       try checkStarted()
      guard let value = value else { throw JSON.BuilderError.wrongType(message: "can't convert the given value for key \(key) to Double")}
      #warning("now we can make them generic because all of them take the same things")
       self.current! += "\(key): \(value),"
       return self
     }

    mutating func add(key: String, value: Bool?) throws ->  JSON.Builder {
        try checkStarted()

      guard let value = value else { throw JSON.BuilderError.wrongType(message: "can't convert the given value for key \(key) to boolean")}

        self.current! += "\"\(key)\": \(value),"
        return self
      }

    //MARK: - Editor checkers
    func checkStarted()  throws {
      guard self.current != nil else { throw JSON.BuilderError.JsonDidntStarted(message: "should call openJSON first!")}
    }

//    func checkNotStarted() throws {
//      guard self.current == nil else { throw  JSON.BuilderError.alreadyStarted}
//    }
  }



  enum JsonTypes: String {
    case String
    case arrayString = "[String]"
    case Int = "Int"
    case arrayInt = "[Int]"
    case double = "Double"
    case arrayDouble = "[Double]"
    case bool = "Bool"

  }
}




enum JSON { }




extension  JSON {
  enum BuilderError: Error {
    case unsupportedType(type: String)
    case JsonDidntStarted(message: String)
    case wrongType(message: String)
    case alreadyStarted
  }
}

 extension String {

    func removingAllWhitespaces() -> String {
        return removingCharacters(from: .whitespaces)
    }

    func removingCharacters(from set: CharacterSet) -> String {
        var newString = self
        newString.removeAll { char -> Bool in
            guard let scalar = char.unicodeScalars.first else { return false }
            return set.contains(scalar)
        }
        return newString
    }
}
