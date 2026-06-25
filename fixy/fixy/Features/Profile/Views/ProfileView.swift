//
//  ProfileView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    // Controles para abrir los modales
    @State private var showEditTech = false
    @State private var showEditPhone = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Header Superior
                    HStack {
                        Text("Perfil")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: { showEditProfile = true }) {
                            Image(systemName: "pencil").font(.title2).foregroundColor(.primary)
                        }
                        Button(action: { showLogoutAlert = true }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 1. Tarjeta Principal (Datos, Medalla, Stats, Bio)
                    mainInfoCard
                    
                    // 2. Tarjeta de Tecnologías
                    technologiesCard
                    
                    // 3. Tarjeta de Contacto
                    contactCard
                    
                    // 4. Tarjeta de Links
                    linksCard
                    
                    // 5. Tarjeta de Calificaciones
                    reviewsCard
                    
                    Spacer().frame(height: 100)
                }
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            // Modales (Bottom Sheets)
            .sheet(isPresented: $showEditTech) {
                editTechnologiesSheet
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditPhone) {
                editPhoneSheet
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showEditProfile, onDismiss: {
                Task { await viewModel.fetchFullProfile() }
            }) {
                EditProfileView(currentUser: viewModel.user)
            }
            .alert("Cerrar sesión", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Salir", role: .destructive) {
                    Task {
                        await viewModel.signOut()
                    }
                }
            } message: {
                Text("¿Estás seguro de que deseas salir de Fixy?")
            }
        }
    }
    
    // MARK: - Tarjeta 1: Información Principal
    private var mainInfoCard: some View {
        VStack(spacing: 20) {
            // Fila 1: Avatar, Nombre y Medalla
            HStack(spacing: 16) {
                Button(action: { showEditProfile = true }) {
                    if let avatar = viewModel.user.avatarId, !avatar.isEmpty {
                        // Verificamos si es una URL de la nube o un asset local
                        if avatar.hasPrefix("http") {
                            AsyncImage(url: URL(string: avatar)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
                            
                        } else if avatar == "custom" {
                            Text(viewModel.user.initials)
                                .font(.title).fontWeight(.bold).foregroundColor(Color("FixyPrimary"))
                                .frame(width: 80, height: 80)
                                .background(Color("FixyPrimary").opacity(0.15)).clipShape(Circle())
                        } else {
                            // Es un asset de Xcode ("cyborg", "hacker")
                            Image(avatar)
                                .resizable().scaledToFill()
                                .frame(width: 80, height: 80).clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
                        }
                    } else {
                        // Fallback: no tiene nada
                        Text(viewModel.user.initials)
                            .font(.title).fontWeight(.bold).foregroundColor(Color("FixyPrimary"))
                            .frame(width: 80, height: 80)
                            .background(Color("FixyPrimary").opacity(0.15)).clipShape(Circle())
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.fullName).font(.title2).fontWeight(.bold)
                    Text(viewModel.user.career).font(.subheadline).foregroundColor(.secondary)
                    Text(viewModel.user.cycle).font(.subheadline).foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(viewModel.currentMedal.image)
                    .resizable().scaledToFit().frame(width: 60, height: 60)
            }
            
            // Fila 2: Grid de Estadísticas
            HStack(spacing: 12) {
                statBox(value: "\(viewModel.user.points)", label: "Puntos", valueColor: Color("FixyPrimary"))
                statBox(value: "#\(viewModel.user.rankingPosition)", label: "Ranking", valueColor: .primary)
                statBox(value: "★ \(String(format: "%.1f", viewModel.user.rating))", label: "Rating", valueColor: .orange)
                statBox(value: "\(viewModel.user.completedTasks)", label: "Completadas", valueColor: .primary)
            }
            
            // Fila 3: Barra de Progreso
            VStack(spacing: 8) {
                HStack {
                    Text("\(viewModel.currentMedal.name) · \(viewModel.currentMedal.min) pts")
                    Spacer()
                    if let next = viewModel.nextMedal {
                        Text("\(next.name) · \(next.min) pts")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color("FixyPrimary").opacity(0.15)).frame(height: 8)
                        Capsule().fill(Color("FixyPrimary")).frame(width: geometry.size.width * viewModel.progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
                
                if let next = viewModel.nextMedal {
                    Text("\(next.min - viewModel.user.points) pts para \(next.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } // 👈 Fin de VStack de la barra de progreso
            
            // 🌟 NUEVA SECCIÓN: BIOGRAFÍA 🌟
            if !viewModel.user.bio.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("SOBRE MÍ")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    
                    Text(viewModel.user.bio)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true) // Evita que se corte
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private func statBox(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).fontWeight(.bold).foregroundColor(valueColor)
            Text(label).font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Tarjeta 2: Tecnologías
    private var technologiesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TECNOLOGIAS").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    viewModel.prepareEditTech()
                    showEditTech = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Editar")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("FixyPrimary"))
                }
            }
            
            if viewModel.user.technologies.isEmpty {
                Text("Aún no has agregado tecnologías.").font(.subheadline).foregroundColor(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.user.technologies), id: \.self) { tech in
                        Text(tech)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tarjeta 3: Contacto
    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONTACTO").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Image(systemName: "phone.fill").font(.title2).foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.phoneNumber.isEmpty ? "No configurado" : viewModel.user.phoneNumber)
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Solo visible cuando aprueben tu postulacion")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.prepareEditPhone()
                    showEditPhone = true
                }) {
                    Image(systemName: "pencil").font(.title3).foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tarjeta 4: Links
    private var linksCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("LINKS").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                Spacer()
            }
            
            if viewModel.user.links.isEmpty {
                Text("Añade tus redes profesionales aquí.").font(.subheadline).foregroundColor(.secondary)
            } else {
                ForEach(viewModel.user.links) { link in
                    Link(destination: URL(string: link.url)!) {
                        HStack(spacing: 12) {
                            Image(systemName: link.iconName).font(.title3)
                            Text(link.title).font(.subheadline).fontWeight(.medium)
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.caption)
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tarjeta 5: Calificaciones
    private var reviewsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ÚLTIMAS CALIFICACIONES").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                Spacer()
            }
            
            if viewModel.user.reviews.isEmpty {
                Text("Aún no tienes calificaciones.").font(.subheadline).foregroundColor(.secondary)
            } else {
                ForEach(viewModel.user.reviews) { review in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(review.reviewerInitials)
                                .font(.caption).fontWeight(.bold).foregroundColor(.white)
                                .frame(width: 30, height: 30).background(Color.gray).clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(review.reviewerName).font(.subheadline).fontWeight(.bold)
                                Text(review.date).font(.caption2).foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill").foregroundColor(.orange)
                                Text(String(format: "%.1f", review.rating)).fontWeight(.bold)
                            }.font(.subheadline)
                        }
                        Text(review.comment).font(.subheadline).foregroundColor(.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Modales (Hojas de edición rápidas)
    private var editTechnologiesSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mis especialidades")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
                .padding(.top, 30)
            
            ScrollView(showsIndicators: false) {
                FlowLayout(spacing: 10) {
                    ForEach(viewModel.availableTags, id: \.self) { tech in
                        let isSelected = viewModel.tempTechnologies.contains(tech)
                        HStack(spacing: 4) {
                            if isSelected { Image(systemName: "checkmark").font(.system(size: 10)) }
                            Text(tech)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color("FixyPrimary").opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? Color("FixyPrimary") : .primary)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 1))
                        .onTapGesture {
                            withAnimation {
                                if isSelected { viewModel.tempTechnologies.remove(tech) }
                                else { viewModel.tempTechnologies.insert(tech) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: {
                viewModel.saveTech()
                showEditTech = false
            }) {
                Text("Guardar especialidades")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("FixyPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
        }
    }
    
    private var editPhoneSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Numero de WhatsApp")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Solo se mostrara cuando aceptes a un postulante o te aprueben.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "phone.fill").foregroundColor(.secondary)
                TextField("Escribe tu numero", text: $viewModel.tempPhoneNumber)
                    .keyboardType(.numberPad)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            Spacer()
            
            Button(action: {
                viewModel.savePhone()
                showEditPhone = false
            }) {
                Text("Guardar")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("FixyPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .padding(.top, 10)
    }
}

#Preview {
    ProfileView()
}
