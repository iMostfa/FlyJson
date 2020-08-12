//
//  File.swift
//  
//
//  Created by Mostfa Essam on 8/11/20.
//

import Foundation
import Combine

class JsonController {
    var service: JsonService
    var bag: Set<AnyCancellable> = []
    
    init(_ service: JsonService) {
        self.service = service
    }
    
    func start() {
        
        Timer.publish(every: 10, on: .main, in: .common)
            .sink { (date) in
                print("date!!!")
        }.store(in: &bag)
    }
    deinit {
        print("i'm leaving!")
    }
}
