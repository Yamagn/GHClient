//
//  Responses.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import Foundation

public struct Users: Codable {
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
    let name: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
        case name
        case type
    }
}

public struct Repository: Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String
    let defaultBranch: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case defaultBranch = "default_branch"
    }
}

public struct Contents: Codable {
    let name: String
    let url: String
    let type: String
}
