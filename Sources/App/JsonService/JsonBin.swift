//
//  File.swift
//  
//
//  Created by mostfa on 8/6/20.
//

import Foundation
import Combine


class jsonUploader: JsonService {
    func upload(json: String) -> AnyPublisher<String, JsonServiceError> {
        jsonService.upload(json: json)
    }
    
    var jsonService: JsonService
    
    init(using service: JsonService) {
        self.jsonService = service
    }
    
    
}

struct JsonBin: JsonService {
    private var secretKey = "$2b$10$s/jQICyINYMma.iRpSB8TeWlfgmq9sRvPIqQ.PUilT3sQznJK/W5S"
  func upload(json: String) -> AnyPublisher<String, JsonServiceError> {

    
    let jsonData = json.data(using: .utf8)
    
    var request = URLRequest(url: URL(string: "https://api.jsonbin.io/b")!)
    
    request.httpMethod = "POST"
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(secretKey, forHTTPHeaderField: "secret-key")
    request.addValue("false", forHTTPHeaderField: "private")
    
  return  URLSession
        .shared
        .dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: UploadResponse.self, decoder: JSONDecoder())
        .map(\.id)
        .map {"https://api.jsonbin.io/b/\($0)"}
        .mapError{ JsonServiceError.decodingError(error: $0)}
        .eraseToAnyPublisher()
        
  }

  
}

extension JsonBin {
    struct UploadResponse: Codable {
        var success: Bool
        var id: String
    }

}
