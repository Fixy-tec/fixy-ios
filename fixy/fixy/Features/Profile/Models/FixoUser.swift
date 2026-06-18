//
//  FixoUser.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation

// Codable nos permite convertir fácilmente los datos de Supabase a esta estructura
struct FixoUser: Codable, Identifiable {
    let id: UUID
    let email: String
    var name: String?
    var bio: String?
    var career: String?
    var cycle: Int?
    var points: Int
    var medal: String // "Hierro", "Bronce", etc.
    var avatarId: String
    
    // Mapeo de las columnas de Supabase a nuestras variables en Swift
    enum CodingKeys: String, CodingKey {
        case id, email, name, bio, career, cycle, points, medal
        case avatarId = "avatar_id"
    }
}
