//
//  DashboardView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct DashboardView: View {
    // Inyectamos el manager para poder cerrar sesión desde aquí luego
    @Environment(SessionManager.self) private var sessionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 60))
                .foregroundColor(Color("FixyPrimary"))
            
            Text("¡Bienvenido a Fixy!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Dashboard en construcción...")
                .foregroundColor(.secondary)
            
            Button(action: {
                Task {
                    await sessionManager.signOut()
                }
            }) {
                Text("Cerrar Sesión")
                    .foregroundColor(Color("FixyPointsNegative"))
            }
            .padding(.top, 30)
        }
    }
}

#Preview {
    DashboardView()
        .environment(SessionManager())
}
