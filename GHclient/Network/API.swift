//
//  API.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import Foundation
import APIKit

final class DecodableDataParser: DataParser {
    var contentType: String? {
        return "applicaiton/json"
    }
    
    func parse(data: Data) throws -> Any {
        return data
    }
}

protocol GitHubRequest: Request {}

extension GitHubRequest {
    public var baseURL: URL {
        return URL(string: "https://api.github.com/")!
    }
}

public struct GetUsers: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = GetUsersResponse
    public let method: HTTPMethod = .get
    public var path: String {
        return "/search/users"
    }
    
    public var parameters: Any? {
        return ["q": q, "sort": sort, "order": order]
    }
    
    let q: String
    let sort: String
    let order: String
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> GetUsersResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(GetUsersResponse.self, from: data)
    }
}
