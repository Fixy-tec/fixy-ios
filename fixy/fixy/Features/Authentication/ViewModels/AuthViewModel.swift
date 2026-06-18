//
//  AuthViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
final class AuthViewModel {
    var email: String = ""
    var password: String = "" // Nueva variable
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func loginWithPassword() async {
        // Validación del dominio
        guard email.hasSuffix("@tecsup.edu.pe") else {
            self.errorMessage = "Solo se permiten correos @tecsup.edu.pe"
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // Inicio de sesión con correo y contraseña en Supabase
            try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
            print("✅ Sesión iniciada con éxito")
            // Aquí iría la lógica para navegar al Dashboard
            
        } catch {
            self.errorMessage = "Credenciales incorrectas o error de red."
        }
        
        self.isLoading = false
    }
}
