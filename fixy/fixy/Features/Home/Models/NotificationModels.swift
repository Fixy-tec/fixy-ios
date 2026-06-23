//
//  NotificationModels.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import Foundation

struct NotificationDTO: Decodable, Identifiable {
    let id: UUID
    let title: String
    let message: String?
    let related_request_id: UUID?
    var is_read: Bool
    let created_at: String
}
