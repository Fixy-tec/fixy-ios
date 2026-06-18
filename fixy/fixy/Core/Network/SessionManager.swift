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
            for await state in SupabaseManager.shared.client.auth.authStateChanges {
                let session = state.session
                self.currentUser = session?.user
                
                // Validamos que la sesión exista y que NO esté expirada
                let isExpired = session?.isExpired ?? true
                self.isAuthenticated = session != nil && !isExpired
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
