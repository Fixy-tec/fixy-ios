//
//  NotificationsViewModel.swift
//  fixy
//
//  Created by yordan on 27/06/26.
//

import Foundation

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    
    // MARK: - Obtener notificaciones del usuario actual
    func fetchNotifications() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        isLoading = true
        do {
            self.notifications = try await SupabaseManager.shared.client
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute().value
        } catch {
            print("Error cargando notificaciones: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Marcar una notificación específica como leída
    func markAsRead(notificationId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: notificationId)
                .execute()
            
            // Actualizar el estado local para no recargar toda la lista
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index].is_read = true
            }
        } catch {
            print("Error al marcar como leída: \(error)")
        }
    }
    
    // MARK: - Marcar TODAS como leídas (Para el botón del check)
    func markAllAsRead() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        do {
            try await SupabaseManager.shared.client
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
            
            for i in 0..<notifications.count {
                notifications[i].is_read = true
            }
        } catch {
            print("Error al marcar todas como leídas: \(error)")
        }
    }
    
    // MARK: - Helper: Formateo de fechas a "hace X días"
    func timeAgoDisplay(dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return "recientemente"
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month], from: date, to: Date())
        
        if let month = components.month, month > 0 { return "hace \(month) mes\(month == 1 ? "" : "es")" }
        if let week = components.weekOfYear, week > 0 { return "hace \(week) semana\(week == 1 ? "" : "s")" }
        if let day = components.day, day > 0 { return "hace \(day) día\(day == 1 ? "" : "s")" }
        if let hour = components.hour, hour > 0 { return "hace \(hour) hora\(hour == 1 ? "" : "s")" }
        if let minute = components.minute, minute > 0 { return "hace \(minute) min" }
        return "hace un momento"
    }
    
    // MARK: - Helper: Diseño visual (Colores e íconos)
    func iconData(for title: String) -> (name: String, color: String) {
        let lowerTitle = title.lowercased()
        if lowerTitle.contains("aprobada") {
            return ("checkmark.circle.fill", "green")
        } else if lowerTitle.contains("vence") {
            return ("clock.fill", "yellow")
        } else if lowerTitle.contains("tags") || lowerTitle.contains("coincide") {
            return ("tag.fill", "teal")
        } else {
            return ("bell.fill", "blue")
        }
    }
}
