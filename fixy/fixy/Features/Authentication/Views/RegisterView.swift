//
//  RegisterView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

// Máquina de estados para los 5 pasos
enum RegistrationStep: Int, CaseIterable {
    case email = 1
    case password = 2
    case personalData = 3
    case avatarSelection = 4
    case confirmation = 5
}

struct RegisterView: View {
    @State private var currentStep: RegistrationStep = .email
    @Environment(\.dismiss) var dismiss // Para volver al Login
    
    var body: some View {
        VStack {
            // Barra de progreso superior
            ProgressView(value: Double(currentStep.rawValue), total: 5.0)
                .tint(Color("FixyPrimary"))
                .padding(.horizontal)
                .padding(.top, 20)
            
            // Contenido dinámico según el paso
            TabView(selection: $currentStep) {
                stepOneEmail.tag(RegistrationStep.email)
                stepTwoPassword.tag(RegistrationStep.password)
                stepThreeData.tag(RegistrationStep.personalData)
                stepFourAvatar.tag(RegistrationStep.avatarSelection)
                stepFiveConfirm.tag(RegistrationStep.confirmation)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Deslizable pero sin puntitos
            .animation(.easeInOut, value: currentStep)
            
            // Controles de Navegación Inferiores
            HStack {
                if currentStep != .email {
                    Button("Atrás") {
                        goBack()
                    }
                    .foregroundColor(.gray)
                } else {
                    Button("Cancelar") {
                        dismiss() // Cierra la pantalla de registro
                    }
                    .foregroundColor(Color("FixyPointsNegative"))
                }
                
                Spacer()
                
                Button(currentStep == .confirmation ? "Finalizar" : "Siguiente") {
                    goNext()
                }
                .fontWeight(.bold)
                .foregroundColor(Color("FixyPrimary"))
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Vistas de cada paso (Borradores estructurales)
    
    private var stepOneEmail: some View {
        VStack {
            Text("Paso 1: Tu correo institucional").font(.title2).bold()
            Text("Solo aceptamos @tecsup.edu.pe").foregroundColor(.secondary)
            Spacer()
            // Aquí irá el TextField del correo
            Spacer()
        }
    }
    
    private var stepTwoPassword: some View {
        VStack {
            Text("Paso 2: Crea una contraseña segura").font(.title2).bold()
            Spacer()
        }
    }
    
    private var stepThreeData: some View {
        VStack {
            Text("Paso 3: Datos Académicos").font(.title2).bold()
            Text("Carrera y Ciclo").foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var stepFourAvatar: some View {
        VStack {
            Text("Paso 4: Elige tu Avatar Fixo").font(.title2).bold()
            Spacer()
        }
    }
    
    private var stepFiveConfirm: some View {
        VStack {
            Text("Paso 5: Todo listo").font(.title2).bold()
            Text("Revisa tus datos y confirma").foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Lógica de Navegación
    
    private func goNext() {
        if let nextStep = RegistrationStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else {
            // Lógica final para enviar datos a Supabase
            print("Enviando registro a Supabase...")
        }
    }
    
    private func goBack() {
        if let prevStep = RegistrationStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prevStep
        }
    }
}

#Preview {
    RegisterView()
}
