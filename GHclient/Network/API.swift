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
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "/search/users"
    }
    
    public var parameters: Any? {
        return ["q": q, "sort": sort, "order": order, "page": page]
    }
    
    let q: String
    let sort: String
    let order: String
    let page: Int
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> GetUsersResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(GetUsersResponse.self, from: data)
    }
}

public struct GetUserRepositories: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = [GetRepositoryResponse]
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "/users/\(username)/repos"
    }
    
    public var parameters: Any? {
        return ["type":"owner", "sort": sort, "direction": direction]
    }
    
    let username: String
    let sort: String
    let direction: String
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [GetRepositoryResponse] {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode([GetRepositoryResponse].self, from: data)
    }
}
