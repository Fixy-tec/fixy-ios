//
//  RankingModels.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation

struct RankingUserDTO: Decodable, Identifiable {
    let id: UUID
    let full_name: String?
    let total_points: Int?
    let medal: String?
}

// Estructura de soporte para nuestro sistema de medallas/rangos
struct MedalTier: Hashable {
    let name: String
    let minPoints: Int
    let maxPoints: Int? // nil para el rango máximo (Challenger)
    
    var rangeText: String {
        if let max = maxPoints { return "\(minPoints)-\(max)" }
        return "\(minPoints)+"
    }
}
