//
//  SessionManager.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor 
final class SessionManager {
    var currentUser: User?
    var isAuthenticated: Bool = false
    
    init() {
        Task {
            await startListeningToAuthChanges()
        }
    }
    
    private func startListeningToAuthChanges() async {
        // Al usar @MainActor, ya no necesitamos el "DispatchQueue.main.async"
        // Swift se encarga automáticamente de actualizar esto de forma segura.
        for await state in SupabaseManager.shared.client.auth.authStateChanges {
            self.currentUser = state.session?.user
            self.isAuthenticated = state.session != nil
        }
    }
    
    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
