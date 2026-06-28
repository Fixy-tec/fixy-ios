//
//  NotificationDTO.swift
//  fixy
//
//  Created by yordan on 27/06/26.
//

import Foundation

struct NotificationModel: Decodable, Identifiable, Equatable {
    let id: UUID
    let user_id: UUID
    let title: String
    let message: String?
    let related_request_id: UUID?
    var is_read: Bool? // Variable para poder actualizarla localmente al leerla
    let created_at: String
}
