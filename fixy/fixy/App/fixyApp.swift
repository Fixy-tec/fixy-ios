//
//  fixyApp.swift
//  fixy
//
//  Created by yordan on 17/06/26.
//

import SwiftUI

@main
struct fixyApp: App {
    // Inicializamos el SessionManager a nivel de aplicación
    @State private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            // El "Semáforo" de la app
            if sessionManager.isAuthenticated {
                HomeView()
                    .environment(sessionManager) // Lo inyectamos para que las vistas hijas lo puedan usar
            } else {
                LoginView()
                    .environment(sessionManager)
            }
        }
    }
}
