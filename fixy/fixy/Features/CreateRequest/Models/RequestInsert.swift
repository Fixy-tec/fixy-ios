//
//  RequestInsert.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation

// El modelo puro de datos que enviaremos a Supabase
struct RequestInsert: Encodable {
    let creatorId: UUID
    let type: String
    let title: String
    let description: String
    let technologies: [String]
    let difficulty: Int
    let deadline: String
    let price: Double?
    let pointsReward: Int
    
    enum CodingKeys: String, CodingKey {
        case type, title, description, technologies, difficulty, deadline, price
        case creatorId = "creator_id"
        case pointsReward = "points_reward"
    }
}
