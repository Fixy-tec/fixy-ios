//
//  LoginView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    
    // Estado local solo para manejar si el ojito de la contraseña está activado o no
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // 1. Logo
                // Asegúrate de arrastrar la imagen de tu logo a Assets y nombrarla "FixyLogo"
                Image("FixyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, 8)
                
                // 2. Textos de Bienvenida
                VStack(spacing: 8) {
                    Text("Bienvenido de vuelta")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Ingresa tus datos para continuar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 16)
                
                // 3. Campos de Texto
                VStack(spacing: 16) {
                    // Campo: Correo
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        
                        TextField("Correo Tecsup", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground)) // El gris claro de tu diseño
                    .cornerRadius(12)
                    
                    // Campo: Contraseña
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        
                        if isPasswordVisible {
                            TextField("Contrasena", text: $viewModel.password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Contrasena", text: $viewModel.password)
                                .autocapitalization(.none)
                        }
                        
                        Spacer()
                        
                        // Botón del ojito
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Mensaje de Error (si ocurre)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(Color("FixyPointsNegative"))
                }
                
                // 4. Botón Principal
                Button(action: {
                    Task {
                        await viewModel.loginWithPassword()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Iniciar sesion")
                    }
                }
                .fixyPrimaryButtonStyle()
                .disabled(viewModel.isLoading)
                .padding(.top, 8)
                
                // 5. Botón Crear Cuenta
                NavigationLink(destination: RegisterView()) {
                    Text("Crear cuenta nueva")
                        .font(.callout)
                        .foregroundColor(Color("FixyPrimary"))
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    LoginView()
}
