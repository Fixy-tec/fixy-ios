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
    // MARK: - Variables de Estado
    var selectedAvatar: String = "cyborg"
    var customAvatarData: Data? = nil
    var selectedPhotoItem: PhotosPickerItem? = nil
    let predefinedAvatars = ["arte", "cyborg", "hacker", "karate", "money", "pirata"]
    
    var fullName: String = ""
    var career: String = ""
    var cycle: String = ""
    var bio: String = ""
    var githubUrl: String = ""
    var linkedinUrl: String = ""
    var portfolioUrl: String = ""
    
    var nameError: String? = nil
    var careerError: String? = nil
    var cycleError: String? = nil
    var isLoading: Bool = false
    
    var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !career.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(cycle) != nil
    }
    
    func processSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.customAvatarData = data
                self.selectedAvatar = "custom"
            }
        } catch {
            print("Error cargando foto: \(error)")
        }
    }
    
    func loadCurrentData(user: ProfilePresentationModel) {
        self.fullName = user.fullName
        self.career = user.career
        self.cycle = user.cycle.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        self.selectedAvatar = user.avatarId ?? "cyborg"
        self.bio = user.bio
        self.githubUrl = user.githubUrl
        self.linkedinUrl = user.linkedinUrl
        self.portfolioUrl = user.portfolioUrl
    }
    
    // MARK: - Guardar en Supabase
    func saveProfile() async -> Bool {
        self.isLoading = true
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            self.isLoading = false
            return false
        }
        
        do {
            var finalAvatarId = selectedAvatar
            
            if selectedAvatar == "custom", let imageData = customAvatarData {
                let fileName = "\(userId)-\(UUID().uuidString).jpg"
                
                // 🌟 CORRECCIÓN 1: Nueva sintaxis de upload de Supabase
                try await SupabaseManager.shared.client.storage
                    .from("avatars")
                    .upload(fileName, data: imageData, options: FileOptions(contentType: "image/jpeg"))
                
                // 🌟 CORRECCIÓN 2: getPublicURL ya no es asíncrono, se quita el 'await'
                let urlResponse = try SupabaseManager.shared.client.storage
                    .from("avatars")
                    .getPublicURL(path: fileName)
                
                finalAvatarId = urlResponse.absoluteString
            }
            
            let updateData = ProfileUpdateDTO(
                full_name: fullName,
                career: career,
                cycle: Int(cycle) ?? 1,
                bio: bio,
                github_url: githubUrl,
                linkedin_url: linkedinUrl,
                portfolio_url: portfolioUrl,
                avatar_id: finalAvatarId
            )
            
            try await SupabaseManager.shared.client
                .from("profiles")
                .update(updateData)
                .eq("id", value: userId)
                .execute()
            
            self.isLoading = false
            return true
            
        } catch {
            print("Error al guardar: \(error)")
            self.isLoading = false
            return false
        }
    }
}
