//
//  ContentView.swift
//  fixy
//
//  Created by yordan on 17/06/26.
//

import SwiftUI

struct ContentView: View {
    // Variable que controla qué pantalla estamos viendo
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                // Si está logueado, ve todo el sistema
                MainNavigationView()
            } else {
                // Si no, ve la pantalla de acceso
                LoginView()
            }
        }
        .task {
            // 1. Verificar si ya hay una sesión guardada al abrir la app
            do {
                _ = try await SupabaseManager.shared.client.auth.session
                isAuthenticated = true
            } catch {
                isAuthenticated = false
            }
            
            // 2. Escuchar los cambios en tiempo real (Login o Logout)
            for await state in SupabaseManager.shared.client.auth.authStateChanges {
                if state.event == .signedIn {
                    isAuthenticated = true
                } else if state.event == .signedOut {
                    isAuthenticated = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
