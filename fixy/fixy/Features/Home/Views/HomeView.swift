//
//  HomeView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

// Estructura para manejar las notificaciones dinámicamente y poder borrarlas
struct FixyNotification: Identifiable {
    let id = UUID()
    let text: String
    let time: String
    let isUnread: Bool
}

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    // Lista interactiva de notificaciones
    @State private var notifications = [
        FixyNotification(text: "Ana Castillo ha solicitado tu ayuda para una asesoría.", time: "hace 2 horas", isUnread: true),
        FixyNotification(text: "Un estudiante ha visto tu perfil de contacto.", time: "ayer", isUnread: false)
    ]
    
    var body: some View {
        NavigationStack {
            // Cambiamos ScrollView por List para habilitar Swipe Actions nativos
            List {
                // SECCIÓN SUPERIOR: Header y Tarjeta Principal
                VStack(spacing: 24) {
                    headerSection
                    
                    if viewModel.isLoading {
                        ProgressView().padding(.top, 50)
                    } else {
                        welcomeCard
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                
                // SECCIÓN INFERIOR: Actividad y Notificaciones
                Section {
                    ForEach(notifications) { notif in
                        notificationRow(notif)
                            // 🌟 AQUÍ ESTÁ LA MAGIA: Deslizar para eliminar
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        notifications.removeAll { $0.id == notif.id }
                                    }
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    HStack {
                        Image(systemName: "bell.badge")
                        Text("NOTIFICACIONES RECIENTES")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                }
                .listRowSeparator(.visible)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                
                // Espaciador final para el TabBar
                Spacer().frame(height: 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain) // Quita el fondo gris genérico de las listas de Apple
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .task {
                await viewModel.fetchProfile()
            }
        }
    }
    
    // MARK: - Componentes de la Vista
    
    private var headerSection: some View {
        HStack {
            Image("FixyLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
            
            Spacer()
            
            // 🔔 AHORA ES UN BOTÓN REAL
            Button(action: {
                print("Campana presionada. ¡Aquí puedes abrir un modal!")
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 24))
                        .foregroundColor(Color("FixyPrimary"))
                        .padding(8)
                        .background(Color("FixyPrimary").opacity(0.1))
                        .clipShape(Circle())
                    
                    if !notifications.isEmpty {
                        Text("\(notifications.count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }
    
    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text("Bienvenido, \(viewModel.userName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text("Encontramos nuevas solicitudes compatibles con tus habilidades.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            // 🌟 CHIPS INTELIGENTES: Usando nuestro nuevo FlowLayout
            if !viewModel.technologies.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.technologies, id: \.self) { tech in
                        Text(tech)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
            }
            
            // Botones de acción
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Explorar")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("FixyPrimary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Crear")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.teal, Color("FixyPrimary")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
    
    // Fila visual de cada notificación
    private func notificationRow(_ notif: FixyNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(notif.isUnread ? Color.teal : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notif.text)
                    .font(.subheadline)
                    .fontWeight(notif.isUnread ? .bold : .medium)
                    .foregroundColor(.primary)
                
                Text(notif.time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
