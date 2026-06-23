//
//  HomeView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(MainNavigationViewModel.self) var navViewModel
    @State private var viewModel = HomeViewModel()
    @State private var showCreateModal = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: - Tarjeta Bienvenida con Degradado (Diseño Fiel)
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Bienvenido, \(viewModel.firstName)")
                                .font(.title2).fontWeight(.bold)
                        }
                        
                        Text("Encontramos nuevas solicitudes compatibles con tus habilidades.")
                            .font(.subheadline).opacity(0.9)
                        
                        // Skills Reales de Supabase
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.technologies, id: \.self) { tech in
                                Text(tech)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.2)) // Fondo semi-transparente
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Acciones de Navegación
                        HStack(spacing: 15) {
                            Button { navViewModel.selectedTab = .buscar } label: {
                                Label("Explorar", systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity).padding().background(.white)
                                    .foregroundColor(Color.blue).cornerRadius(12).fontWeight(.bold) // Texto azul
                            }
                            
                            Button { showCreateModal = true } label: {
                                Label("Crear", systemImage: "plus")
                                    .frame(maxWidth: .infinity).padding()
                                    .background(.white.opacity(0.2)).cornerRadius(12) // Semi-transparente
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white, lineWidth: 1))
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(20)
                    // 👇 AQUÍ ESTÁ EL DEGRADADO EXACTO DE TU IMAGEN
                    .background(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20) // Bordes redondeados
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Notificaciones Recientes
                    notificationSection
                }
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .task { await viewModel.loadUserData() }
            .fullScreenCover(isPresented: $showCreateModal) { CreateRequestView() }
            
            // MARK: - Barra Superior (Logo y Campana)
            .toolbar {
                // Lado Izquierdo: LOGO
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("FixyLogo") // ⚠️ Cambia esto por el nombre exacto de tu imagen en Assets
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75) // Altura ajustada para que no se vea gigante
                }
                
                // Lado Derecho: CAMPANA DE NOTIFICACIONES
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotificationsView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            // Burbuja roja (Solo aparece si hay notificaciones sin leer)
                            if viewModel.unreadCount > 0 {
                                Text("\(viewModel.unreadCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
            }
        }
    } // 👈 ¡ESTA ES LA PRIMERA LLAVE QUE FALTABA! (Cierra la variable 'body')
    
    // MARK: - Sección de Notificaciones
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("NOTIFICACIONES RECIENTES", systemImage: "bell")
                .font(.caption).fontWeight(.bold).foregroundColor(.secondary).padding(.horizontal)
            
            if viewModel.recentNotifications.isEmpty {
                Text("No tienes notificaciones recientes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ForEach(viewModel.recentNotifications) { notification in
                    // Si la notificación tiene un ID de solicitud, nos lleva al Detalle real
                    NavigationLink(destination: Group {
                        if let reqId = notification.related_request_id {
                            RequestDetailView(requestId: reqId)
                        } else {
                            Text("Esta notificación no está enlazada a una solicitud")
                        }
                    }) {
                        HStack(alignment: .top, spacing: 15) {
                            Circle()
                                .fill(notification.is_read ? Color.clear : Color.cyan)
                                .frame(width: 8, height: 8)
                                .padding(.top, 5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.title)
                                    .font(.subheadline)
                                    .fontWeight(notification.is_read ? .regular : .medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                if let msg = notification.message {
                                    Text(msg).font(.caption).foregroundColor(.secondary).lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
} // 👈 ¡ESTA ES LA SEGUNDA LLAVE QUE FALTABA! (Cierra el 'struct HomeView')

#Preview {
    HomeView()
        .environment(MainNavigationViewModel())
}
