//
//  ProfileViewModel.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class ProfileViewModel {
    // Datos del usuario (Simulando lo que vendría de Supabase)
    var user: UserProfile
    
    // Catálogo de medallas (Simplificado para el perfil)
    let allMedals: [(name: String, min: Int, max: Int, image: String)] = [
        ("Hierro", 0, 299, "hierro"),
        ("Bronce", 300, 799, "bronce"),
        ("Plata", 800, 1799, "plata"),
        ("Oro", 1800, 3499, "oro"),
        ("Diamante", 3500, 5999, "diamante"),
        ("Maestro", 6000, 9999, "maestro"),
        ("Challenger", 10000, 99999, "challenger")
    ]
    
    // Lista global de tecnologías para el modal de edición
    let availableTags = ["TypeScript", "Supabase", "SQL", "Spring Boot", "Seguridad", "Rust", "Redes", "React", "Raspberry Pi", "Python", "Node.js", "Next.js", "Matematicas", "Machine Learning", "Logica de programacion", "Linux", "Dart", "Flutter", "Firebase"]
    
    // Estado temporal para los modales
    var tempTechnologies: Set<String> = []
    var tempPhoneNumber: String = ""
    
    init() {
        self.user = UserProfile(
            fullName: "Sofia Rios",
            career: "Desarrollo de Software",
            cycle: "Ciclo 6",
            points: 4320,
            rankingPosition: 2,
            rating: 4.9,
            completedTasks: 0,
            technologies: ["Python", "Dart", "Flutter", "Firebase", "Supabase"],
            phoneNumber: "987654321",
            links: [
                ProfileLink(title: "GitHub", url: "https://github.com", iconName: "chevron.left.forward.slash.o"),
                ProfileLink(title: "LinkedIn", url: "https://linkedin.com", iconName: "network")
            ],
            reviews: [
                UserReview(reviewerName: "Marco Villanueva", rating: 5.0, comment: "Excelente asesora, me ayudó a entender Supabase en 1 hora. Muy recomendada.", date: "Hace 2 días")
            ]
        )
    }
    
    // Propiedades calculadas para la medalla
    var currentMedal: (name: String, min: Int, max: Int, image: String) {
        allMedals.first { user.points >= $0.min && user.points <= $0.max } ?? allMedals[0]
    }
    
    var nextMedal: (name: String, min: Int, max: Int, image: String)? {
        if let currentIndex = allMedals.firstIndex(where: { $0.name == currentMedal.name }), currentIndex + 1 < allMedals.count {
            return allMedals[currentIndex + 1]
        }
        return nil
    }
    
    var progressPercentage: Double {
        guard let next = nextMedal else { return 1.0 }
        let range = Double(next.min - currentMedal.min)
        let currentProgress = Double(user.points - currentMedal.min)
        return currentProgress / range
    }
    
    // Funciones de guardado
    func prepareEditTech() { tempTechnologies = user.technologies }
    func saveTech() { user.technologies = tempTechnologies }
    
    func prepareEditPhone() { tempPhoneNumber = user.phoneNumber }
    func savePhone() { user.phoneNumber = tempPhoneNumber }
    
    // MARK: - Autenticación
        
        func signOut() async {
            do {
                // Llama a la función nativa de Supabase para cerrar sesión
                try await SupabaseManager.shared.client.auth.signOut()
                print("👋 Sesión cerrada exitosamente")
            } catch {
                print("❌ Error al cerrar sesión: \(error.localizedDescription)")
            }
        }
}
