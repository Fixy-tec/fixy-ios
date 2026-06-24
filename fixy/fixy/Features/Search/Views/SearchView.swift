//
//  SearchView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showCreateModal = false
    
    let filters = ["Todo", "Asesorias", "Proyectos"]
    
    var body: some View {
        NavigationStack {
            // ZStack para permitir que el botón "+" flote correctamente al fondo
            ZStack(alignment: .bottomTrailing) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Barra de Búsqueda y Botón de Ajustes
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                            TextField("Buscar por titulo, descr...", text: $viewModel.searchText)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Botón para alternar los filtros avanzados
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                viewModel.showAdvancedFilters.toggle()
                            }
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title3)
                                .foregroundColor(viewModel.showAdvancedFilters ? .white : Color("FixyPrimary"))
                                .padding(12)
                                .background(viewModel.showAdvancedFilters ? Color("FixyPrimary") : Color("FixyPrimary").opacity(0.15))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Píldoras de Categoría Superiores
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            tabPill(title: filter, icon: iconForFilter(filter))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // MARK: - CONTENIDO DINÁMICO (Resultados o Filtros Avanzados)
                    if viewModel.showAdvancedFilters {
                        
                        // 💡 SOLUCIÓN: Envolvemos todo el panel de filtros en un ScrollView independiente
                        // para que nunca más se aplaste hacia arriba y se pueda deslizar libremente.
                        ScrollView(.vertical, showsIndicators: false) {
                            advancedFiltersPanel
                                .padding(.top, 16)
                                .padding(.bottom, 110) // Margen de seguridad para el FAB y el TabBar
                        }
                        
                    } else {
                        
                        // Vista normal: Solicitudes encontradas
                        Text("\(viewModel.filteredRequests.count) solicitudes encontradas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        
                        if viewModel.isLoading {
                            Spacer(); ProgressView("Cargando solicitudes..."); Spacer()
                        } else if viewModel.filteredRequests.isEmpty {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass").font(.system(size: 40)).foregroundColor(.gray)
                                Text("No se encontraron solicitudes abiertas.").foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            // Lista de solicitudes
                            ScrollView(showsIndicators: false) {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.filteredRequests) { request in
                                        NavigationLink(destination: RequestDetailView(requestId: request.id)) {
                                            requestCard(request)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                }
                
                // MARK: - Botón Flotante "+" (FAB)
                Button(action: { showCreateModal = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("FixyPrimary"))
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .task { await viewModel.fetchRequests() }
            .fullScreenCover(isPresented: $showCreateModal) { CreateRequestView() }
        }
    }
    
    // MARK: - PANEL DE FILTROS AVANZADOS (Fiel a filtrado.jpeg)
    private var advancedFiltersPanel: some View {
        VStack(alignment: .leading, spacing: 28) {
            
            // Sección de Columnas (Compensación y Dificultad)
            HStack(alignment: .top, spacing: 20) {
                
                // Columna Izquierda: Compensación (Con desfase superior asimétrico)
                VStack(alignment: .leading, spacing: 16) {
                    Text("COMPENSACION")
                        .font(.caption).fontWeight(.bold).tracking(0.5).foregroundColor(.secondary)
                    
                    radioButton(title: "Todos", isSelected: viewModel.compensationFilter == "Todos") { viewModel.compensationFilter = "Todos" }
                    radioButton(title: "Con pago", isSelected: viewModel.compensationFilter == "Con pago") { viewModel.compensationFilter = "Con pago" }
                    radioButton(title: "Voluntario", isSelected: viewModel.compensationFilter == "Voluntario") { viewModel.compensationFilter = "Voluntario" }
                }
                .padding(.top, 35) // Respetando la asimetría visual de tu diseño original
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Columna Derecha: Dificultad
                VStack(alignment: .leading, spacing: 16) {
                    Text("DIFICULTAD")
                        .font(.caption).fontWeight(.bold).tracking(0.5).foregroundColor(.secondary)
                    
                    radioButton(title: "Todas", isSelected: viewModel.difficultyFilter == 0) { viewModel.difficultyFilter = 0 }
                    ForEach(1...5, id: \.self) { nivel in
                        radioButton(title: "Nivel \(nivel)", isSelected: viewModel.difficultyFilter == nivel) { viewModel.difficultyFilter = nivel }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider().padding(.vertical, 4)
            
            // Sección de Tags Centralizados (Llama directo a AppConstants.tags mediante el ViewModel)
            VStack(alignment: .leading, spacing: 16) {
                Text("TAGS")
                    .font(.caption).fontWeight(.bold).tracking(0.5).foregroundColor(.secondary)
                
                FlowLayout(spacing: 10) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        let isSelected = viewModel.selectedTags.contains(tag)
                        Button(action: {
                            if isSelected { viewModel.selectedTags.remove(tag) } else { viewModel.selectedTags.insert(tag) }
                        }) {
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.blue.opacity(0.12) : Color(UIColor.systemBackground))
                                .foregroundColor(isSelected ? Color.blue : .primary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding(22)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.65))
        .cornerRadius(24)
        .padding(.horizontal)
    }
    
    // MARK: - COMPONENTES AUXILIARES VISTOS ANTERIORMENTE
    
    private func tabPill(title: String, icon: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { viewModel.selectedFilter = title }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(viewModel.selectedFilter == title ? Color.blue.opacity(0.15) : Color.clear)
            .foregroundColor(viewModel.selectedFilter == title ? .primary : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(viewModel.selectedFilter == title ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func radioButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color("FixyPrimary") : .gray)
                Text(title).font(.subheadline).foregroundColor(.primary)
            }
        }
    }
    
    private func iconForFilter(_ filter: String) -> String {
        switch filter {
        case "Todo": return "square.grid.2x2.fill"
        case "Asesorias": return "book.fill"
        default: return "paperplane.fill"
        }
    }
    
    private func requestCard(_ request: SearchRequestDTO) -> some View {
        let isAsesoria = request.type.lowercased() == "asesoria"
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(request.type.capitalized)
                    .font(.caption).fontWeight(.bold)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(isAsesoria ? Color.teal.opacity(0.15) : Color.indigo.opacity(0.15))
                    .foregroundColor(isAsesoria ? .teal : .indigo)
                    .clipShape(Capsule())
                Spacer()
                Text("+\(request.points_reward) pts").font(.subheadline).fontWeight(.bold).foregroundColor(.teal)
            }
            Text(request.title).font(.title3).fontWeight(.bold).lineLimit(2)
            FlowLayout(spacing: 6) {
                ForEach(request.technologies.prefix(4), id: \.self) { tech in
                    Text(tech).font(.caption).padding(.horizontal, 10).padding(.vertical, 5).background(Color(UIColor.tertiarySystemBackground)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill").font(.title2).foregroundColor(.gray)
                Text(request.profiles?.full_name ?? "Usuario").font(.subheadline).fontWeight(.bold)
                if let price = request.price, price > 0 { Text("·  S/ \(String(format: "%.2f", price))").font(.subheadline).fontWeight(.bold).foregroundColor(.teal) }
            }
            Text("Vence \(String(request.deadline.prefix(10))) · 0 postulantes").font(.caption).foregroundColor(.secondary)
        }
        .padding(16).background(Color(UIColor.secondarySystemBackground)).cornerRadius(20)
    }
}
#Preview {
    SearchView()
}
