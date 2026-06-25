//
//  EditProfileViewModel.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation
import SwiftUI
import PhotosUI
import Supabase

@Observable
@MainActor
final class EditProfileViewModel {
    // MARK: - Avatar
    var selectedAvatar: String = "cyborg"
    var customAvatarData: Data? = nil
    var selectedPhotoItem: PhotosPickerItem? = nil
    let predefinedAvatars = ["arte", "cyborg", "hacker", "karate", "money", "pirata"]
    
    // MARK: - Datos Personales
    var fullName: String = ""
    var career: String = ""
    var cycle: String = "" // Tu vista usa String para el TextField
    
    // MARK: - Bio y URLs
    var bio: String = ""
    var githubUrl: String = ""
    var linkedinUrl: String = ""
    var portfolioUrl: String = ""
    
    // MARK: - Errores de Validación
    var nameError: String? = nil
    var careerError: String? = nil
    var cycleError: String? = nil
    var isLoading: Bool = false
    
    // MARK: - Validación Reactiva
    var isFormValid: Bool {
        let isNameValid = !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        let isCareerValid = !career.trimmingCharacters(in: .whitespaces).isEmpty
        let isCycleValid = Int(cycle) != nil && (1...10).contains(Int(cycle)!)
        
        return isNameValid && isCareerValid && isCycleValid
    }
    
    // MARK: - Procesar Foto Personalizada
    func processSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.customAvatarData = data
                self.selectedAvatar = "custom"
            }
        } catch {
            print("Error cargando la foto: \(error)")
        }
    }
    
    // MARK: - Pre-llenar Formulario
    func loadCurrentData(user: ProfilePresentationModel) {
        self.fullName = user.fullName == "Cargando..." ? "" : user.fullName
        self.career = user.career == "Sin carrera asignada" ? "" : user.career
        
        let cleanedCycle = user.cycle.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.cycle = cleanedCycle.isEmpty ? "1" : cleanedCycle
        
        // Asumiendo que agregas bio y urls a tu ProfilePresentationModel luego
        self.selectedAvatar = user.avatarId ?? "cyborg"
    }
    
    // MARK: - Guardar en Supabase
    func saveProfile() {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        self.isLoading = true
        
        // Convertimos el ciclo a Int (es seguro por la validación isFormValid)
        let cycleInt = Int(cycle) ?? 1
        
        let updateData = ProfileUpdateDTO(
            full_name: fullName,
            career: career,
            cycle: cycleInt,
            bio: bio,
            github_url: githubUrl,
            linkedin_url: linkedinUrl,
            portfolio_url: portfolioUrl,
            avatar_id: selectedAvatar
        )
        
        Task {
            do {
                // NOTA: Si 'selectedAvatar' es "custom", idealmente aquí subirías 'customAvatarData'
                // a un Storage Bucket de Supabase y guardarías la URL pública.
                // Por ahora guardaremos la selección estática o la etiqueta "custom".
                
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update(updateData)
                    .eq("id", value: userId)
                    .execute()
                
            } catch {
                print("❌ Error al guardar perfil: \(error)")
            }
            self.isLoading = false
        }
    }
}
