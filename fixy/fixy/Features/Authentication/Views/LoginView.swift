//
//  LoginView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

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
            VStack(spacing: 0) { // 🌟
                Spacer()
                
                // 1. Logo
                Image("FixyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, 16)
                
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
                .padding(.bottom, 32) // 🌟 Más espacio antes del formulario
                
                // 3. Campos de Texto
                VStack(spacing: 16) {
                    // Campo: Correo
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        
                        TextField("Correo", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Campo: Contraseña
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        
                        if isPasswordVisible {
                            TextField("Contraseña", text: $viewModel.password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Contraseña", text: $viewModel.password)
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
                .padding(.bottom, 8)
                
                // Mensaje de Error (si ocurre)
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(Color("FixyPointsNegative"))
                        .padding(.bottom, 8)
                } else {
                    Spacer().frame(height: 24) // Espacio fantasma si no hay error
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
                        Text("Iniciar sesión")
                    }
                }
                .fixyPrimaryButtonStyle()
                .disabled(viewModel.isLoading)
                
                // 🌟 5. Separador Estético
                HStack {
                    VStack { Divider() }
                    Text("O continuar con")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    VStack { Divider() }
                }
                .padding(.vertical, 24)
                
                // 🌟 6. Botón de Google
                Button(action: {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }) {
                    HStack(spacing: 12) {
                        // Cambia "globe" por "google_logo" si tienes la imagen real en tus Assets
                        Image(systemName: "globe")
                            .font(.title3)
                        Text("Google")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 32)
                
                // 7. Botón Crear Cuenta
                NavigationLink(destination: RegisterView()) {
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .foregroundColor(.secondary)
                        Text("Regístrate")
                            .fontWeight(.bold)
                            .foregroundColor(Color("FixyPrimary"))
                    }
                    .font(.callout)
                }
                
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
