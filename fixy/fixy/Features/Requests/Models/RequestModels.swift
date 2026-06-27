//
//  RequestModels.swift
//  fixy
//
//  Created by yordan on 26/06/26.
//

import Foundation

// MARK: - DTO para las solicitudes (Requests)
struct MyRequestDTO: Decodable, Identifiable {
    let id: UUID
    let creator_id: UUID
    let type: String
    let title: String
    let description: String
    let technologies: [String]?
    let difficulty: Int
    let deadline: String
    let price: Double?
    let points_reward: Int	
    let applicants_count: Int?
    let status: String?
    let created_at: String
    let profiles: CreatorProfileDTO?
    let applications: [MyApplicationDTO]?
}

struct CreatorProfileDTO: Decodable {
    let full_name: String?
    let medal: String?
}

// MARK: - DTO para las postulaciones cruzadas (Applications)
struct MyApplicationDTO: Decodable, Identifiable {
    let id: UUID
    let request_id: UUID
    let applicant_id: UUID
    let status: String?
    let created_at: String
    
    // Relación para traer los datos del request al que postulamos
    let requests: MyRequestDTO?
}
