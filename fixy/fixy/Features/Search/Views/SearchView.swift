//
//  SearchView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Buscar")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        searchBarSection
                        
                        filterChipsSection
                        
                        Text("\(viewModel.filteredRequests.count) solicitudes encontradas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredRequests) { request in
                                RequestCardView(request: request)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                floatingActionButton
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Componentes de la Vista
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar por titulo, descr...", text: $viewModel.searchText)
                    .autocapitalization(.none)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(Color("FixyPrimary"))
                    .padding()
                    .background(Color("FixyPrimary").opacity(0.15))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.filters, id: \.self) { filter in
                    Button(action: {
                        withAnimation { viewModel.selectedFilter = filter }
                    }) {
                        HStack(spacing: 6) {
                            if filter == "Todo" {
                                Image(systemName: "square.grid.2x2")
                            } else if filter == "Asesorias" {
                                Image(systemName: "book.pages")
                            } else {
                                Image(systemName: "rocket")
                            }
                            
                            Text(filter)
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(viewModel.selectedFilter == filter ? Color("FixyPrimary").opacity(0.15) : Color.clear)
                        .foregroundColor(viewModel.selectedFilter == filter ? Color("FixyPrimary") : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewModel.selectedFilter == filter ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var floatingActionButton: some View {
        Button(action: {
            print("Abrir pantalla para crear nueva solicitud")
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color("FixyPrimary"))
                .padding(18)
                .background(Color("FixyPrimary").opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

struct RequestCardView: View {
    let request: FixyRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(request.type)
                    .font(.caption).fontWeight(.bold)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.teal.opacity(0.2)).foregroundColor(.teal)
                    .clipShape(Capsule())
                Spacer()
                Text("+\(request.points) pts")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.teal)
            }
            
            Text(request.title)
                .font(.title3).fontWeight(.semibold).foregroundColor(.primary)
            
            FlowLayout(spacing: 8) {
                ForEach(request.technologies, id: \.self) { tech in
                    Text(tech).font(.caption).foregroundColor(.primary)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            
            HStack(spacing: 8) {
                Image(request.creatorAvatar)
                    .resizable().scaledToFit().frame(width: 24, height: 24)
                    .clipShape(Circle()).background(Circle().fill(Color.gray.opacity(0.2)))
                Text(request.creatorName).font(.subheadline).fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: "hexagon").font(.system(size: 10))
                    Text(request.creatorMedal)
                }
                .font(.caption).foregroundColor(.gray)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.gray.opacity(0.15)).clipShape(Capsule())
                
                if let price = request.price {
                    Text("· S/ \(String(format: "%.2f", price))")
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.teal)
                }
            }
            .padding(.top, 4)
            
            Text("\(request.expiration) · \(request.applicants) postulantes")
                .font(.caption).foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    SearchView()
}
