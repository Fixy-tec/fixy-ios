//
//  RequestDetailView.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import SwiftUI

struct RequestDetailView: View {
    let requestId: UUID
    @State private var viewModel = RequestDetailViewModel()
    @State private var showApplySheet = false
    @State private var applyMessage = ""
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando información...")
            } else if let request = viewModel.request {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Cabecera Dinámica
                        HStack {
                            Text(request.type.capitalized)
                                .font(.caption).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(request.type == "Asesoria" ? .teal.opacity(0.15) : .indigo.opacity(0.15))
                                .foregroundColor(request.type == "Asesoria" ? .teal : .indigo)
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            statusBadge(status: request.status)
                        }
                        
                        // Título de la Base de Datos
                        Text(request.title).font(.title).bold()
                        
                        // Tecnologías Dinámicas
                        FlowLayout(spacing: 8) {
                            ForEach(request.technologies, id: \.self) { tech in
                                Text(tech)
                                    .font(.subheadline).padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color(UIColor.secondarySystemBackground)).clipShape(Capsule())
                            }
                        }
                        
                        // Creador Info Dinámica
                        HStack {
                            Image(systemName: "person").foregroundColor(.secondary)
                            Text(request.profiles?.full_name ?? "Usuario Fixy").font(.headline)
                            Spacer()
                            if let medal = request.profiles?.medal {
                                HStack(spacing: 4) {
                                    Image(medal.lowercased()).resizable().frame(width: 16, height: 16)
                                    Text(medal)
                                }
                                .font(.caption).padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color(UIColor.secondarySystemBackground)).clipShape(Capsule())
                            }
                        }
                        
                        // Stats Grid Dinámico
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            statRow(icon: "bolt.fill", text: "+\(request.points_reward) pts")
                            statRow(icon: "chart.bar.fill", text: "Dificultad \(request.difficulty)/5")
                            if let price = request.price, price > 0 {
                                statRow(icon: "banknote", text: "S/ \(String(format: "%.2f", price))")
                            }
                            statRow(icon: "calendar", text: String(request.deadline.prefix(10)))
                        }
                        
                        // Descripción Dinámica
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripcion").font(.headline)
                            Text(request.description).font(.subheadline).foregroundColor(.secondary)
                        }
                        
                        Divider().padding(.vertical, 10)
                        
                        // 🌟 LÓGICA DE VISTAS
                        if viewModel.isCreator {
                            creatorView
                        } else {
                            applicantView
                        }
                    }
                    .padding(20)
                }
            } else {
                Text("Error: No se pudo cargar la solicitud.")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDetails(requestId: requestId) }
        .sheet(isPresented: $showApplySheet) { applySheet }
    }
    
    // MARK: - Vista del Creador
    private var creatorView: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if viewModel.request?.status == "en_proceso" {
                Button(action: { Task { await viewModel.markAsCompleted() } }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Marcar como completada")
                    }
                    .fontWeight(.bold).frame(maxWidth: .infinity).padding().background(Color("FixyPrimary")).foregroundColor(.white).cornerRadius(12)
                }
                .padding(.bottom, 10)
            }
            
            Text("Postulantes (\(viewModel.applicants.count))").font(.headline)
            
            if viewModel.applicants.isEmpty {
                Text("Aún no hay postulantes.").foregroundColor(.secondary)
            } else {
                ForEach(viewModel.applicants) { applicant in
                    let applicantName = applicant.profiles?.full_name ?? "Estudiante"
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(applicantName.prefix(2)).uppercased())
                                .font(.caption).fontWeight(.bold).foregroundColor(Color("FixyPrimary"))
                                .frame(width: 40, height: 40).background(Color("FixyPrimary").opacity(0.15)).clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(applicantName).font(.subheadline).bold()
                                Text("\(applicant.profiles?.total_points ?? 0) pts").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                if let medal = applicant.profiles?.medal {
                                    HStack(spacing: 2) {
                                        Image(medal.lowercased()).resizable().frame(width: 12, height: 12)
                                        Text(medal).font(.caption2).foregroundColor(.blue)
                                    }.padding(.horizontal, 8).padding(.vertical, 2).background(Color.blue.opacity(0.1)).clipShape(Capsule())
                                }
                                
                                Text(applicant.status.capitalized)
                                    .font(.caption2).bold()
                                    .foregroundColor(applicant.status == "aprobado" ? .green : .orange)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(applicant.status == "aprobado" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        if !applicant.message.isEmpty {
                            Text(applicant.message).font(.subheadline).foregroundColor(.secondary)
                        }
                        
                        if applicant.status == "pendiente" && viewModel.request?.status == "abierta" {
                            HStack(spacing: 12) {
                                Button(action: {}) { // Lógica de rechazar a futuro
                                    Text("Rechazar").frame(maxWidth: .infinity).padding(.vertical, 10).background(Color.white).foregroundColor(.primary).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                                Button(action: {
                                    Task { await viewModel.acceptApplicant(applicationId: applicant.id) }
                                }) {
                                    Text("Aceptar").fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 10).background(Color("FixyPrimary")).foregroundColor(.white).cornerRadius(12)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(16)
                }
            }
        }
    }
    
    // MARK: - Vista del Postulante
    private var applicantView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if viewModel.hasApplied {
                Text("Mi postulación").font(.headline)
                
                if !viewModel.applicationMessage.isEmpty {
                    Text(viewModel.applicationMessage)
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                }
                
                HStack {
                    Image(systemName: viewModel.myApplicationStatus == "aprobado" ? "checkmark.circle.fill" : "hourglass")
                    Text(viewModel.myApplicationStatus == "aprobado" ? "¡Felicidades! Has sido aceptado." : "El creador aún no ha tomado una decisión.")
                }
                .font(.subheadline)
                .foregroundColor(viewModel.myApplicationStatus == "aprobado" ? .green : .secondary)
                .padding().frame(maxWidth: .infinity, alignment: .leading)
                .background(viewModel.myApplicationStatus == "aprobado" ? Color.green.opacity(0.1) : Color.yellow.opacity(0.1))
                .cornerRadius(12)
                
            } else if viewModel.request?.status == "abierta" {
                Button(action: { showApplySheet = true }) {
                    Label("Postularme", systemImage: "paperplane.fill")
                        .fontWeight(.bold).frame(maxWidth: .infinity).padding().background(Color("FixyPrimary")).foregroundColor(.white).cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Componentes Auxiliares
    private func statRow(icon: String, text: String) -> some View {
        HStack { Image(systemName: icon).foregroundColor(.secondary).frame(width: 20); Text(text).font(.subheadline); Spacer() }
    }
    
    private func statusBadge(status: String) -> some View {
        let isAbierta = status == "abierta"
        let isEnProceso = status == "en_proceso"
        return Text(isAbierta ? "Abierta" : isEnProceso ? "En proceso" : "Completada")
            .font(.caption).bold().padding(.horizontal, 12).padding(.vertical, 6)
            .background(isAbierta ? Color.blue.opacity(0.15) : isEnProceso ? Color.teal.opacity(0.15) : Color.green.opacity(0.15))
            .foregroundColor(isAbierta ? .blue : isEnProceso ? .teal : .green)
            .clipShape(Capsule())
    }
    
    // Hoja inferior para redactar el mensaje de postulación
    private var applySheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Postularse").font(.title2).fontWeight(.bold)
            Text("Comparte un breve mensaje al creador (opcional, max 300 caracteres).").font(.subheadline).foregroundColor(.secondary)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $applyMessage)
                    .frame(height: 120).padding(8).background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                    .onChange(of: applyMessage) { _, newValue in
                        if newValue.count > 300 { applyMessage = String(newValue.prefix(300)) }
                    }
                Text("\(applyMessage.count)/300").font(.caption).foregroundColor(.secondary).padding(16)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.apply(message: applyMessage)
                    if success { showApplySheet = false }
                }
            }) {
                Text("Enviar postulación").fontWeight(.bold).frame(maxWidth: .infinity).padding().background(Color("FixyPrimary")).foregroundColor(.white).cornerRadius(12)
            }
            Spacer()
        }
        .padding(24).padding(.top, 10)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}


#Preview {
    // Le pasamos un UUID() vacío solo para que Xcode pueda dibujar la vista
    RequestDetailView(requestId: UUID())
}
