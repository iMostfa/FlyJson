//
//  JsonService.swift
//  
//
//  Created by mostfa on 8/6/20.
//

import Foundation
import Combine


protocol JsonService {
   func upload(json: String) -> AnyPublisher<String,JsonServiceError>
}


enum JsonServiceError: Error {
    case unDefinded
    case never
    case decodingError(error: Error)
}



enum JsonUploaders {}
