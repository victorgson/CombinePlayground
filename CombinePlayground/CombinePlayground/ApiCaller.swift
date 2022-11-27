//
//  ApiCaller.swift
//  CombinePlayground
//
//  Created by Victor Gustafsson on 2022-11-27.
//

import Foundation
import Combine

class ApiCaller {
    static let shared = ApiCaller()
    
    // Future is basically a promise, like in JavaScript
    func fetchStores() -> Future<[String], Error> {
        return Future { promise in
            promise(.success(["Webhallen", "Media Markt"]))
        }
    }
    
    
    
}
