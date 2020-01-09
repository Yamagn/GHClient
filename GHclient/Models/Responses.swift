//
//  Responses.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import Foundation

public struct GetUsersResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UserItem]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

public struct UserItem: Codable {
    let login: String
    let id: Int
    let avatarUrl: String
    let reposUrl: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
        case type
    }
}

public struct GetRepositoryResponse: Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String
    let defaultBranch: String
}
