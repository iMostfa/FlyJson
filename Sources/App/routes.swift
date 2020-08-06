import Vapor
import ConsoleKit
import SourceKittenFramework
import Leaf
func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in


      return req.view.render("index",["jsonCode": "Your Json will appear here"])
       }

  app.post("toJson") { (req) ->  EventLoopFuture<View>  in

    let code = try req.content.decode(SwiftCode.self)

    var builder = try SKittenParser(for: .init(contents: code.swift))
      .decode()
      .extractDefaultValues()
      .map{JSON.Builder($0)}
      .first!
    let  result =  try builder.build()
        return req.view.render("index",["jsonCode": result,
                                    "swiftCode": code.swift ])


  }


  app.get("debug", ":name") { req -> String in

    if  let name = req.parameters.get("name") {

      let file = File(path: "/Users/mostfa/Downloads/file.swift")!

      let index = file.contents.index(file.contents.startIndex, offsetBy: Int(req.parameters.get("name")!)!)
//
//      print(file.contents[index].description)

      return file.contents[index].description + "\n \n \n" + file.contents + "\n \n \n \n" + (try! SourceKittenFramework.Structure(file: file).description)
      let me =  try! JSONDecoder().decode(SourceKittenResponse.self, from: ((try! SourceKittenFramework.Structure(file: file).description).data(using: .utf8))!)



    } else {

      return "no offset!"
    }

  }

  app.get("resultOnly", ":name") { req -> String in

   var builder =  try SKittenParser(for: File(path: "/Users/mostfa/Downloads/file.swift")!)
       .decode()
       .extractDefaultValues()
      .map{JSON.Builder($0)}
      .first!
      let  result =  try builder.build()


//print(String(data: try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted), encoding: .utf8)!)

//    let json = JSONSerialization.isValidJSONObject(result)
//    return try SKittenParser(for: File(path: "/Users/mostfa/Downloads/file.swift")!).decode().extractDefaultValues().description
    return  result

  }






}

struct SwiftCode: Codable {
  var swift: String

}





//"""
//
//struct Mostfa {
//var name: String = "Mostfa"
//var age: String = "30"
//}
//
//"""
