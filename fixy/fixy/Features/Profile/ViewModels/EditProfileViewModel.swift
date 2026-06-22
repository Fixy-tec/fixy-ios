//
//  EditProfileViewModel.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation
import SwiftUI
import PhotosUI // Necesario para acceder a la galería del dispositivo

@Observable
@MainActor
final class EditProfileViewModel {
    // Campos del formulario (Inicializados con datos de ejemplo)
    var fullName: String = "Sofia Rios"
    var career: String = "Desarrollo de Software"
    var cycle: String = "6"
    var bio: String = ""
    var githubUrl: String = ""
    var linkedinUrl: String = ""
    var portfolioUrl: String = ""
    
    // Gestión del Avatar
    let predefinedAvatars = ["avatar_1", "avatar_2", "avatar_3", "avatar_4"] // Ajusta a los nombres de tus assets
    var selectedAvatar: String = "avatar_1"
    
    // Variables para la selección de foto de la galería
    var selectedPhotoItem: PhotosPickerItem? = nil
    var customAvatarData: Data? = nil
    
    // MARK: - Validaciones en Tiempo Real
    
    var nameError: String? {
        let hasNumbers = fullName.rangeOfCharacter(from: .decimalDigits) != nil
        return hasNumbers ? "El nombre no puede contener números" : nil
    }
    
    var careerError: String? {
        let hasNumbers = career.rangeOfCharacter(from: .decimalDigits) != nil
        return hasNumbers ? "La carrera no puede contener números" : nil
    }
    
    var cycleError: String? {
        guard let cycleInt = Int(cycle) else { return nil }
        return (cycleInt < 1 || cycleInt > 10) ? "El ciclo debe ser entre 1 y 10" : nil
    }
    
    var isFormValid: Bool {
        return nameError == nil &&
               careerError == nil &&
               cycleError == nil &&
               !fullName.isEmpty &&
               !career.isEmpty
    }
    
    // MARK: - Funciones
    
    // Procesa la imagen seleccionada de la galería nativa
    func processSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            self.customAvatarData = data
            self.selectedAvatar = "custom" // Indicador de que usamos foto propia
        }
    }
    
    func saveProfile() {
        if isFormValid {
            print("🚀 Guardando perfil de: \(fullName)")
            // Aquí irá la lógica de Supabase en el futuro
        }
    }
}
