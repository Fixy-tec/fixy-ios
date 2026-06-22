//
//  SearchViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class SearchViewModel {
    // Estado principal de búsqueda
    var searchText: String = ""
    var selectedFilter: String = "Todo"
    let filters: [String] = ["Todo", "Asesorias", "Proyectos"]
    
    // 👇 NUEVO: Estado de los Filtros Avanzados
    var compensationFilter: String = "Todos" // "Todos", "Con pago", "Voluntario"
    var difficultyFilter: Int = 0 // 0 significa "Todas"
    var selectedTagsFilter: Set<String> = []
    
    // Lista de todos los tags disponibles en la app
    let availableTags = ["TypeScript", "Supabase", "SQL", "Spring Boot", "Seguridad", "Rust", "Redes", "React", "Raspberry Pi", "Python", "Node.js", "Next.js"]
    
    // Base de datos simulada (Actualizada con la dificultad)
    private var allRequests: [FixyRequest] = [
        FixyRequest(type: "Asesoria", points: 400, title: "Gufugigufugufif", technologies: ["Node.js", "Java", "Matematicas", "Fisica", "Flutter"], creatorName: "Hhhw", creatorAvatar: "avatar_6", creatorMedal: "Hierro", price: 996.00, expiration: "Vence manana", applicants: 0, difficulty: 4),
        FixyRequest(type: "Proyecto", points: 180, title: "Hola ayuda porfa fast", technologies: ["Raspberry Pi", "Node.js", "Fisica", "Python", "React", "Linux", "Next.js"], creatorName: "Ana Castillo", creatorAvatar: "avatar_2", creatorMedal: "Bronce", price: nil, expiration: "Vence en 2 dias", applicants: 2, difficulty: 3),
        FixyRequest(type: "Asesoria", points: 250, title: "Ayuda con base de datos en SQL", technologies: ["SQL", "Supabase", "Logica de programacion"], creatorName: "Carlos Dev", creatorAvatar: "avatar_3", creatorMedal: "Plata", price: 50.00, expiration: "Vence hoy", applicants: 1, difficulty: 2)
    ]
    
    // 🌟 MAGIA EN TIEMPO REAL: Esta lista se recalcula sola cada vez que tocas algo
    var filteredRequests: [FixyRequest] {
        var result = allRequests
        
        // 1. Filtrar por Categoría Principal (Chips superiores)
        if selectedFilter != "Todo" {
            let typeToMatch = selectedFilter == "Asesorias" ? "Asesoria" : "Proyecto"
            result = result.filter { $0.type == typeToMatch }
        }
        
        // 2. Filtrar por Búsqueda de Texto
        if !searchText.isEmpty {
            result = result.filter { request in
                let titleMatch = request.title.localizedCaseInsensitiveContains(searchText)
                let techMatch = request.technologies.contains { $0.localizedCaseInsensitiveContains(searchText) }
                return titleMatch || techMatch
            }
        }
        
        // 3. Filtrar por Compensación
        if compensationFilter == "Con pago" {
            result = result.filter { $0.price != nil && $0.price! > 0 }
        } else if compensationFilter == "Voluntario" {
            result = result.filter { $0.price == nil || $0.price == 0 }
        }
        
        // 4. Filtrar por Dificultad
        if difficultyFilter != 0 {
            result = result.filter { $0.difficulty == difficultyFilter }
        }
        
        // 5. Filtrar por Tags (Si el usuario seleccionó alguno, la solicitud debe tener al menos uno coincidente)
        if !selectedTagsFilter.isEmpty {
            result = result.filter { request in
                let requestTags = Set(request.technologies)
                return !requestTags.isDisjoint(with: selectedTagsFilter) // Retorna true si comparten al menos 1 tag
            }
        }
        
        return result
    }
}
