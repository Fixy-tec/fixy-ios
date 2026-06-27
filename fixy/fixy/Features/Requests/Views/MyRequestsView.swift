//
//  MyRequestsView.swift
//  fixy
//
//  Created by yordan on 26/06/26.
//

import SwiftUI

struct MyRequestsView: View {
    @State private var viewModel = MyRequestsViewModel()
    @State private var selectedTab: RequestTab = .postulaciones
    
    enum RequestTab: String, CaseIterable {
        case postulaciones = "Postulaciones"
        case creadas = "Creadas"
        case enProceso = "En proceso"
        case completadas = "Completadas"
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Título principal
                Text("Mis solicitudes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                // Menú de Pestañas (Tabs)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(RequestTab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text(tab.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(selectedTab == tab ? .bold : .medium)
                                        .foregroundColor(selectedTab == tab ? Color("FixyPrimary") : .secondary)
                                    
                                    // Línea indicadora
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color("FixyPrimary") : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Divider()
                
                // Contenido de las pestañas
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                switch selectedTab {
                                case .postulaciones:
                                    postulacionesList
                                case .creadas:
                                    creadasList
                                case .enProceso:
                                    enProcesoList
                                case .completadas:
                                    completadasList
                                }
                            }
                            .padding(20)
                        }
                        .refreshable {
                            await viewModel.fetchAllData()
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchAllData()
            }
        }
    }
    
    // MARK: - Listas por Pestaña
    
    @ViewBuilder
        private var postulacionesList: some View {
            if viewModel.myApplications.isEmpty {
                emptyStateView(message: "Aun no te has postulado a nada")
            } else {
                ForEach(viewModel.myApplications) { app in
                    // 🌟 CORRECCIÓN: Envolvemos la tarjeta en un NavigationLink
                    if let request = app.requests {
                        NavigationLink(destination: RequestDetailView(requestId: request.id)) {
                            applicationCard(app: app)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    
    @ViewBuilder
        private var creadasList: some View {
            if viewModel.myCreatedRequests.isEmpty {
                emptyStateView(message: "No has creado ninguna solicitud")
            } else {
                ForEach(viewModel.myCreatedRequests) { req in
                    NavigationLink(destination: RequestDetailView(requestId: req.id)) {
                        createdRequestCard(req: req)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    
    @ViewBuilder
        private var enProcesoList: some View {
            if viewModel.inProcessRequests.isEmpty {
                emptyStateView(message: "No tienes solicitudes en proceso")
            } else {
                ForEach(viewModel.inProcessRequests) { req in
                    // 🌟 AQUÍ ESTÁ LA CORRECCIÓN: Ahora navega a RequestDetailView pasando el ID real
                    NavigationLink(destination: RequestDetailView(requestId: req.id)) {
                        inProcessCard(req: req)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        
        @ViewBuilder
        private var completadasList: some View {
            if viewModel.completedRequests.isEmpty {
                emptyStateView(message: "Aún no tienes solicitudes completadas")
            } else {
                ForEach(viewModel.completedRequests) { req in
                    // 🌟 AQUÍ ESTÁ LA CORRECCIÓN: Ahora navega a RequestDetailView pasando el ID real
                    NavigationLink(destination: RequestDetailView(requestId: req.id)) {
                        completedCard(req: req)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    
    // MARK: - Diseño de Tarjetas (Cards)
    
    @ViewBuilder
    private func applicationCard(app: MyApplicationDTO) -> some View {
        // 🌟 SOLUCIÓN: Usamos if let en lugar de guard para que ViewBuilder haga su magia
        if let request = app.requests {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(request.type.capitalized)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("FixyPrimary"))
                    
                    Spacer()
                    
                    // Pill de estado
                    Text(app.status?.capitalized ?? "Pendiente")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .cornerRadius(10)
                    
                    // Menú de acciones
                    Menu {
                        Button(role: .destructive, action: {
                            Task { await viewModel.withdrawApplication(applicationId: app.id) }
                        }) {
                            Label("Retirar postulación", systemImage: "xmark.bin")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                            .padding(.leading, 8)
                    }
                }
                
                Text(request.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    private func createdRequestCard(req: MyRequestDTO) -> some View {
        let isAbierta = req.status == "abierta"
        let postulantes = req.applications?.count ?? 0
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(req.type.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("FixyPrimary"))
                
                Spacer()
                
                Text(req.status?.capitalized ?? "Desconocido")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isAbierta ? Color("FixyPrimary").opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(isAbierta ? Color("FixyPrimary") : .gray)
                    .cornerRadius(10)
                
                if isAbierta {
                    Menu {
                        if postulantes == 0 {
                            Button(role: .destructive, action: {
                                Task { await viewModel.deleteRequest(requestId: req.id) }
                            }) {
                                Label("Eliminar", systemImage: "trash")
                            }
                        } else {
                            Button(role: .destructive, action: {
                                Task { await viewModel.cancelRequest(requestId: req.id) }
                            }) {
                                Label("Cancelar solicitud", systemImage: "xmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                            .padding(.leading, 8)
                    }
                }
            }
            
            Text(req.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text("\(postulantes) postulante\(postulantes == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func inProcessCard(req: MyRequestDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(req.type.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("FixyPrimary"))
                Spacer()
                Text("En proceso")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.2))
                    .foregroundColor(.teal)
                    .cornerRadius(10)
            }
            
            Text(req.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            //Text("\(req.applicants_count ?? 1) postulante(s) aceptado(s)")
                //.font(.subheadline)
                //.foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func completedCard(req: MyRequestDTO) -> some View {
        let pendienteCalificar = req.status == "completada"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(req.type.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("FixyPrimary"))
                Spacer()
                Text("Completada")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(10)
            }
            
            Text(req.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            if pendienteCalificar {
                HStack(spacing: 4) {
                    Image(systemName: "star")
                    Text("Pendiente de calificar")
                }
                .font(.subheadline)
                .foregroundColor(.yellow)
                .fontWeight(.medium)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Estado Vacío (Empty State)
    
    // MARK: - Estado Vacío (Empty State)
        
        private func emptyStateView(message: String) -> some View {
            VStack(spacing: 16) {
                Spacer().frame(height: 100)
                Image(systemName: "list.clipboard")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.4))
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center) 
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
}
#Preview {
    MyRequestsView()
}
