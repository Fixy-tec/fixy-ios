//
//  SearchView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    
    // Filtros disponibles
    let filters = ["Todos", "Asesoria", "Proyecto"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - Barra de Búsqueda y Filtros
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                        TextField("Buscar por título, tecnología...", text: $viewModel.searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Píldoras de Filtro
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    withAnimation { viewModel.selectedFilter = filter }
                                }) {
                                    Text(filter)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedFilter == filter ? Color("FixyPrimary") : Color(UIColor.secondarySystemBackground))
                                        .foregroundColor(viewModel.selectedFilter == filter ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                .padding(.top, 10)
                
                // MARK: - Lista de Resultados Dinámica
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando solicitudes...")
                    Spacer()
                } else if viewModel.filteredRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 40)).foregroundColor(.gray)
                        Text("No se encontraron solicitudes abiertas.").foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredRequests) { request in
                                // 🌟 AQUÍ ESTÁ LA MAGIA DE LA NAVEGACIÓN
                                NavigationLink(destination: RequestDetailView(requestId: request.id)) {
                                    requestCard(request)
                                }
                                .buttonStyle(PlainButtonStyle()) // Evita que la tarjeta se vuelva azul al tocarla
                            }
                        }
                        .padding()
                        .padding(.bottom, 80) // Espacio para que el TabBar no tape la última tarjeta
                    }
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .task {
                // Descarga los datos cuando la pantalla aparece
                await viewModel.fetchRequests()
            }
        }
    }
    
    // MARK: - Diseño de la Tarjeta (Card)
    private func requestCard(_ request: SearchRequestDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Fila 1: Tipo y Puntos
            HStack {
                // 🚀 Aquí reemplazamos el "rocket" por "lightbulb.fill" para proyectos y "doc.text.fill" para asesorías
                let isAsesoria = request.type.lowercased() == "asesoria"
                HStack(spacing: 4) {
                    Image(systemName: isAsesoria ? "doc.text.fill" : "lightbulb.fill")
                    Text(request.type.capitalized)
                }
                .font(.caption).fontWeight(.bold)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isAsesoria ? Color.teal.opacity(0.15) : Color.indigo.opacity(0.15))
                .foregroundColor(isAsesoria ? .teal : .indigo)
                .clipShape(Capsule())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill").foregroundColor(.yellow)
                    Text("+\(request.points_reward) pts").fontWeight(.bold)
                }
            }
            
            // Fila 2: Título
            Text(request.title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Fila 3: Tecnologías (Mostramos máximo 3 para no saturar la tarjeta)
            HStack(spacing: 8) {
                ForEach(request.technologies.prefix(3), id: \.self) { tech in
                    Text(tech)
                        .font(.caption2)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
                if request.technologies.count > 3 {
                    Text("+\(request.technologies.count - 3)")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Fila 4: Creador y Dificultad
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill").foregroundColor(.secondary)
                    Text(request.profiles?.full_name ?? "Usuario").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                Text("Dificultad \(request.difficulty)/5").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    SearchView()
}
