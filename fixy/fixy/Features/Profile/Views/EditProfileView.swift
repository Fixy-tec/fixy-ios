//
//  EditProfileView.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = EditProfileViewModel()
    
    var body: some View {
        // 🌟 TRUCO SWIFT 6: Extraemos los valores del ViewModel a constantes locales
        // para que los closures de la interfaz gráfica no peleen con la concurrencia.
        let currentAvatar = viewModel.selectedAvatar
        let currentCustomData = viewModel.customAvatarData
        
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - 1. Sección de Avatar
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Avatar").font(.headline).foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Botón de galería
                                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(UIColor.secondarySystemBackground))
                                            .frame(width: 80, height: 80)
                                        
                                        // Usamos las constantes locales seguras
                                        if currentAvatar == "custom", let data = currentCustomData, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "camera.fill")
                                                .font(.title)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        if currentAvatar == "custom" {
                                            Circle().stroke(Color("FixyPrimary"), lineWidth: 3).frame(width: 86, height: 86)
                                        }
                                    }
                                }
                                .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                                    Task { await viewModel.processSelectedPhoto() }
                                }
                                
                                // Avatares predefinidos
                                ForEach(viewModel.predefinedAvatars, id: \.self) { avatar in
                                    Button(action: {
                                        // Las acciones (escribir datos) sí son seguras aquí
                                        withAnimation { viewModel.selectedAvatar = avatar }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(UIColor.secondarySystemBackground))
                                                .frame(width: 80, height: 80)
                                            
                                            Image(avatar)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                            
                                            // Usamos la constante local segura
                                            if currentAvatar == avatar {
                                                Circle().stroke(Color("FixyPrimary"), lineWidth: 3).frame(width: 86, height: 86)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // MARK: - 2. Sección de Datos Personales
                    VStack(alignment: .leading, spacing: 16) {
                        customTextField(icon: "person", title: "Nombre completo", placeholder: "Ej. Sofia Rios", text: $viewModel.fullName, errorMessage: viewModel.nameError)
                        
                        customTextField(icon: "graduationcap", title: "Carrera", placeholder: "Ej. Desarrollo de Software", text: $viewModel.career, errorMessage: viewModel.careerError)
                        
                        customTextField(icon: "calendar", title: "Ciclo (1-10)", placeholder: "Ej. 6", text: $viewModel.cycle, errorMessage: viewModel.cycleError, keyboardType: .numberPad)
                    }
                    
                    // MARK: - 3. Sección de Bio
                    VStack(alignment: .trailing, spacing: 4) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (opcional)").font(.caption).foregroundColor(.secondary)
                            TextEditor(text: $viewModel.bio)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .onChange(of: viewModel.bio) { _, newValue in
                                    if newValue.count > 280 { viewModel.bio = String(newValue.prefix(280)) }
                                }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        Text("\(viewModel.bio.count)/280").font(.caption).foregroundColor(.secondary)
                    }
                    
                    // MARK: - 4. Sección de URLs
                    VStack(alignment: .leading, spacing: 16) {
                        urlField(icon: "chevron.left.forward.slash", placeholder: "GitHub (URL, opcional)", text: $viewModel.githubUrl)
                        urlField(icon: "briefcase", placeholder: "LinkedIn (URL, opcional)", text: $viewModel.linkedinUrl)
                        urlField(icon: "globe", placeholder: "Portafolio (URL, opcional)", text: $viewModel.portfolioUrl)
                    }
                    
                    // Botón Guardar
                    Button(action: {
                        viewModel.saveProfile()
                        dismiss()
                    }) {
                        Text("Guardar cambios")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color("FixyPrimary") : Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.isFormValid)
                    .padding(.top, 10)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Componentes de Soporte
    
    private func customTextField(icon: String, title: String, placeholder: String, text: Binding<String>, errorMessage: String? = nil, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(errorMessage != nil ? .red : .secondary)
                    .frame(width: 24)
                
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.words)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = errorMessage {
                Text(error).font(.caption2).foregroundColor(.red).padding(.leading, 4)
            }
        }
    }
    
    private func urlField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.secondary).frame(width: 24)
            TextField(placeholder, text: text)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    EditProfileView()
}
