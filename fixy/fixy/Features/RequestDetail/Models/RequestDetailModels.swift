//
//  RequestDetailModels.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import Foundation

// 1. Modelo de la Solicitud (Trae los datos de la tabla 'requests' + el perfil del creador)
struct RequestDetailDTO: Decodable {
    let id: UUID
    let creator_id: UUID
    let type: String
    let title: String
    let description: String
    let technologies: [String]
    let difficulty: Int
    let deadline: String
    let price: Double?
    let points_reward: Int
    var status: String
    let profiles: ProfileRelationDTO? // Relación con el creador
}

// 2. Modelo de las Postulaciones (Trae la postulación + el perfil del estudiante)
struct ApplicationDTO: Decodable, Identifiable {
    let id: UUID
    let applicant_id: UUID
    let message: String
    var status: String
    let profiles: ProfileRelationDTO? // Relación con el postulante
}

// 3. Estructura compartida para leer los datos del perfil
struct ProfileRelationDTO: Decodable {
    let full_name: String?
    let total_points: Int?
    let medal: String?
}

// 4. Modelo para insertar una nueva postulación
struct ApplicationInsert: Encodable {
    let requestId: UUID
    let applicantId: UUID
    let message: String
    let status: String = "pendiente"
    
    enum CodingKeys: String, CodingKey {
        case message, status
        case requestId = "request_id"
        case applicantId = "applicant_id"
    }
}
