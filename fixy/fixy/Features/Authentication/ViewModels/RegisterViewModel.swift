//
//  RegisterViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class RegisterViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // Función principal que recibe todos los datos de la vista
    func registerUser(
        email: String,
        password: String,
        fullName: String,
        career: String,
        cycle: String,
        technologies: Set<String>,
        avatarId: String?,
        whatsapp: String,
        bio: String,
        github: String,
        linkedin: String,
        portfolio: String
    ) async -> Bool {
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // 1. Crear el usuario en la bóveda segura (auth.users)
            let authResponse = try await SupabaseManager.shared.client.auth.signUp(
                email: email,
                password: password
            )
            
            // Obtenemos el ID directamente, ya no es opcional en esta versión
            let userId = authResponse.user.id
            
            // 2. Formatear los datos para nuestra tabla 'profiles'
            let cycleInt = Int(cycle) ?? 1
            let finalAvatar = avatarId ?? "avatar_1" // Avatar por defecto si no eligió nada
            let techsArray = Array(technologies) // Supabase requiere Arrays, no Sets
            
            let profileData = ProfileInsert(
                id: userId,
                email: email,
                fullName: fullName,
                career: career.isEmpty ? nil : career,
                cycle: cycleInt,
                technologies: techsArray,
                avatarId: finalAvatar,
                whatsapp: whatsapp.isEmpty ? nil : whatsapp,
                bio: bio.isEmpty ? nil : bio,
                github: github.isEmpty ? nil : github,
                linkedin: linkedin.isEmpty ? nil : linkedin,
                portfolio: portfolio.isEmpty ? nil : portfolio
            )
            
            // 3. Insertar el perfil público
            try await SupabaseManager.shared.client
                .from("profiles")
                .insert(profileData)
                .execute()
            
            self.isLoading = false
            return true // ¡Registro exitoso!
            
        } catch {
            self.isLoading = false
            // Si el correo ya existe, Supabase lanzará un error aquí
            self.errorMessage = "Error: \(error.localizedDescription)"
            return false
        }
    }
}

// Estructura auxiliar para mapear nuestras variables a las columnas de SQL
struct ProfileInsert: Encodable {
    let id: UUID
    let email: String
    let fullName: String
    let career: String?
    let cycle: Int?
    let technologies: [String]
    let avatarId: String
    let whatsapp: String?
    let bio: String?
    let github: String?
    let linkedin: String?
    let portfolio: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, career, cycle, technologies, whatsapp, bio, github, linkedin, portfolio
        case fullName = "full_name" // Conectamos camelCase con snake_case de SQL
        case avatarId = "avatar_id"
    }
}
