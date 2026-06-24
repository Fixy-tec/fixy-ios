//
//  SearchModels.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import Foundation

struct SearchRequestDTO: Decodable, Identifiable {
    let id: UUID
    let type: String
    let title: String
    let description: String
    let technologies: [String]
    let difficulty: Int
    let points_reward: Int
    let status: String
    let created_at: String
    let profiles: SearchProfileDTO?
}

struct SearchProfileDTO: Decodable {
    let full_name: String?
    let medal: String?
}
