import Vapor
import ConsoleKit
import SourceKittenFramework
import Leaf
import Combine

var cancellables:Set<AnyCancellable> = []
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



  app.get("debug", ":name") { req -> EventLoopFuture<String> in

    if  let name = req.parameters.get("name") {

      let file = File(path: "/Users/mostfaessam/Downloads/file.swift")!

//
//         let promise = req.eventLoop.makePromise(of: String.self)
//        req.eventLoop.execute {
//
//            JsonBin().upload(json: "{\"name\":\"Mostfa\"}").sink(receiveCompletion: {print($0)}, receiveValue: {promise.succeed($0)}).store(in: &cancellables)
//
//        }
        
        let somePublisher =  JsonBin().upload(json: "{\"name\":\"Mostfa\"}").promise(on: req)
      
        
        return somePublisher
      let me =  try! JSONDecoder().decode(SourceKittenResponse.self, from: ((try! SourceKittenFramework.Structure(file: file).description).data(using: .utf8))!)
        

        

    } else {

        return  req.eventLoop.makeSucceededFuture("!!!!!!!!")
    }

  }

  app.get("resultOnly", ":name") { req -> AnyPublisher<String,JsonServiceError>  in

    
   var builder =  try SKittenParser(for: File(path: "/Users/mostfaessam/Downloads/file.swift")!)
       .decode()
       .extractDefaultValues()
      .map{JSON.Builder($0)}
      .first!
    
    let  result =  try builder.build()

    
    let toJson = JsonBin()
        .upload(json: result)
   
    

//print(String(data: try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted), encoding: .utf8)!)

//    let json = JSONSerialization.isValidJSONObject(result)
//    return try SKittenParser(for: File(path: "/Users/mostfa/Downloads/file.swift")!).decode().extractDefaultValues().description
    return  JsonBin().upload(json: result)

  }






}

struct SwiftCode: Codable {
  var swift: String

}


extension Publisher {
    
    func promise(on req: Vapor.Request) -> EventLoopFuture<Output>   {
        let eventLoop = req.eventLoop
        let promise = req.eventLoop.makePromise(of: Output.self)
        eventLoop.execute {
            self.sink(receiveCompletion: {_ in}, receiveValue: { promise.succeed($0) })
                .store(in: &req.disposeBag)
        }
        return promise.futureResult
    }
    
}


