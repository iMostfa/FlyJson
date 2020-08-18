import Vapor
import ConsoleKit
import SourceKittenFramework
import Leaf
import Combine
import Fluent

func routes(_ app: Application) throws {
    
    
    app.get{ req -> EventLoopFuture<View> in //normal route in vapor 4
        
        Just("Awesome Combine Publisher") //Combine Publisher, could be any publisher like PassThroughPublisher AnyPublisher,
          
            .flatMap({ (value) -> AnyPublisher<String,Never>  in //flat map from Combine to process data
                return Just(value + "Some operation").eraseToAnyPublisher()
            })
            
            .promise(on: req) //Combine Publisher tranformed to EventLoopFuture
            
            .flatMap { (outputFromCombine) -> EventLoopFuture<View> in //Flat map in SwiftNIO to process data recieved to a view
                return req.view.render("index",outputFromCombine)
        }
        
    }
    
    app.get { req -> EventLoopFuture<View> in
        
        return  JsonSnippet.query(on: req.db).all() // get all the stored snippets
            .map { HomeViewModel(jsonCode: "your json Will appear here", //map to a codable values & default strings for leaf
                                 jsonURL: "your url will appear here",
                                 snippets: $0
                )}
            .flatMap { req.view.render("index", $0) }
    }
    
    //MARK:- transform swift code to json and upload it
    app.post("toJson") { (req) ->  EventLoopFuture<View>  in
        
        let swiftCode = try req.content.decode(SwiftCode.self).swiftCode
        
        var builder = try SKittenParser(for: .init(contents: swiftCode))
            .decode()
            .extractDefaultValues()
            .map{JSON.Builder($0)}
            .first!
        let  jsonCode =  try builder.build()
        
        return jsonUploader(using: JsonBin()) //upload json to the inejected Json service
            .upload(json: jsonCode)
            .promise(on: req) //convert AnyPublisher(Combine) to to eventFutureLoop(SwiftNIO) 😎
            .flatMap { (jsonURL) -> EventLoopFuture<Void> in //recieve the url from the future, and assign it in the database
                let snippet = JsonSnippet(name: UUID().uuidString,
                                          swiftCode: swiftCode,
                                          jsonCode: jsonCode,
                                          jsonURL: jsonURL)
                return snippet.create(on: req.db)
        }
        .flatMap {
            return JsonSnippet.query(on: req.db).all() //return all the stored snippets including last one added
        }
        .map { SnippetsViewModel(swiftCode: swiftCode, //transform to a codable type to be used in Leaf
                                 jsonCode: jsonCode, jsonURL: $0.last?.jsonURL ?? "NoURL",
                                 snippets: $0
            )}
        .flatMap { (viewModel) in //return a eventLoopFuture aka Publisher of the view
            
            return req.view.render("index", viewModel
            )}
    }
    
    
    //MARK:- get Json snippet by ID
    app.get("", ":id") { req ->  EventLoopFuture<View> in
        guard let id = req.parameters.get("id") else { throw ViewError.wrongID}
        return JsonSnippet
            .query(on: req.db)
            .filter(\.$name == id) //fluent has to be imported !
            .first()
            .flatMap { req.view.render("index", SnippetsViewModel(swiftCode: $0?.swiftCode ?? "Swift Code not found!",
                                                                  jsonCode: $0?.jsonCode ?? "Json code not found!",
                                                                  jsonURL: $0?.jsonURL ?? "Json url not found!",
                                                                  snippets: [])) //should fix it later
        }
    }
    

    
    app.get("debug", ":name") { req ->  EventLoopFuture<[JsonSnippet]> in
        //EventLoopFuture<String> in
        
        if  req.parameters.get("name") != nil {
            
            let file = File(path: "/Users/mostfaessam/Downloads/file.swift")!
            
            //
            //         let promise = req.eventLoop.makePromise(of: String.self)
            //        req.eventLoop.execute {
            //
            //            JsonBin().upload(json: "{\"name\":\"Mostfa\"}").sink(receiveCompletion: {print($0)}, receiveValue: {promise.succeed($0)}).store(in: &cancellables)
            //
            //        }
            
            // let somePublisher =  JsonBin().upload(json: "{\"name\":\"Mostfa\"}").promise(on: req)
            
            
            //   return somePublisher
            return JsonSnippet.query(on: req.db).all()
            //            let me =  try! JSONDecoder().decode(SourceKittenResponse.self, from: ((try! SourceKittenFramework.Structure(file: file).description).data(using: .utf8))!)
        } else {
            
            return  req.eventLoop.makeSucceededFuture([])
        }
        
    }
    

    
    
    
    
    
    
}

struct SwiftCode: Codable {
    var swiftCode: String
    
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


struct SnippetsViewModel: Codable {
    var swiftCode: String
    var jsonCode: String
    var jsonURL: String
    var snippets: [JsonSnippet]
}

struct HomeViewModel: Codable {
    var jsonCode: String
    var jsonURL: String

    var snippets: [JsonSnippet]
    
    
}




enum ViewError: Error {
    case wrongID
    
}
