//
//  ProfileModels.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation

// MARK: - DTOs de Supabase (Para leer la BD)
struct ProfileDTO: Decodable {
    let id: UUID
    let full_name: String?
    let career: String?
    let cycle: Int?
    let total_points: Int?
    let medal: String?
    let technologies: [String]?
    let phone_number: String?
    let rating: Double?
    let completed_tasks: Int?
    let avatar_id: String?
    let github_url: String?
    let linkedin_url: String?
    let portfolio_url: String?
    let bio: String?
}

struct UserLinkDTO: Decodable, Identifiable {
    let id: UUID
    let title: String
    let url: String
    let icon_name: String
    
    // Mapeo para tu Vista
    var iconName: String { icon_name }
}

struct UserReviewDTO: Decodable, Identifiable {
    let id: UUID
    let reviewer_name: String
    let reviewer_initials: String
    let rating: Double
    let comment: String
    let created_at: String
    
    // Mapeo para tu Vista
    var reviewerName: String { reviewer_name }
    var reviewerInitials: String { reviewer_initials }
    var date: String { String(created_at.prefix(10)) } // Solo YYYY-MM-DD
}

// MARK: - Modelo de Presentación (Este es el "user" de tu ViewModel)
struct ProfilePresentationModel {
    var id: UUID = UUID()
    var initials: String = "--"
    var avatarId: String? = nil
    var fullName: String = "Cargando..."
    var career: String = "..."
    var cycle: String = "..."
    var points: Int = 0
    var rankingPosition: Int = 0
    var rating: Double = 0.0
    var completedTasks: Int = 0
    var technologies: Set<String> = []
    var phoneNumber: String = ""
    var links: [UserLinkDTO] = []       // 👈 ¡Aquí están los links!
    var reviews: [UserReviewDTO] = []   // 👈 ¡Aquí están las reviews!
    var bio: String = ""
}

struct MedalDisplay {
    let name: String
    let min: Int
    let image: String
}

// MARK: - DTO para Actualizar Perfil
struct ProfileUpdateDTO: Encodable {
    let full_name: String
    let career: String
    let cycle: Int
    let bio: String
    let github_url: String
    let linkedin_url: String
    let portfolio_url: String
    let avatar_id: String
}
