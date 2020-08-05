//
//  File.swift
//  
//
//  Created by mostfa on 8/4/20.
//

import Foundation

struct SourceKittenResponse: Codable  {

  var models: [Model]

  private enum CodingKeys : String, CodingKey {
        case models = "key.substructure"
    }

}

extension SourceKittenResponse {

  struct Model: Codable {
    var name: String
    var startIndex: Int
    var endIndex: Int
    private var properties :[Property]
    var propertiesO: [Property] {
      return properties.filter{$0.kind == .instance}
    }
    var chars: Range<Int> {
      return (startIndex ..< endIndex - 1)
    }

    private enum CodingKeys : String, CodingKey {
          case name = "key.name"
          case startIndex = "key.nameoffset"
          case endIndex = "key.namelength"
          case properties = "key.substructure"
      }
   }


}


struct Property: Codable {
  var kind: ProperyKind
  var name: String?
  var startIndex: Int
  var endIndex: Int
  var type: String?

  var chars: Range<Int> {
    return (startIndex ..< startIndex + endIndex - 1)
  }

  private enum CodingKeys : String, CodingKey {
          case name = "key.name"
          case kind = "key.kind"
          case startIndex = "key.nameoffset"
          case endIndex = "key.namelength"
          case type = "key.typename"
      }

}

enum ProperyKind: String, Codable {

  case instance = "source.lang.swift.decl.var.instance" //var or let
  case call = "source.lang.swift.expr.call"

}






