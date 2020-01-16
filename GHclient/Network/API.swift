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
        return "application/json"
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

public struct SearchUsers: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = Users
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "/search/users"
    }
    
    public var parameters: Any? {
        return ["q": q, "page": page]
    }
    
    let q: String
    let page: Int
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Users.self, from: data)
    }
}

public struct GetUserRepositories: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = [Repository]
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "users/\(username)/repos"
    }
    
    public var parameters: Any? {
        return ["page": page]
    }
    
    let username: String
    let page: Int
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode([Repository].self, from: data)
    }
}

public struct GetContents: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = [Contents]
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "/repos/\(username)/\(reponame)/contents"
    }
    
    let username: String
    let reponame: String
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode([Contents].self, from: data)
    }
}

public struct GetUser: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = UserItem
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "/user"
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(UserItem.self, from: data)
    }
}

public struct GetUserDetail: GitHubRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = UserItem
    public var method: HTTPMethod {
        return .get
    }
    public var path: String {
        return "users/\(username)"
    }
    
    let username: String
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> UserItem {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(UserItem.self, from: data)
    }
}
