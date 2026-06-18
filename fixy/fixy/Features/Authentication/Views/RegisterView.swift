//
//  RegisterView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
// ["arte", "pirta", "money", "karate", "hacker", "cyborg"]

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    
    // MARK: - Estados de Datos (Formulario)
    // Paso 1
    @State private var fullName = ""
    @State private var email = ""
    @State private var career = ""
    @State private var cycle = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    // Paso 2
    let allTechs = ["TypeScript", "Supabase", "SQL", "Spring Boot", "Seguridad", "Rust", "Redes", "React", "Raspberry Pi", "Python", "Node.js", "Next.js", "Matematicas", "Machine Learning", "Logica de programacion", "Linux", "JavaScript", "Java", "Go", "Flutter", "Fisica", "Firebase", "Estructuras", "Estadistica"]
    @State private var selectedTechs: Set<String> = []
    
    // Paso 3
    let avatars = ["arte", "pirta", "money", "karate", "hacker", "cyborg"]
    @State private var selectedAvatar: String? = nil
    
    // Paso 4
    @State private var whatsapp = ""
    @State private var personalDescription = ""
    
    // Paso 5
    @State private var github = ""
    @State private var linkedin = ""
    @State private var portfolio = ""
    
    // Variables para validación de base de datos
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Botón atrás y Título de Paso
            HStack {
                Button(action: goBack) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Paso \(currentStep) de 5")
                    .font(.headline)
                Spacer()
                // Espaciador invisible para centrar el texto
                Image(systemName: "arrow.left").opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Barra de progreso segmentada
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? Color("FixyPrimary") : Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Contenedor dinámico de pasos
            TabView(selection: $currentStep) {
                stepOneView.tag(1)
                stepTwoView.tag(2)
                stepThreeView.tag(3)
                stepFourView.tag(4)
                stepFiveView.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
            
            // Botones inferiores
            HStack {
                if currentStep > 1 {
                    Button(action: goBack) {
                        Text("Atras")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Button(action: goNext) {
                    Text(currentStep == 5 ? "Crear cuenta" : "Continuar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("FixyPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
    
    // MARK: - Paso 1: Crea tu cuenta
    private var stepOneView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerText(title: "Crea tu cuenta", subtitle: "Solo necesitas tu correo institucional.")
                
                // 1. Nombre sin números
                customTextField(icon: "person", placeholder: "Nombre completo", text: $fullName)
                    .onChange(of: fullName) { oldValue, newValue in
                        fullName = newValue.filter { !$0.isNumber }
                    }
                
                // 2. Correo
                customTextField(icon: "envelope", placeholder: "Correo Tecsup", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                // 3. Carrera
                customTextField(icon: "graduationcap", placeholder: "Carrera", text: $career)
                
                // 4. Ciclo
                customTextField(icon: "calendar", placeholder: "Ciclo (1-10)", text: $cycle)
                    .keyboardType(.numberPad)
                    .onChange(of: cycle) { oldValue, newValue in
                        cycle = newValue.filter { $0.isNumber }
                        if cycle.count > 2 { cycle = String(cycle.prefix(2)) }
                    }
                
                // 5. Contraseña
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock").foregroundColor(.gray)
                        if isPasswordVisible {
                            TextField("Contrasena", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Contrasena", text: $password)
                                .autocapitalization(.none)
                        }
                        Spacer()
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye").foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Text("Minimo 8 caracteres")
                        .font(.caption)
                        .foregroundColor(password.count >= 8 ? .green : .gray)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Paso 2: Tecnologías
    private var stepTwoView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerText(title: "Cuales son tus tecnologias?", subtitle: "Esto nos ayuda a mostrarte solicitudes relevantes. Puedes saltar este paso.")
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                    ForEach(allTechs, id: \.self) { tech in
                        Text(tech)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedTechs.contains(tech) ? Color("FixyPrimary").opacity(0.1) : Color.clear)
                            .foregroundColor(selectedTechs.contains(tech) ? Color("FixyPrimary") : .primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedTechs.contains(tech) ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .onTapGesture {
                                if selectedTechs.contains(tech) {
                                    selectedTechs.remove(tech)
                                } else {
                                    selectedTechs.insert(tech)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Paso 3: Avatar
    private var stepThreeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerText(title: "Elige tu avatar", subtitle: "Sera tu imagen de perfil dentro de Fixy. Puedes cambiarlo despues.")
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(avatars, id: \.self) { avatar in
                        Image(avatar)
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedAvatar == avatar ? Color("FixyPrimary") : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                selectedAvatar = avatar
                            }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Paso 4: Cuéntanos sobre ti
    private var stepFourView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerText(title: "Cuentanos sobre ti", subtitle: "Esta info aparecera en tu perfil publico. Puedes editarla despues.")
                
                // WhatsApp
                VStack(alignment: .leading, spacing: 4) {
                    customTextField(icon: "phone", placeholder: "WhatsApp (opcional)", text: $whatsapp)
                        .keyboardType(.phonePad)
                    Text("Solo visible cuando aprueben tu postulacion.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                
                // Descripción Personal
                VStack(alignment: .trailing, spacing: 4) {
                    ZStack(alignment: .topLeading) {
                        Color(UIColor.secondarySystemBackground)
                            .cornerRadius(12)
                        
                        if personalDescription.isEmpty {
                            Text("Descripcion personal (opcional)")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                        }
                        
                        TextEditor(text: $personalDescription)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .onChange(of: personalDescription) { oldValue, newValue in
                                if newValue.count > 200 {
                                    personalDescription = String(newValue.prefix(200))
                                }
                            }
                    }
                    .frame(height: 150)
                    
                    Text("\(personalDescription.count)/200")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Paso 5: Tus links
    private var stepFiveView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                headerText(title: "Tus links", subtitle: "Agrega tu portafolio o redes. Completamente opcional.")
                
                customTextField(icon: "chevron.left.forwardslash.chevron.right", placeholder: "GitHub (opcional)", text: $github)
                    .autocapitalization(.none)
                
                customTextField(icon: "briefcase", placeholder: "LinkedIn (opcional)", text: $linkedin)
                    .autocapitalization(.none)
                
                customTextField(icon: "globe", placeholder: "Portafolio (opcional)", text: $portfolio)
                    .autocapitalization(.none)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.primary)
                    Text("Ya casi terminas! Tu perfil estara listo para conectar con otros estudiantes de Tecsup.")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.top, 8)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(Color("FixyPointsNegative"))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Componentes Reutilizables
    private func headerText(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 16)
    }
    
    private func customTextField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.gray)
            TextField(placeholder, text: text)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Lógica de Navegación
    private func goNext() {
        if currentStep < 5 {
            withAnimation { currentStep += 1 }
        } else {
            print("Enviando a Supabase...")
        }
    }
    
    private func goBack() {
        if currentStep > 1 {
            withAnimation { currentStep -= 1 }
        } else {
            dismiss()
        }
    }
}

#Preview {
    RegisterView()
}
