//
//  FixyRequest.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation

// Definición pura de los datos de una solicitud
struct FixyRequest: Identifiable {
    let id = UUID()
    let type: String
    let points: Int
    let title: String
    let technologies: [String]
    let creatorName: String
    let creatorAvatar: String
    let creatorMedal: String
    let price: Double?
    let expiration: String
    let applicants: Int
}
