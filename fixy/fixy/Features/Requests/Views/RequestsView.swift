//
//  RequestsView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

// Enumerador para manejar las 4 pestañas de forma segura y limpia
enum RequestTab: String, CaseIterable {
    case postulaciones = "Postulaciones"
    case creadas = "Creadas"
    case enProceso = "En proceso"
    case completadas = "Completadas"
}

struct RequestsView: View {
    @State private var selectedTab: RequestTab = .postulaciones
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Menú Superior Personalizado (Top Tab Bar)
                topTabBar
                
                Spacer()
                
                // 2. Estado Vacío Dinámico
                emptyStateView
                
                Spacer()
                
                // Espaciador extra para que el TabBar inferior no tape el contenido
                Spacer().frame(height: 50)
            }
            .navigationTitle("Mis solicitudes")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
    
    // MARK: - Componentes de la Vista
    
    private var topTabBar: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(RequestTab.allCases, id: \.self) { tab in
                        VStack(spacing: 12) {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedTab == tab ? .bold : .medium)
                                // Color azul primario si está seleccionado, gris si no
                                .foregroundColor(selectedTab == tab ? Color("FixyPrimary") : .gray)
                            
                            // Línea indicadora inferior
                            Rectangle()
                                .fill(selectedTab == tab ? Color("FixyPrimary") : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        }
                        // Agregamos un poco de padding inferior para que la línea no pegue con el borde
                        .padding(.bottom, 8)
                        .onTapGesture {
                            // Animación fluida al cambiar de pestaña
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            // Línea separadora gris que cruza toda la pantalla
            Divider()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Ícono de portapapeles gigante
            Image(systemName: "list.clipboard")
                .font(.system(size: 70))
                .foregroundColor(Color.gray.opacity(0.8))
            
            // Texto que cambia según la pestaña seleccionada
            Text(emptyStateText)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        // Animación sutil para que el ícono y el texto hagan una transición suave
        .transition(.opacity)
        .id(selectedTab) // Fuerza a SwiftUI a redibujar el componente al cambiar de pestaña
    }
    
    // MARK: - Lógica Dinámica
    
    // Texto dinámico para el estado vacío
    private var emptyStateText: String {
        switch selectedTab {
        case .postulaciones:
            return "Aun no te has postulado a nada"
        case .creadas:
            return "Aun no has creado solicitudes"
        case .enProceso:
            return "No tienes solicitudes en proceso"
        case .completadas:
            return "Aun no has completado solicitudes"
        }
    }
}

#Preview {
    RequestsView()
}
