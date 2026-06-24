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
    
    let filters = ["Todos", "Asesoria", "Proyecto"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // BARRA DE BÚSQUEDA (Reactiva)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Buscar por título o tecnología...", text: $viewModel.searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding([.horizontal, .top])
                
                // PÍLDORAS DE FILTRADO (Reactiva)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectedFilter = filter
                                }
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
                .padding(.vertical, 14)
                
                // LISTADO DE RESULTADOS
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando solicitudes...")
                    Spacer()
                } else if viewModel.filteredRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No se encontraron solicitudes que coincidan.")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredRequests) { request in
                                NavigationLink(destination: RequestDetailView(requestId: request.id)) {
                                    requestCard(request)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 90) // Evita solapamiento con el TabBar inferior
                    }
                }
            }
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .task {
                await viewModel.fetchRequests()
            }
            // BOTÓN "+" PARA CREAR SOLICITUDES
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateModal = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("FixyPrimary"))
                    }
                }
            }
            .fullScreenCover(isPresented: $showCreateModal) {
                CreateRequestView()
            }
        }
    }
    
    // DISEÑO DE TARJETA EXCLUSIVO DE LA BASE DE DATOS
    private func requestCard(_ request: SearchRequestDTO) -> some View {
        let isAsesoria = request.type.lowercased() == "asesoria"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
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
                .font(.subheadline)
            }
            
            Text(request.title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            FlowLayout(spacing: 6) {
                ForEach(request.technologies.prefix(3), id: \.self) { tech in
                    Text(tech)
                        .font(.caption2)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(6)
                }
                if request.technologies.count > 3 {
                    Text("+\(request.technologies.count - 3)")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Divider().padding(.vertical, 2)
            
            HStack {
                Label(request.profiles?.full_name ?? "Estudiante", systemImage: "person.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Dificultad \(request.difficulty)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
