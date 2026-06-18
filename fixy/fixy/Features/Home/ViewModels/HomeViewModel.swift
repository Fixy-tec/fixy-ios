//
//  HomeViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class HomeViewModel {
    var userName: String = ""
    var technologies: [String] = []
    var isLoading: Bool = true
    
    func fetchProfile() async {
        do {
            // 1. Obtener el ID del usuario que tiene la sesión iniciada
            guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
                isLoading = false
                return
            }
            
            // 2. Buscar su nombre y tecnologías en la tabla 'profiles'
            let profile: HomeProfileData = try await SupabaseManager.shared.client
                .from("profiles")
                .select("full_name, technologies")
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            // 3. Extraer solo el primer nombre para un saludo más amigable
            if let firstName = profile.fullName.components(separatedBy: " ").first {
                self.userName = firstName
            } else {
                self.userName = profile.fullName
            }
            
            self.technologies = profile.technologies
            self.isLoading = false
            
        } catch {
            print("Error al obtener el perfil: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
}

// Estructura ligera solo para leer los datos que necesitamos en el Inicio
struct HomeProfileData: Decodable {
    let fullName: String
    let technologies: [String]
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case technologies
    }
}
