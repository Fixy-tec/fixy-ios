//
//  ProfileViewModel.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class ProfileViewModel {
    // Objeto principal que tu vista lee directamente (viewModel.user...)
    var user = ProfilePresentationModel()
    var isLoading: Bool = true
    
    // Variables temporales para la edición (Modales)
    var tempTechnologies: Set<String> = []
    var tempPhoneNumber: String = ""
    var tempAvatarId: String? = nil
    let availableAvatars = ["arte", "cyborg", "hacker", "karate", "money", "pirata"]
    
    // Lista centralizada de Tecnologías (Viene de tu AppConstants)
    var availableTags: [String] {
        return AppConstants.tags
    }
    
    // Sistema de Medallas
    let allTiers: [MedalTier] = [
        MedalTier(name: "Hierro", minPoints: 0, maxPoints: 499),
        MedalTier(name: "Bronce", minPoints: 500, maxPoints: 999),
        MedalTier(name: "Plata", minPoints: 1000, maxPoints: 1999),
        MedalTier(name: "Oro", minPoints: 2000, maxPoints: 3499),
        MedalTier(name: "Diamante", minPoints: 3500, maxPoints: 5999),
        MedalTier(name: "Maestro", minPoints: 6000, maxPoints: 9999),
        MedalTier(name: "Challenger", minPoints: 10000, maxPoints: nil)
    ]
    
    init() {
        // La primera vez sí mostramos la pantalla de carga
        Task { await fetchFullProfile(showLoader: true) }
    }
    
    // 🌟 AÑADIDO: showLoader para decidir si mostramos el spinner o si actualizamos en silencio
    func fetchFullProfile(showLoader: Bool = true) async {
        if showLoader { self.isLoading = true }
        
        guard let myId = SupabaseManager.shared.client.auth.currentUser?.id else {
            self.isLoading = false
            return
        }
        
        do {
            // 1. Descargar Perfil (Obligatorio)
            let profile: ProfileDTO = try await SupabaseManager.shared.client
                .from("profiles")
                .select()
                .eq("id", value: myId)
                .single()
                .execute()
                .value
            
            let myPoints = profile.total_points ?? 0
            
            // 2. Descargar posición en el ranking (Calcula cuántos tienen más puntos)
            let higherUsersCount = (try? await SupabaseManager.shared.client
                .from("profiles")
                .select("*", head: true)
                .gt("total_points", value: myPoints)
                .execute()
                .count) ?? 0
            
            var dynamicLinks: [UserLinkDTO] = []
            
            if let git = profile.github_url, !git.isEmpty {
                dynamicLinks.append(UserLinkDTO(id: UUID(), title: "GitHub", url: git, icon_name: "terminal"))
            }
            if let lin = profile.linkedin_url, !lin.isEmpty {
                dynamicLinks.append(UserLinkDTO(id: UUID(), title: "LinkedIn", url: lin, icon_name: "briefcase"))
            }
            if let port = profile.portfolio_url, !port.isEmpty {
                dynamicLinks.append(UserLinkDTO(id: UUID(), title: "Portafolio", url: port, icon_name: "globe"))
            }
            
            // 4. Descargar Reviews (Queda igual)
            let reviews: [UserReviewDTO] = (try? await SupabaseManager.shared.client
                .from("user_reviews")
                .select()
                .eq("reviewee_id", value: myId)
                .order("created_at", ascending: false)
                .execute()
                .value) ?? []
            
            // 5. Ensamblar modelo para la vista
            let name = profile.full_name ?? "Estudiante"
            let cycleString = profile.cycle != nil ? "\(profile.cycle!)° Ciclo" : "1er Ciclo"
            
            self.user = ProfilePresentationModel(
                id: profile.id,
                initials: String(name.prefix(2)).uppercased(),
                avatarId: profile.avatar_id,
                fullName: name,
                career: profile.career ?? "Sin carrera asignada",
                cycle: cycleString,
                points: myPoints,
                rankingPosition: higherUsersCount + 1,
                rating: profile.rating ?? 5.0,
                completedTasks: profile.completed_tasks ?? 0,
                technologies: Set(profile.technologies ?? []),
                phoneNumber: profile.phone_number ?? "",
                links: dynamicLinks,
                reviews: reviews,
                bio: profile.bio ?? "",
                githubUrl: profile.github_url ?? "",
                linkedinUrl: profile.linkedin_url ?? "",
                portfolioUrl: profile.portfolio_url ?? ""
            )
            
        } catch {
            print("Error cargando perfil: \(error)")
            if self.user.fullName.isEmpty {
                self.user.fullName = "Error al cargar"
                self.user.initials = "!!"
            }
        }
        
        // 🌟 Siempre quitamos el loading al terminar
        self.isLoading = false
    }
    
    // MARK: - Cálculos de Medallas (¡Quedan idénticos, están perfectos!)
    
    var currentMedal: MedalDisplay {
        let pts = user.points
        let tier = allTiers.first { pts >= $0.minPoints && (pts <= ($0.maxPoints ?? Int.max)) } ?? allTiers[0]
        return MedalDisplay(name: tier.name, min: tier.minPoints, image: tier.name.lowercased())
    }
    
    var nextMedal: MedalDisplay? {
        let pts = user.points
        guard let currentIndex = allTiers.firstIndex(where: { pts >= $0.minPoints && (pts <= ($0.maxPoints ?? Int.max)) }),
              currentIndex + 1 < allTiers.count else { return nil }
        let nextTier = allTiers[currentIndex + 1]
        return MedalDisplay(name: nextTier.name, min: nextTier.minPoints, image: nextTier.name.lowercased())
    }
    
    var progressPercentage: Double {
        let pts = Double(user.points)
        let min = Double(currentMedal.min)
        guard let next = nextMedal else { return 1.0 }
        let max = Double(next.min)
        let range = max - min
        return range > 0 ? (pts - min) / range : 1.0
    }
    
    // MARK: - Funciones de Edición de tu Vista
    
    func prepareEditTech() { self.tempTechnologies = self.user.technologies }
    
    func saveTech() {
        let tagsArray = Array(tempTechnologies)
        self.user.technologies = self.tempTechnologies
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update(["technologies": tagsArray])
                    .eq("id", value: user.id)
                    .execute()
            } catch { print("Error guardando tags: \(error)") }
        }
    }
    
    func prepareEditPhone() { self.tempPhoneNumber = self.user.phoneNumber }
    
    func savePhone() {
        self.user.phoneNumber = self.tempPhoneNumber
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update(["phone_number": tempPhoneNumber])
                    .eq("id", value: user.id)
                    .execute()
            } catch { print("Error guardando teléfono: \(error)") }
        }
    }
    
    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch { print("Error cerrando sesión: \(error)") }
    }
    
    func prepareEditAvatar() { self.tempAvatarId = self.user.avatarId }
    
    func saveAvatar(newAvatar: String) {
        self.user.avatarId = newAvatar
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .update(["avatar_id": newAvatar])
                    .eq("id", value: user.id)
                    .execute()
            } catch { print("Error guardando avatar: \(error)") }
        }
    }
}
