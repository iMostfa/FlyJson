import Vapor
import ConsoleKit
import SourceKittenFramework
import Leaf
func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in


       return req.view.render("index")
       }

  app.post("toJson") { (req) -> String  in

    let code = try req.content.decode(SwiftCode.self)

    var builder = try SKittenParser(for: .init(contents: code.swift))
      .decode()
      .extractDefaultValues()
      .map{JSON.Builder($0)}
      .first!
    let  result =  try builder.build()

    return result


  }
  

    app.get("hello") { req -> String in



      return  "!"
    }

  app.get("testKitten") { req -> String  in
    //    let k = (SwiftDocs(file: file, arguments: ["-j4", file.path!])!)

    let file = File(path: "/Users/mostfa/Downloads/file.swift")!
    let index = file.contents.index(file.contents.startIndex, offsetBy: 10)

    return file.contents[index].description

  }

  app.get("helllo", ":name") { req -> String in

    if  let name = req.parameters.get("name") {

      let file = File(path: "/Users/mostfa/Downloads/file.swift")!

      let index = file.contents.index(file.contents.startIndex, offsetBy: Int(req.parameters.get("name") as! String)!)
//
//      print(file.contents[index].description)

      return file.contents[index].description + "\n \n \n" + file.contents + "\n \n \n \n" + (try! SourceKittenFramework.Structure(file: file).description)
      let me =  try! JSONDecoder().decode(SourceKittenResponse.self, from: ((try! SourceKittenFramework.Structure(file: file).description).data(using: .utf8))!)
//      let mirror =  Mirror(reflecting: me)

   //   return me.models.first!.propertiesO.map{$0.name}.reduce("", {$0 + "\n" + $1})


    } else {

      return "no offset!"
    }

  }

  app.get("hello", ":name") { req -> String in

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
