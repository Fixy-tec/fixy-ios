//
//  HomeViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class HomeViewModel {
    var firstName: String = ""
    var technologies: [String] = []
    var isLoading: Bool = false
    
    // Nuevas variables para Notificaciones
    var recentNotifications: [NotificationDTO] = []
    var unreadCount: Int = 0
    
    func loadUserData() async {
        self.isLoading = true
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        
        do {
            // 1. Cargar Perfil
            let profile: HomeUserDTO = try await SupabaseManager.shared.client
                .from("profiles")
                .select("full_name, technologies")
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.firstName = profile.full_name?.components(separatedBy: " ").first ?? "Usuario"
            self.technologies = profile.technologies ?? []
            
            // 2. Cargar Notificaciones (Traemos las últimas 3 para el Home)
            let fetchedNotifications: [NotificationDTO] = try await SupabaseManager.shared.client
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(3)
                .execute()
                .value
            
            self.recentNotifications = fetchedNotifications
            
            // Contamos cuántas no han sido leídas
            self.unreadCount = fetchedNotifications.filter { !$0.is_read }.count
            
        } catch {
            print("❌ Error cargando Home: \(error)")
        }
        self.isLoading = false
    }
}
