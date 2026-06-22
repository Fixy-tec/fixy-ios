//
//  RankingModels.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation

struct FixyMedal: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let minPoints: Int
    let maxPoints: Int
    let imageName: String // Esto coincidirá con tus imágenes en Assets (ej. "diamante")
}

struct RankedStudent: Identifiable {
    let id = UUID()
    let position: Int
    let fullName: String
    let points: Int
    let medal: FixyMedal
    let isCurrentUser: Bool
    
    // Extrae las iniciales automáticamente (ej. "Yordan Sapacayo" -> "YS")
    var initials: String {
        let parts = fullName.components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        
        // CORRECCIÓN AQUÍ: Faltaba el ": """ al final de esta línea
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        
        return String(first + last).uppercased()
    }
}
